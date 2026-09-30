import 'dart:async';

import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/enums/upload_status.dart';
import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/sync/sync_worker.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/chapters/data/datasources/local/chapter_local_datasource.dart';
import 'package:lekhan_ai/features/chapters/data/models/chapter_model.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/repositories/chapter_source_repository.dart';
import 'package:lekhan_ai/features/upload/data/services/resumable_uploader.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Moves the bytes of one queued source, resuming where it stopped.
///
/// Order of work:
///  1. the chapter must already exist on the server (metadata is P0, so it runs
///     first; if it is genuinely missing the task fails and is retried),
///  2. the upload session is opened (or resumed) and chunks are sent,
///  3. the source record is marked uploaded with the Drive file id, which is the
///     moment the UI stops saying "waiting to upload".
class SourceUploadHandler extends SyncTaskHandler {
  SourceUploadHandler({
    required this.uploader,
    required this.sourceRepository,
    required this.chapterLocal,
    required this.queue,
  });

  final ResumableUploader uploader;
  final ChapterSourceRepository sourceRepository;
  final ChapterLocalDataSource chapterLocal;
  final SyncQueue queue;

  @override
  SyncEntityType get entityType => SyncEntityType.chapterSource;

  @override
  Set<SyncOperation> get supportedOperations => const <SyncOperation>{
        SyncOperation.uploadFile,
      };

  @override
  Future<SyncOutcome> handle(SyncTask task) async {
    final Either<AppException, ChapterSource> found =
        await sourceRepository.getSource(task.entityId);
    final ChapterSource? source = found.valueOrNull;

    if (source == null) {
      // The user deleted it while it was queued: nothing to do, and not an
      // error worth showing.
      return const SyncOutcome.success(message: 'Source no longer exists.');
    }

    if (source.isUploaded) {
      return SyncOutcome.success(remoteId: source.remoteId);
    }

    final Either<AppException, ChapterModel?> chapterResult =
        await chapterLocal.getChapter(source.chapterId);
    final String? chapterRemoteId = chapterResult.valueOrNull?.remoteId;

    if (chapterRemoteId == null || chapterRemoteId.isEmpty) {
      return const SyncOutcome.failure(
        'Waiting for the chapter to be saved on the server.',
      );
    }

    await sourceRepository.updateUploadStatus(
      source.id,
      uploadStatus: UploadStatus.uploading,
      clearError: true,
    );
    await queue.updateProgress(task.id, 0);

    int lastReportedPercent = -1;

    final Either<AppException, UploadRunResult> run = await uploader.run(
      source: source,
      chapterRemoteId: chapterRemoteId,
      onProgress: (double progress, int bytesSent) {
        final int percent = (progress * 100).floor();
        if (percent == lastReportedPercent) return;
        lastReportedPercent = percent;

        // Fire-and-forget: progress must never slow the transfer down, and
        // losing one update is harmless (the next one overwrites it).
        unawaited(
          sourceRepository.updateUploadStatus(
            source.id,
            uploadStatus: UploadStatus.uploading,
            uploadProgress: progress,
          ),
        );
        unawaited(
          queue.updateProgress(task.id, progress, bytesUploaded: bytesSent),
        );
      },
    );

    final UploadRunResult? result = run.valueOrNull;

    if (result == null) {
      final String message =
          run.errorOrNull?.message ?? 'The upload could not be completed.';
      await sourceRepository.updateUploadStatus(
        source.id,
        uploadStatus: UploadStatus.failed,
        errorMessage: message,
      );
      return SyncOutcome.failure(message);
    }

    if (!result.completed) {
      // Session expired or dropped mid-flight: retryable by design, the next
      // run opens a fresh session and resumes from the last offset.
      return const SyncOutcome.failure(
        'The upload was interrupted and will resume automatically.',
      );
    }

    await sourceRepository.updateUploadStatus(
      source.id,
      uploadStatus: UploadStatus.uploaded,
      uploadProgress: 1,
      remoteId: result.remoteSourceId,
      remoteFileId: result.remoteFileId,
      driveFileId: result.driveFileId,
      clearError: true,
    );

    return SyncOutcome.success(
      remoteId: result.remoteSourceId ?? source.remoteId,
      progress: 1,
    );
  }
}
