import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/utils/id_generator.dart';

/// Builds [SyncTask]s so repositories do not have to hand-assemble JSON keys.
class SyncTaskBuilder {
  const SyncTaskBuilder._();

  /// A metadata change (create / update / delete of a structural record).
  static SyncTask metadata({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
    String? remoteId,
    Map<String, dynamic>? payload,
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    return SyncTask(
      id: IdGenerator.taskId(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      remoteId: remoteId,
      payload: payload,
      priority: SyncPriority.p0,
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  /// A file that has to move from the device to the backend.
  static SyncTask upload({
    required String sourceId,
    required String chapterId,
    required String sourceName,
    required SourceType sourceType,
    required int sizeBytes,
    String? remoteId,
    String? remoteFileId,
    Map<String, dynamic>? extra,
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    return SyncTask(
      id: IdGenerator.taskId(),
      entityType: SyncEntityType.chapterSource,
      entityId: sourceId,
      operation: SyncOperation.uploadFile,
      remoteId: remoteId,
      totalBytes: sizeBytes,
      progress: 0,
      priority: SyncPriority.forSourceType(sourceType),
      payload: <String, dynamic>{
        'name': sourceName,
        'chapter_id': chapterId,
        'source_type': sourceType.value,
        'size_bytes': sizeBytes,
        if (remoteFileId != null) 'remote_file_id': remoteFileId,
        ...?extra,
      },
      createdAt: stamp,
      updatedAt: stamp,
    );
  }

  /// Reading progress / word counts, batched separately from structure.
  static SyncTask progress({
    required String chapterId,
    required int currentWords,
    String? remoteId,
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    return SyncTask(
      id: IdGenerator.taskId(),
      entityType: SyncEntityType.progress,
      entityId: chapterId,
      operation: SyncOperation.update,
      remoteId: remoteId,
      priority: SyncPriority.p0,
      payload: <String, dynamic>{'current_words': currentWords},
      createdAt: stamp,
      updatedAt: stamp,
    );
  }
}
