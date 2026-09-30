import 'package:equatable/equatable.dart';
import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';

/// One unit of work waiting to reach the backend.
///
/// A task is created the moment the user changes something locally, before any
/// network call is attempted. That is what makes the write path offline-first:
/// the local database and the file store are updated first, and this record is
/// the promise that the server will be told about it later.
class SyncTask extends Equatable {
  const SyncTask({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.remoteId,
    this.payload,
    this.status = SyncStatus.pending,
    this.attemptCount = 0,
    this.maxAttempts = 5,
    this.priority = SyncPriority.p0,
    this.totalBytes,
    this.bytesUploaded,
    this.progress,
    this.lastAttemptAt,
    this.nextRetryAt,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final SyncEntityType entityType;

  /// Local id of the affected record (never the remote one).
  final String entityId;

  final SyncOperation operation;

  /// Server id, when the record already exists remotely.
  final String? remoteId;

  /// Everything the handler needs. Also the payload for `/sync/push`.
  final Map<String, dynamic>? payload;

  final SyncStatus status;
  final int attemptCount;
  final int maxAttempts;
  final SyncPriority priority;

  /// Size of the file involved, when the task moves bytes.
  final int? totalBytes;
  final int? bytesUploaded;

  /// 0..1 while uploading; null for metadata tasks.
  final double? progress;

  final DateTime? lastAttemptAt;
  final DateTime? nextRetryAt;
  final String? errorMessage;

  final DateTime createdAt;
  final DateTime updatedAt;

  // ---------------------------------------------------------------------------
  // Derived state
  // ---------------------------------------------------------------------------

  bool get canRetry => attemptCount < maxAttempts;

  bool get isUpload => operation == SyncOperation.uploadFile;

  bool get isLargeTransfer {
    if (priority.isHeavy) return true;
    return (totalBytes ?? 0) >= 25 * 1024 * 1024;
  }

  /// True when the task is due (or overdue) at [now].
  bool isDue(DateTime now) =>
      status == SyncStatus.pending &&
      (nextRetryAt == null || !nextRetryAt!.isAfter(now));

  /// Exponential backoff with a ceiling, so a flaky network does not spin.
  Duration get backoff {
    const int baseSeconds = 20;
    const int maxSeconds = 60 * 60; // 1 hour
    final int exponent = attemptCount < 1 ? 1 : attemptCount;
    final int seconds = baseSeconds * (1 << (exponent - 1).clamp(0, 8));
    return Duration(seconds: seconds.clamp(baseSeconds, maxSeconds));
  }

  /// Sort key used by the queue: urgency first, then age.
  int get orderKey => priority.index;

  // ---------------------------------------------------------------------------
  // Transitions
  // ---------------------------------------------------------------------------

  SyncTask onStarted(DateTime now) {
    return copyWith(
      status: SyncStatus.inProgress,
      lastAttemptAt: now,
      updatedAt: now,
    );
  }

  SyncTask onSucceeded(DateTime now, {String? remoteId, double? progress}) {
    return SyncTask(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      remoteId: remoteId ?? this.remoteId,
      payload: payload,
      status: SyncStatus.completed,
      attemptCount: attemptCount,
      maxAttempts: maxAttempts,
      priority: priority,
      totalBytes: totalBytes,
      bytesUploaded: totalBytes ?? bytesUploaded,
      progress: progress ?? 1,
      lastAttemptAt: lastAttemptAt,
      nextRetryAt: null,
      errorMessage: null,
      createdAt: createdAt,
      updatedAt: now,
    );
  }

  SyncTask onFailed(
    String error,
    DateTime now, {
    Duration? retryAfter,
    bool permanent = false,
  }) {
    final int nextAttempt = attemptCount + 1;
    final bool exhausted = permanent || nextAttempt >= maxAttempts;
    return SyncTask(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      remoteId: remoteId,
      payload: payload,
      status: SyncStatus.failed,
      attemptCount: nextAttempt,
      maxAttempts: maxAttempts,
      priority: priority,
      totalBytes: totalBytes,
      bytesUploaded: bytesUploaded,
      progress: progress,
      lastAttemptAt: now,
      nextRetryAt: exhausted
          ? null
          : now.add(retryAfter ?? backoff),
      errorMessage: error,
      createdAt: createdAt,
      updatedAt: now,
    );
  }

  /// Parks the task without counting it as a failure (offline, waiting for
  /// Wi-Fi, waiting for charging, ...).
  SyncTask onDeferred(DateTime now, {Duration delay = const Duration(minutes: 15)}) {
    return copyWith(
      status: SyncStatus.pending,
      nextRetryAt: now.add(delay),
      updatedAt: now,
    );
  }

  SyncTask withProgress(double value, {int? bytesUploaded}) {
    final double clamped = value.isNaN ? 0 : value.clamp(0, 1).toDouble();
    return copyWith(
      progress: clamped,
      bytesUploaded: bytesUploaded ?? this.bytesUploaded,
    );
  }

  SyncTask copyWith({
    String? id,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperation? operation,
    String? remoteId,
    Map<String, dynamic>? payload,
    SyncStatus? status,
    int? attemptCount,
    int? maxAttempts,
    SyncPriority? priority,
    int? totalBytes,
    int? bytesUploaded,
    double? progress,
    DateTime? lastAttemptAt,
    DateTime? nextRetryAt,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncTask(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      remoteId: remoteId ?? this.remoteId,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      priority: priority ?? this.priority,
      totalBytes: totalBytes ?? this.totalBytes,
      bytesUploaded: bytesUploaded ?? this.bytesUploaded,
      progress: progress ?? this.progress,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'entity_type': entityType.value,
      'entity_id': entityId,
      'remote_id': remoteId,
      'operation': operation.value,
      'payload': payload,
      'status': status.value,
      'attempt_count': attemptCount,
      'max_attempts': maxAttempts,
      'priority': priority.index,
      'total_bytes': totalBytes,
      'bytes_uploaded': bytesUploaded,
      'progress': progress,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
      'next_retry_at': nextRetryAt?.toIso8601String(),
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SyncTask.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = JsonUtils.asMap(json);
    final DateTime created =
        JsonUtils.asDateTime(data['created_at']) ?? DateTime.now();

    return SyncTask(
      id: JsonUtils.asString(data['id']),
      entityType: SyncEntityType.fromString(
        JsonUtils.asStringOrNull(data['entity_type']),
      ),
      entityId: JsonUtils.asString(data['entity_id']),
      operation: SyncOperation.fromString(
        JsonUtils.asStringOrNull(data['operation']),
      ),
      remoteId: JsonUtils.asStringOrNull(data['remote_id']),
      payload: JsonUtils.asMapOrNull(data['payload']),
      status: SyncStatus.fromString(JsonUtils.asStringOrNull(data['status'])),
      attemptCount: JsonUtils.asInt(data['attempt_count']),
      maxAttempts: JsonUtils.asInt(data['max_attempts'], fallback: 5),
      priority: SyncPriority.fromIndex(JsonUtils.asInt(data['priority'])),
      totalBytes: JsonUtils.asIntOrNull(data['total_bytes']),
      bytesUploaded: JsonUtils.asIntOrNull(data['bytes_uploaded']),
      progress: JsonUtils.asDoubleOrNull(data['progress']),
      lastAttemptAt: JsonUtils.asDateTime(data['last_attempt_at']),
      nextRetryAt: JsonUtils.asDateTime(data['next_retry_at']),
      errorMessage: JsonUtils.asStringOrNull(data['error_message']),
      createdAt: created,
      updatedAt: JsonUtils.asDateTime(data['updated_at']) ?? created,
    );
  }

  /// Shape sent to `POST /sync/push`.
  Map<String, dynamic> toChangeJson() {
    return <String, dynamic>{
      'local_id': entityId,
      if (remoteId != null) 'remote_id': remoteId,
      'entity_type': entityType.value,
      'operation': operation.value,
      'payload': payload ?? <String, dynamic>{},
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        entityType,
        entityId,
        operation,
        remoteId,
        status,
        attemptCount,
        maxAttempts,
        priority,
        totalBytes,
        bytesUploaded,
        progress,
        lastAttemptAt,
        nextRetryAt,
        errorMessage,
        createdAt,
        updatedAt,
      ];
}
