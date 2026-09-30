import 'package:lekhan_ai/core/enums/source_type.dart';

/// Lifecycle of a queued unit of work.
enum SyncStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const SyncStatus(this.value);

  final String value;

  static SyncStatus fromString(String? raw) {
    if (raw == null) return SyncStatus.pending;
    final String needle = raw.trim().toLowerCase();
    for (final SyncStatus status in SyncStatus.values) {
      if (status.value == needle) return status;
    }
    return SyncStatus.pending;
  }

  bool get isOpen =>
      this == SyncStatus.pending || this == SyncStatus.inProgress;

  bool get isSettled =>
      this == SyncStatus.completed || this == SyncStatus.cancelled;
}

/// Scheduling weight of a queued unit of work.
///
/// Smaller index == more urgent. Metadata always travels before bytes so that
/// the server can create the record the file will be attached to.
enum SyncPriority {
  /// Critical metadata (project / book / chapter / source records).
  p0,

  /// Small documents (pdf, docx, txt).
  p1,

  /// Images and scans.
  p2,

  /// Audio.
  p3,

  /// Video (largest, uploaded when the network is suitable).
  p4;

  static SyncPriority fromIndex(int index) {
    if (index < 0 || index >= SyncPriority.values.length) {
      return SyncPriority.p0;
    }
    return SyncPriority.values[index];
  }

  /// Weight a source file of [type] should be queued with.
  static SyncPriority forSourceType(SourceType type) {
    switch (type) {
      case SourceType.document:
        return SyncPriority.p1;
      case SourceType.image:
        return SyncPriority.p2;
      case SourceType.audio:
      case SourceType.recording:
        return SyncPriority.p3;
      case SourceType.video:
        return SyncPriority.p4;
    }
  }

  String get label {
    switch (this) {
      case SyncPriority.p0:
        return 'Metadata';
      case SyncPriority.p1:
        return 'Document';
      case SyncPriority.p2:
        return 'Image';
      case SyncPriority.p3:
        return 'Audio';
      case SyncPriority.p4:
        return 'Video';
    }
  }

  /// True for the two heaviest classes, used by the Wi-Fi / charging rules.
  bool get isHeavy => this == SyncPriority.p3 || this == SyncPriority.p4;
}

/// What woke the sync engine up. Useful in logs and in the sync centre.
enum SyncTrigger {
  appStartup('app_startup'),
  networkRestored('network_restored'),
  background('background'),
  manual('manual'),
  push('push');

  const SyncTrigger(this.value);

  final String value;
}

/// Overall health of the sync engine, i.e. what the global indicator shows.
enum SyncConnectionStatus {
  /// Engine idle and everything is on the server.
  synced,

  /// Transfer in progress.
  syncing,

  /// No usable connection; work is parked locally.
  offline,

  /// There is a connection, but the work is deliberately parked: waiting for
  /// Wi-Fi, for a backoff window, or for recharge.
  waiting,

  /// Something failed and needs a user decision.
  attentionRequired,

  /// Engine has not produced a verdict yet.
  unknown;

  bool get isBusy => this == SyncConnectionStatus.syncing;
}
