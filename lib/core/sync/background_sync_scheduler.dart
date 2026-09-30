import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/database/app_database.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/storage/local_file_storage.dart';
import 'package:lekhan_ai/core/sync/sync_manager.dart';
import 'package:workmanager/workmanager.dart';

/// Asks the OS for an opportunity to sync while the app is not in the
/// foreground.
///
/// IMPORTANT, and deliberately reflected in the product copy: the operating
/// system decides when (and whether) these windows happen. The app must be
/// designed around *eventual* synchronisation - never around "syncs every 5
/// minutes".
class BackgroundSyncScheduler {
  BackgroundSyncScheduler();

  static const String periodicTaskName = 'lekhanBackgroundSync';
  static const String oneOffTaskName = 'lekhanBackgroundSyncOnce';
  static const String uniquePeriodicName = 'lekhan.sync.periodic';
  static const String uniqueOneOffName = 'lekhan.sync.oneOff';

  /// Minimum the OS accepts for periodic work.
  static const Duration minimumPeriodicFrequency = Duration(minutes: 15);

  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  /// Registers the callback dispatcher. Safe (and cheap) to call on every
  /// start.
  Future<void> initialize() async {
    if (!isSupported) return;
    try {
      // `isInDebugMode` was deprecated in workmanager 0.9 (it is a no-op now);
      // debug output is configured through WorkmanagerDebug handlers instead.
      await Workmanager().initialize(syncCallbackDispatcher);
    } catch (error) {
      debugPrint('BackgroundSyncScheduler: initialize failed ($error)');
    }
  }

  /// The "try at least every ~15 minutes when a network exists" heartbeat.
  Future<void> schedulePeriodic({
    Duration frequency = minimumPeriodicFrequency,
  }) async {
    if (!isSupported) return;
    final Duration safeFrequency =
        frequency < minimumPeriodicFrequency ? minimumPeriodicFrequency : frequency;
    try {
      await Workmanager().registerPeriodicTask(
        uniquePeriodicName,
        periodicTaskName,
        frequency: safeFrequency,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (error) {
      debugPrint('BackgroundSyncScheduler: periodic task failed ($error)');
    }
  }

  /// Fired when the app goes to the background after a change, to give the
  /// upload a chance to finish without the user waiting in-app.
  Future<void> scheduleOneOff({
    Duration initialDelay = const Duration(seconds: 10),
  }) async {
    if (!isSupported) return;
    try {
      await Workmanager().registerOneOffTask(
        uniqueOneOffName,
        oneOffTaskName,
        initialDelay: initialDelay,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    } catch (error) {
      debugPrint('BackgroundSyncScheduler: one-off task failed ($error)');
    }
  }

  Future<void> cancelAll() async {
    if (!isSupported) return;
    try {
      await Workmanager().cancelByUniqueName(uniquePeriodicName);
      await Workmanager().cancelByUniqueName(uniqueOneOffName);
    } catch (error) {
      debugPrint('BackgroundSyncScheduler: cancel failed ($error)');
    }
  }
}

/// Entry point executed by the OS in a *fresh isolate*.
///
/// The service locator is rebuilt here on purpose: an isolate does not share
/// memory with the UI isolate, so nothing registered at app start exists yet.
@pragma('vm:entry-point')
void syncCallbackDispatcher() {
  Workmanager().executeTask((String task, Map<String, dynamic>? inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await setUpServiceLocator();
      await sl<AppDatabase>().init();
      await sl<LocalFileStorage>().init();

      await sl<SyncManager>().sync(trigger: SyncTrigger.background);
      return true;
    } catch (error) {
      debugPrint('syncCallbackDispatcher: sync failed ($error)');
      // Returning false lets the OS retry later with the same work policy.
      return false;
    }
  });
}
