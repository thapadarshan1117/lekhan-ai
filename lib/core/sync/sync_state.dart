import 'package:equatable/equatable.dart';
import 'package:lekhan_ai/core/constants/storage_constants.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';

/// Everything the global indicator and the sync centre need, in one immutable
/// value. Presentation layers can `switch` on [status] without touching the
/// queue.
class SyncState extends Equatable {
  const SyncState({
    this.status = SyncConnectionStatus.unknown,
    this.isSyncing = false,
    this.trigger,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.completedCount = 0,
    this.activeTask,
    this.activeProgress,
    this.lastSyncedAt,
    this.message,
    this.updatedAt,
  });

  const SyncState.initial() : this();

  final SyncConnectionStatus status;

  final bool isSyncing;
  final SyncTrigger? trigger;

  final int pendingCount;
  final int failedCount;
  final int completedCount;

  /// Task currently being executed, if any.
  final SyncTask? activeTask;

  /// 0..1 for [activeTask].
  final double? activeProgress;

  final DateTime? lastSyncedAt;

  /// Why the engine is idle/offline, when there is something worth saying.
  final String? message;

  final DateTime? updatedAt;

  // ---------------------------------------------------------------------------
  // Derived UI copy
  // ---------------------------------------------------------------------------

  /// Text for the header indicator.
  String get headline {
    switch (status) {
      case SyncConnectionStatus.synced:
        return 'Synced';
      case SyncConnectionStatus.waiting:
        return pendingCount == 1
            ? '1 item waiting to sync'
            : '$pendingCount items waiting to sync';
      case SyncConnectionStatus.syncing:
        return pendingCount > 1 ? 'Syncing $pendingCount files' : 'Syncing';
      case SyncConnectionStatus.offline:
        return 'Offline';
      case SyncConnectionStatus.attentionRequired:
        return failedCount == 1
            ? '1 item needs attention'
            : '$failedCount items need attention';
      case SyncConnectionStatus.unknown:
        return 'Sync status unknown';
    }
  }

  /// Secondary line, e.g. "Stored safely on device".
  String get subtitle {
    if (status == SyncConnectionStatus.offline) {
      return pendingCount == 0
          ? 'Working offline'
          : 'Stored safely on device - will upload automatically';
    }
    if (status == SyncConnectionStatus.attentionRequired) {
      return message ?? 'Something could not be uploaded.';
    }
    if (status == SyncConnectionStatus.waiting) {
      return message ?? 'Sync will resume automatically.';
    }
    if (isSyncing && activeTask != null) {
      final double? progress = activeProgress;
      if (progress == null) return 'Preparing ${_nameOf(activeTask!)}';
      return '${_nameOf(activeTask!)} ${(progress * 100).round()}%';
    }
    if (pendingCount > 0) {
      return pendingCount == 1
          ? '1 item waiting to sync'
          : '$pendingCount items waiting to sync';
    }
    return lastSyncedAt == null ? 'Up to date' : 'All changes saved';
  }

  static String _nameOf(SyncTask task) {
    final dynamic name = task.payload?['name'];
    if (name is String && name.isNotEmpty) return name;
    return task.entityType.value;
  }

  SyncState copyWith({
    SyncConnectionStatus? status,
    bool? isSyncing,
    SyncTrigger? trigger,
    int? pendingCount,
    int? failedCount,
    int? completedCount,
    SyncTask? activeTask,
    double? activeProgress,
    DateTime? lastSyncedAt,
    String? message,
    DateTime? updatedAt,
    bool clearActiveTask = false,
    bool clearMessage = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      isSyncing: isSyncing ?? this.isSyncing,
      trigger: trigger ?? this.trigger,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      completedCount: completedCount ?? this.completedCount,
      activeTask: clearActiveTask ? null : (activeTask ?? this.activeTask),
      activeProgress:
          clearActiveTask ? null : (activeProgress ?? this.activeProgress),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: clearMessage ? null : (message ?? this.message),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        isSyncing,
        trigger,
        pendingCount,
        failedCount,
        completedCount,
        activeTask,
        activeProgress,
        lastSyncedAt,
        message,
        updatedAt,
      ];
}

/// User controlled sync rules (settings screen, later).
///
/// Every value lives in [StorageService], so the UI and the background isolate
/// read the same truth.
class SyncPreferences {
  const SyncPreferences({required this.storageService});

  final StorageService storageService;

  Future<bool> get wifiOnly => _readBool(
        StorageConstants.syncWifiOnlyKey,
        StorageConstants.defaultSyncWifiOnly,
      );

  Future<bool> get chargingOnly => _readBool(
        StorageConstants.syncChargingOnlyKey,
        StorageConstants.defaultSyncChargingOnly,
      );

  Future<bool> get backgroundEnabled => _readBool(
        StorageConstants.backgroundSyncEnabledKey,
        StorageConstants.defaultBackgroundSyncEnabled,
      );

  Future<int> get maxParallelUploads async {
    final Object? raw = await storageService.get(
      StorageConstants.maxParallelUploadsKey,
    );
    final int? value = int.tryParse(raw?.toString() ?? '');
    if (value == null || value < 1) {
      return StorageConstants.defaultMaxParallelUploads;
    }
    return value;
  }

  Future<void> setWifiOnly(bool value) =>
      _writeBool(StorageConstants.syncWifiOnlyKey, value);

  Future<void> setChargingOnly(bool value) =>
      _writeBool(StorageConstants.syncChargingOnlyKey, value);

  Future<void> setBackgroundEnabled(bool value) =>
      _writeBool(StorageConstants.backgroundSyncEnabledKey, value);

  Future<void> setMaxParallelUploads(int value) async {
    await storageService.set(
      StorageConstants.maxParallelUploadsKey,
      value.toString(),
    );
  }

  Future<bool> _readBool(String key, bool fallback) async {
    final Object? raw = await storageService.get(key);
    if (raw == null) return fallback;
    if (raw is bool) return raw;
    final String needle = raw.toString().trim().toLowerCase();
    if (needle == 'true' || needle == '1') return true;
    if (needle == 'false' || needle == '0') return false;
    return fallback;
  }

  Future<void> _writeBool(String key, bool value) async {
    await storageService.set(key, value.toString());
  }
}

/// Records the last successful sync so the sync centre can say
/// "Last synced: today, 1:42 PM".
class SyncCheckpointStore {
  const SyncCheckpointStore({required this.storageService});

  final StorageService storageService;

  Future<DateTime?> lastSyncedAt() async {
    final Object? raw = await storageService.get(
      StorageConstants.lastSyncedAtKey,
    );
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  Future<void> markSynced([DateTime? at]) {
    return storageService.set(
      StorageConstants.lastSyncedAtKey,
      (at ?? DateTime.now()).toIso8601String(),
    );
  }

  Future<String?> lastError() async {
    final Object? raw = await storageService.get(
      StorageConstants.lastSyncErrorKey,
    );
    return raw?.toString();
  }

  Future<void> setLastError(String? message) {
    if (message == null) {
      return storageService.remove(StorageConstants.lastSyncErrorKey);
    }
    return storageService.set(StorageConstants.lastSyncErrorKey, message);
  }
}
