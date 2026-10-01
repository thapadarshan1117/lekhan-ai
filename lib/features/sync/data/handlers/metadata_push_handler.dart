import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/sync/sync_worker.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/sync/data/datasources/sync_remote_datasource.dart';
import 'package:lekhan_ai/features/sync/data/services/sync_entity_applier.dart';
import 'package:lekhan_ai/features/sync/data/services/sync_reference_resolver.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Pushes one metadata change and writes the server's answer back into the
/// local store.
///
/// One task per request on purpose: the queue already executes tasks one at a
/// time, so a batch would only add failure modes without adding throughput.
/// (Batching several changes into one `/sync/push` call is a later
/// optimisation, and the API already accepts an array.)
class MetadataPushService {
  const MetadataPushService({
    required this.remote,
    required this.resolver,
    required this.applier,
  });

  final SyncRemoteDataSource remote;
  final SyncReferenceResolver resolver;
  final SyncEntityApplier applier;

  Future<SyncOutcome> push(SyncTask task) async {
    final Map<String, dynamic> payload = Map<String, dynamic>.of(
      task.payload ?? const <String, dynamic>{},
    );
    final Map<String, dynamic> data = payload['data'] is Map
        ? JsonUtils.asMap(payload['data'])
        : Map<String, dynamic>.of(payload);
    final DateTime? localVersion =
        JsonUtils.asDateTime(payload['local_updated_at']);
    data.remove('local_updated_at');

    Map<String, dynamic> resolvedData = data;
    if (task.operation != SyncOperation.delete) {
      // Local ids -> remote ids for every parent reference in the payload.
      final Either<AppException, Map<String, dynamic>> resolved =
          await resolver.resolve(
        entityType: task.entityType,
        entityId: task.entityId,
        data: data,
      );

      final Map<String, dynamic>? value = resolved.valueOrNull;
      if (value == null) {
        // Most commonly "the parent has not been pushed yet": retryable, and
        // P0 ordering puts metadata ahead of file bytes.
        return SyncOutcome.failure(
          resolved.errorOrNull?.message ?? 'This change could not be prepared.',
        );
      }
      resolvedData = value;
    }

    final String? remoteId = task.remoteId ??
        await resolver.selfRemoteId(
          entityType: task.entityType,
          entityId: task.entityId,
        );

    final Map<String, dynamic> change = <String, dynamic>{
      'local_id': task.entityId,
      if (remoteId != null && remoteId.isNotEmpty) 'remote_id': remoteId,
      'entity_type': task.entityType.value,
      'operation': task.operation.value,
      'payload': resolvedData,
    };

    final Either<AppException, SyncPushResponse> pushed =
        await remote.pushChanges(changes: <Map<String, dynamic>>[change]);

    final SyncPushResponse? response = pushed.valueOrNull;
    if (response == null) {
      return SyncOutcome.failure(
        pushed.errorOrNull?.message ?? 'The change could not be sent.',
      );
    }

    final SyncChangeResult? result = response.resultFor(task.entityId);
    if (result == null) {
      return const SyncOutcome.failure(
        'The server did not confirm that this change was saved.',
      );
    }
    if (!result.isAccepted) {
      return SyncOutcome.failure(
        result.error ??
            (result.isConflict
                ? 'This item changed on another device. It will be retried safely.'
                : 'The server rejected this change.'),
      );
    }

    if (task.operation == SyncOperation.delete) {
      await applier.applyRemoteDelete(
        entityType: task.entityType,
        entityId: task.entityId,
      );
      return const SyncOutcome.success();
    }

    final String? assignedRemoteId = result.remoteId ?? remoteId;
    if ((task.operation == SyncOperation.create || remoteId == null) &&
        (assignedRemoteId == null || assignedRemoteId.isEmpty)) {
      return const SyncOutcome.failure(
        'The server accepted the change but did not return its record id.',
      );
    }

    await applier.markSynced(
      entityType: task.entityType,
      entityId: task.entityId,
      remoteId: assignedRemoteId,
      expectedUpdatedAt: localVersion,
    );

    return SyncOutcome.success(remoteId: assignedRemoteId);
  }
}

/// Base class for the metadata handlers: they all do the same thing, only the
/// entity type differs.
abstract class MetadataPushHandler extends SyncTaskHandler {
  const MetadataPushHandler({required this.service});

  final MetadataPushService service;

  @override
  Set<SyncOperation> get supportedOperations => const <SyncOperation>{
        SyncOperation.create,
        SyncOperation.update,
        SyncOperation.delete,
      };

  @override
  Future<SyncOutcome> handle(SyncTask task) => service.push(task);
}

class ProjectPushHandler extends MetadataPushHandler {
  const ProjectPushHandler({required super.service});

  @override
  SyncEntityType get entityType => SyncEntityType.project;
}

class BookPushHandler extends MetadataPushHandler {
  const BookPushHandler({required super.service});

  @override
  SyncEntityType get entityType => SyncEntityType.book;
}

class ChapterPushHandler extends MetadataPushHandler {
  const ChapterPushHandler({required super.service});

  @override
  SyncEntityType get entityType => SyncEntityType.chapter;
}

class ChapterSourceMetadataPushHandler extends MetadataPushHandler {
  const ChapterSourceMetadataPushHandler({required super.service});

  @override
  SyncEntityType get entityType => SyncEntityType.chapterSource;
}

/// Word counts travel on their own channel so a busy writer never queues a
/// full chapter update just to save a number.
class ProgressPushHandler extends MetadataPushHandler {
  const ProgressPushHandler({required super.service});

  @override
  SyncEntityType get entityType => SyncEntityType.progress;

  @override
  Set<SyncOperation> get supportedOperations => const <SyncOperation>{
        SyncOperation.update,
      };
}
