import 'dart:io';

import 'package:lekhan_ai/core/constants/file_constants.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/core/utils/id_generator.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/upload/data/datasources/local/upload_session_local_datasource.dart';
import 'package:lekhan_ai/features/upload/data/datasources/remote/upload_remote_datasource.dart';
import 'package:lekhan_ai/features/upload/data/models/upload_session_model.dart';
import 'package:lekhan_ai/features/upload/domain/entities/upload_run_result.dart';
import 'package:lekhan_ai/features/upload/domain/entities/upload_session.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';



/// Moves a file to the backend in chunks, resuming from the last acknowledged
/// offset.
///
/// Behaviour that matters for a 500 MB video on a phone:
///  * a chunk that fails does **not** roll back the session: the offset stays,
///    the exception travels up, the sync task is retried later with backoff and
///    the next run starts where the previous one stopped;
///  * an expired session (404/410) is reported, not silently restarted;
///  * progress is reported per chunk and within a chunk, so the UI can show a
///    real percentage.
class ResumableUploader {
  ResumableUploader({required this.remote, required this.sessions});

  final UploadRemoteDataSource remote;
  final UploadSessionLocalDataSource sessions;

  static const String _identifier = 'ResumableUploader';

  Future<Either<AppException, UploadRunResult>> run({
    required ChapterSource source,
    required String chapterRemoteId,
    UploadProgressCallback? onProgress,
  }) async {
    if (chapterRemoteId.isEmpty) {
      return Left<AppException, UploadRunResult>(
        AppException(
          message: 'Waiting for the chapter to be created on the server.',
          statusCode: LocalErrorCodes.localFailure,
          identifier: '$_identifier.run.chapterNotSynced',
        ),
      );
    }

    final File file = File(source.localPath);
    if (!await file.exists()) {
      return Left<AppException, UploadRunResult>(
        AppException(
          message: 'The file is no longer on this device.',
          statusCode: LocalErrorCodes.notFound,
          identifier: '$_identifier.run.fileMissing',
        ),
      );
    }

    final int totalBytes = source.fileSize > 0
        ? source.fileSize
        : await file.length();

    if (totalBytes <= 0) {
      return Left<AppException, UploadRunResult>(
        AppException(
          message: 'The file is empty and was not uploaded.',
          statusCode: LocalErrorCodes.invalidPayload,
          identifier: '$_identifier.run.emptyFile',
        ),
      );
    }

    UploadSessionModel session = await _loadOrCreateSession(
      source: source,
      totalBytes: totalBytes,
    );

    // A session that is expired (or failed hard) is re-initiated once, so the
    // user never has to think about it.
    if (!session.isResumable) {
      session = await _initiate(
        source: source,
        chapterRemoteId: chapterRemoteId,
        totalBytes: totalBytes,
      );
    }

    while (session.bytesUploaded < totalBytes) {
      final Either<AppException, UploadChunkResult> pushed = await remote.pushChunk(
        uploadUrl: session.uploadUrl ?? '',
        method: session.method,
        file: file,
        offset: session.bytesUploaded,
        totalBytes: totalBytes,
        chunkSize: session.chunkSize,
        onProgress: (int sent, int total) {
          final int absolute = session.bytesUploaded + sent;
          if (onProgress != null) {
            onProgress(
              totalBytes == 0 ? 0 : absolute / totalBytes,
              absolute,
            );
          }
        },
      );

      final UploadChunkResult? chunk = pushed.valueOrNull;

      if (chunk == null) {
        final AppException error = pushed.errorOrNull ??
            FailureMapper.local(
              StateError('Chunk upload failed'),
              identifier: '$_identifier.run.pushChunk',
            );
        final UploadSessionModel failed = session.copyWith(
          status: UploadSessionStatus.failed,
          errorMessage: error.message,
          attemptCount: session.attemptCount + 1,
          updatedAt: DateTime.now(),
        );
        await sessions.save(failed);
        return Left<AppException, UploadRunResult>(error);
      }

      if (chunk.expired) {
        final UploadSessionModel expired = session.reset(
          now: DateTime.now(),
          status: UploadSessionStatus.expired,
        );
        await sessions.save(expired);
        return Right<AppException, UploadRunResult>(
          UploadRunResult(
            session: expired,
            completed: false,
            expiredSession: true,
          ),
        );
      }

      session = session.copyWith(
        bytesUploaded: chunk.offset,
        status: chunk.completed
            ? UploadSessionStatus.completing
            : UploadSessionStatus.active,
        remoteFileId: chunk.remoteFileId,
        driveFileId: chunk.driveFileId,
        clearError: true,
        updatedAt: DateTime.now(),
      );
      await sessions.save(session);

      if (onProgress != null) {
        onProgress(session.progress, session.bytesUploaded);
      }

      if (chunk.completed) break;
    }

    // Finalise on the server: this is where the Drive file id and the
    // ingestion job are produced.
    final String uploadId = session.uploadId ?? '';
    if (uploadId.isEmpty) {
      return Left<AppException, UploadRunResult>(
        FailureMapper.local(
          StateError('Upload session has no server id'),
          identifier: '$_identifier.run.missingUploadId',
          statusCode: LocalErrorCodes.syncFailure,
        ),
      );
    }

    final Either<AppException, UploadCompletion> completed =
        await remote.completeSession(uploadId: uploadId, checksum: source.checksum);

    final UploadCompletion? completion = completed.valueOrNull;

    if (completion == null) {
      final AppException error = completed.errorOrNull ??
          FailureMapper.local(
            StateError('Upload could not be completed'),
            identifier: '$_identifier.run.complete',
          );
      await sessions.save(
        session.copyWith(
          status: UploadSessionStatus.failed,
          errorMessage: error.message,
          updatedAt: DateTime.now(),
        ),
      );
      return Left<AppException, UploadRunResult>(error);
    }

    final UploadSessionModel finished = session.copyWith(
      status: UploadSessionStatus.completed,
      bytesUploaded: totalBytes,
      remoteFileId: completion.remoteFileId ?? session.remoteFileId,
      driveFileId: completion.driveFileId ?? session.driveFileId,
      clearError: true,
      updatedAt: DateTime.now(),
    );
    await sessions.save(finished);

    return Right<AppException, UploadRunResult>(
      UploadRunResult(
        session: finished,
        completed: true,
        remoteSourceId: completion.remoteSourceId,
        remoteFileId: finished.remoteFileId,
        driveFileId: finished.driveFileId,
        processingStatus: completion.processingStatus,
      ),
    );
  }

  /// Forgets the session of a source (used when the user cancels or deletes).
  Future<void> cancel(String sourceId) async {
    final Either<AppException, UploadSessionModel?> found =
        await sessions.getBySource(sourceId);
    final UploadSessionModel? session = found.valueOrNull;
    if (session == null) return;

    final String? uploadId = session.uploadId;
    if (uploadId != null && uploadId.isNotEmpty) {
      await remote.cancelSession(uploadId);
    }
    await sessions.delete(session.id);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<UploadSessionModel> _loadOrCreateSession({
    required ChapterSource source,
    required int totalBytes,
  }) async {
    final Either<AppException, UploadSessionModel?> existing =
        await sessions.getBySource(source.id);

    final UploadSessionModel? session = existing.valueOrNull;
    if (session != null) return session;

    final DateTime now = DateTime.now();
    final UploadSessionModel fresh = UploadSessionModel(
      id: IdGenerator.newId('ups'),
      sourceId: source.id,
      chapterId: source.chapterId,
      totalBytes: totalBytes,
      chunkSize: FileConstants.uploadChunkSizeBytes,
      status: UploadSessionStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
    await sessions.save(fresh);
    return fresh;
  }

  Future<UploadSessionModel> _initiate({
    required ChapterSource source,
    required String chapterRemoteId,
    required int totalBytes,
  }) async {
    final SourceType type = source.sourceType;
    final Either<AppException, UploadInitiation> initiated =
        await remote.initiateSession(
      sourceLocalId: source.id,
      chapterRemoteId: chapterRemoteId,
      name: source.name,
      mimeType: source.mimeType,
      sizeBytes: totalBytes,
      checksum: source.checksum,
      sourceType: type.value,
    );

    final UploadInitiation? initiation = initiated.valueOrNull;
    final DateTime now = DateTime.now();

    if (initiation == null) {
      // Keep the (possibly stale) session so the next attempt can retry.
      final Either<AppException, UploadSessionModel?> existing =
          await sessions.getBySource(source.id);
      final UploadSessionModel? session = existing.valueOrNull;
      if (session != null) {
        final UploadSessionModel failed = session.copyWith(
          status: UploadSessionStatus.failed,
          errorMessage: initiated.errorOrNull?.message,
          attemptCount: session.attemptCount + 1,
          updatedAt: now,
        );
        await sessions.save(failed);
        return failed;
      }

      final UploadSessionModel placeholder = UploadSessionModel(
        id: IdGenerator.newId('ups'),
        sourceId: source.id,
        chapterId: source.chapterId,
        totalBytes: totalBytes,
        status: UploadSessionStatus.failed,
        errorMessage: initiated.errorOrNull?.message,
        attemptCount: 1,
        createdAt: now,
        updatedAt: now,
      );
      await sessions.save(placeholder);
      return placeholder;
    }

    final Either<AppException, UploadSessionModel?> existing =
        await sessions.getBySource(source.id);
    final UploadSessionModel? previous = existing.valueOrNull;

    final UploadSessionModel active = UploadSessionModel(
      id: previous?.id ?? IdGenerator.newId('ups'),
      sourceId: source.id,
      chapterId: source.chapterId,
      uploadId: initiation.uploadId,
      uploadUrl: initiation.uploadUrl,
      method: initiation.method,
      totalBytes: totalBytes,
      bytesUploaded: initiation.offset,
      chunkSize: initiation.chunkSize,
      status: UploadSessionStatus.active,
      expiresAt: initiation.expiresAt,
      attemptCount: (previous?.attemptCount ?? 0) + 1,
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
    );
    await sessions.save(active);
    return active;
  }
}
