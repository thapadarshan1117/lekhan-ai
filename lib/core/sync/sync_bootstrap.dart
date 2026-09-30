import 'dart:async';
import 'dart:developer';

import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/storage/storage_manager.dart';
import 'package:lekhan_ai/core/sync/background_sync_scheduler.dart';
import 'package:lekhan_ai/core/sync/sync_manager.dart';
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
  });

  final SyncManager syncManager;
  final SyncQueue queue;
  final SyncPreferences preferences;
  final BackgroundSyncScheduler backgroundScheduler;
  final StorageManager storageManager;

  /// Repositories publish here after every local write; this is what makes a
  /// change leave the device within seconds instead of at the next trigger.
  final SyncRequestBus requestBus;

  StreamSubscription<void>? _busSubscription;
  DateTime? _lastPushRequest;
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

    final bool backgroundEnabled = await preferences.backgroundEnabled;
    if (backgroundEnabled) {
      await _safely('register background sync', () async {
        await backgroundScheduler.initialize();
        await backgroundScheduler.schedulePeriodic();
      });
    }

    if (syncOnStart) {
      // Never await: the first screen must not wait for the network.
      unawaited(syncManager.sync(trigger: SyncTrigger.appStartup));
    }
  }

  /// Called when the app is sent to the background and there is work pending.
  Future<void> onAppPaused() async {
    final bool backgroundEnabled = await preferences.backgroundEnabled;
    if (!backgroundEnabled) return;
    if (syncManager.currentState.pendingCount == 0) return;
    await _safely('schedule one-off sync', backgroundScheduler.scheduleOneOff);
  }

  /// Bridges the write path to the sync engine without either side knowing
  /// about the other.
  void _listenForLocalWrites() {
    _busSubscription ??= requestBus.onRequest.listen((_) {
      final DateTime now = DateTime.now();
      final DateTime? last = _lastPushRequest;
      if (last != null && now.difference(last) < _pushDebounce) return;
      _lastPushRequest = now;
      unawaited(syncManager.sync(trigger: SyncTrigger.push));
    });
  }

  Future<void> dispose() async {
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
