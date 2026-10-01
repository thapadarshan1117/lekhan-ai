import 'dart:async';
import 'dart:developer';

import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/storage/storage_manager.dart';
import 'package:lekhan_ai/core/sync/background_sync_scheduler.dart';
import 'package:lekhan_ai/core/sync/sync_manager.dart';
import 'package:lekhan_ai/core/sync/offline_session_guard.dart';
import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_request_bus.dart';
import 'package:lekhan_ai/core/sync/sync_state.dart';

/// The single call that turns the offline engine on.
///
/// ```dart
/// await setUpServiceLocator();
/// await sl<SyncBootstrap>().start();
/// ```
///
/// It performs the three triggers the architecture asks for:
///  * housekeeping + one sync pass at startup,
///  * a listener that syncs again when the network comes back (owned by
///    [SyncManager.start]),
///  * a background task registration for when the app is not running.
class SyncBootstrap {
  SyncBootstrap({
    required this.syncManager,
    required this.queue,
    required this.preferences,
    required this.backgroundScheduler,
    required this.storageManager,
    required this.requestBus,
    required this.sessionGuard,
  });

  final SyncManager syncManager;
  final SyncQueue queue;
  final SyncPreferences preferences;
  final BackgroundSyncScheduler backgroundScheduler;
  final StorageManager storageManager;

  /// Repositories publish here after every local write; this is what makes a
  /// change leave the device within seconds instead of at the next trigger.
  final SyncRequestBus requestBus;
  final OfflineSessionGuard sessionGuard;

  StreamSubscription<void>? _busSubscription;
  Timer? _pushDebounceTimer;
  bool _started = false;

  /// Requests arriving closer together than this are collapsed into one run,
  /// so saving five edits in a row does not start five passes.
  static const Duration _pushDebounce = Duration(seconds: 3);

  bool get hasStarted => _started;

  Future<void> start({bool syncOnStart = true}) async {
    if (_started) return;
    _started = true;

    await _safely('clean local storage', storageManager.cleanUp);
    await _safely('prune completed tasks', () => queue.pruneCompleted());
    await _safely('reset interrupted tasks', () => queue.resetStuck());
    await _safely('start sync manager', syncManager.start);
    _listenForLocalWrites();

    final bool authorized = await _prepareSession();
    if (authorized) await _schedulePeriodicIfEnabled();

    if (syncOnStart && authorized) {
      // Never await: the first screen must not wait for the network.
      unawaited(syncManager.sync(trigger: SyncTrigger.appStartup));
    }
  }

  /// Called after login/OTP has stored a valid user and token.
  Future<void> onSignedIn() async {
    final bool authorized = await _prepareSession();
    if (!authorized) return;
    syncManager.resume();
    await _schedulePeriodicIfEnabled();
    unawaited(syncManager.sync(trigger: SyncTrigger.appResume));
  }

  Future<void> onAppResumed() async {
    final bool authorized = await _prepareSession();
    if (!authorized) return;
    syncManager.resume();
    unawaited(syncManager.sync(trigger: SyncTrigger.appResume));
  }

  Future<bool> _prepareSession() async {
    try {
      return await sessionGuard.prepareForCurrentUser();
    } catch (error) {
      log('SyncBootstrap: session preparation failed ($error)');
      return false;
    }
  }

  Future<void> _schedulePeriodicIfEnabled() async {
    final bool backgroundEnabled = await preferences.backgroundEnabled;
    if (!backgroundEnabled) return;
    await _safely('register background sync', () async {
      await backgroundScheduler.initialize();
      await backgroundScheduler.schedulePeriodic();
    });
  }

  /// Called when the app is sent to the background and there is work pending.
  Future<void> onAppPaused() async {
    bool authorized;
    try {
      authorized = await sessionGuard.canSync();
    } catch (error) {
      log('SyncBootstrap: cannot check background session ($error)');
      return;
    }
    if (!authorized) return;
    final bool backgroundEnabled = await preferences.backgroundEnabled;
    if (!backgroundEnabled) return;
    final Map<SyncStatus, int> counts = await queue.counts();
    final int open = (counts[SyncStatus.pending] ?? 0) +
        (counts[SyncStatus.inProgress] ?? 0);
    if (open == 0) return;
    // Use the final foreground window as well as asking the OS for a later
    // background execution slot.
    unawaited(syncManager.sync(trigger: SyncTrigger.background));
    await _safely('schedule one-off sync', backgroundScheduler.scheduleOneOff);
  }

  /// Bridges the write path to the sync engine without either side knowing
  /// about the other.
  void _listenForLocalWrites() {
    _busSubscription ??= requestBus.onRequest.listen((_) {
      // Trailing debounce (not leading throttle): the final edit in a burst
      // always gets a sync request, and a write during an active pass is
      // retained by SyncManager as a follow-up run.
      _pushDebounceTimer?.cancel();
      _pushDebounceTimer = Timer(_pushDebounce, () {
        unawaited(syncManager.sync(trigger: SyncTrigger.push));
      });
    });
  }

  Future<void> dispose() async {
    _pushDebounceTimer?.cancel();
    _pushDebounceTimer = null;
    await _busSubscription?.cancel();
    _busSubscription = null;
  }

  Future<void> _safely(String label, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      log('SyncBootstrap: $label failed ($error)');
    }
  }
}
