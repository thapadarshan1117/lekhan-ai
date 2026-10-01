import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/mock/mock_lekhan_backend.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/upload/data/datasources/remote/upload_remote_datasource.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// A network-free implementation of the resumable upload contract.
///
/// It checks the selected file still exists, advances the mock server offset,
/// reports realistic chunk progress, and returns mock file/Drive identifiers.
/// No bytes leave the device and no Google Drive SDK or HTTP client is used.
class MockUploadRemoteDataSource implements UploadRemoteDataSource {
  const MockUploadRemoteDataSource({required this.backend});

  final MockLekhanBackend backend;
  static const String _identifier = 'MockUploadRemoteDataSource';

  @override
  Future<Either<AppException, UploadInitiation>> initiateSession({
    required String sourceLocalId,
    required String chapterRemoteId,
    required String name,
    required String mimeType,
    required int sizeBytes,
    required String checksum,
    required String sourceType,
    int chunkSize = 4 * 1024 * 1024,
  }) async {
    try {
      final MockUploadSession session = await backend.initiateUpload(
        sourceLocalId: sourceLocalId,
        chapterRemoteId: chapterRemoteId,
        sizeBytes: sizeBytes,
        chunkSize: chunkSize,
        checksum: checksum,
      );
      return Right<AppException, UploadInitiation>(
        UploadInitiation(
          uploadId: session.uploadId,
          uploadUrl: session.uploadUrl,
          offset: session.offset,
          chunkSize: session.chunkSize,
          method: 'MOCK',
          remoteSourceId: session.sourceRemoteId,
          driveFolderId: 'mock_drive_folder_${session.chapterRemoteId}',
        ),
      );
    } catch (error) {
      return Left<AppException, UploadInitiation>(
        FailureMapper.from(error, identifier: '$_identifier.initiateSession'),
      );
    }
  }

  @override
  Future<Either<AppException, UploadChunkResult>> pushChunk({
    required String uploadUrl,
    required String method,
    required File file,
    required int offset,
    required int totalBytes,
    required int chunkSize,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      if (!await file.exists()) {
        return Left<AppException, UploadChunkResult>(
          AppException(
            message: 'The selected file is no longer available.',
            statusCode: 404,
            identifier: '$_identifier.pushChunk.fileMissing',
          ),
        );
      }

      final Uri uploadUri = Uri.parse(uploadUrl);
      if (uploadUri.scheme != 'mock-upload' || uploadUri.host.isEmpty) {
        return Left<AppException, UploadChunkResult>(
          AppException(
            message: 'The mock upload session is invalid.',
            statusCode: 400,
            identifier: '$_identifier.pushChunk.invalidSession',
          ),
        );
      }

      final MockUploadSession? session =
          backend.uploadSession(uploadUri.host);
      if (session == null) {
        return Right<AppException, UploadChunkResult>(
          UploadChunkResult(offset: offset, completed: false, expired: true),
        );
      }

      if (offset != session.offset) {
        return Left<AppException, UploadChunkResult>(
          AppException(
            message: 'The mock upload offset is out of date. Retry the upload.',
            statusCode: 409,
            identifier: '$_identifier.pushChunk.offsetMismatch',
          ),
        );
      }

      final int remaining = totalBytes - offset;
      if (remaining <= 0) {
        return Right<AppException, UploadChunkResult>(
          UploadChunkResult(
            offset: offset,
            completed: offset >= totalBytes,
          ),
        );
      }

      final int bytesInChunk =
          remaining < chunkSize ? remaining : chunkSize;
      onProgress?.call(0, bytesInChunk);
      await Future<void>.delayed(backend.latency);
      onProgress?.call(bytesInChunk, bytesInChunk);

      final MockUploadSession? updated = await backend.saveUploadOffset(
        session.uploadId,
        offset + bytesInChunk,
      );
      if (updated == null) {
        return Right<AppException, UploadChunkResult>(
          UploadChunkResult(offset: offset, completed: false, expired: true),
        );
      }

      return Right<AppException, UploadChunkResult>(
        UploadChunkResult(
          offset: updated.offset,
          completed: updated.offset >= totalBytes,
        ),
      );
    } catch (error) {
      return Left<AppException, UploadChunkResult>(
        FailureMapper.from(error, identifier: '$_identifier.pushChunk'),
      );
    }
  }

  @override
  Future<Either<AppException, UploadCompletion>> completeSession({
    required String uploadId,
    required String checksum,
  }) async {
    try {
      final MockUploadSession? session = backend.uploadSession(uploadId);
      if (session == null) {
        return Left<AppException, UploadCompletion>(
          AppException(
            message: 'The mock upload session has expired.',
            statusCode: 410,
            identifier: '$_identifier.completeSession.expired',
          ),
        );
      }
      if (session.offset < session.sizeBytes) {
        return Left<AppException, UploadCompletion>(
          AppException(
            message: 'The mock upload is not complete yet.',
            statusCode: 409,
            identifier: '$_identifier.completeSession.incomplete',
          ),
        );
      }

      final Map<String, dynamic>? result =
          await backend.completeUpload(uploadId);
      if (result == null) {
        return Left<AppException, UploadCompletion>(
          AppException(
            message: 'The mock upload could not be finalized.',
            statusCode: 500,
            identifier: '$_identifier.completeSession.failed',
          ),
        );
      }
      return Right<AppException, UploadCompletion>(
        UploadCompletion(
          remoteSourceId: JsonUtils.asStringOrNull(result['source_id']),
          remoteFileId: JsonUtils.asStringOrNull(result['remote_file_id']),
          driveFileId: JsonUtils.asStringOrNull(result['drive_file_id']),
          processingStatus:
              JsonUtils.asStringOrNull(result['processing_status']),
        ),
      );
    } catch (error) {
      return Left<AppException, UploadCompletion>(
        FailureMapper.from(error, identifier: '$_identifier.completeSession'),
      );
    }
  }

  @override
  Future<Either<AppException, UploadChunkResult>> fetchStatus(
    String uploadId,
  ) async {
    try {
      await Future<void>.delayed(backend.latency);
      final MockUploadSession? session = backend.uploadSession(uploadId);
      if (session == null) {
        return const Right<AppException, UploadChunkResult>(
          UploadChunkResult(offset: 0, completed: false, expired: true),
        );
      }
      return Right<AppException, UploadChunkResult>(
        UploadChunkResult(
          offset: session.offset,
          completed: session.offset >= session.sizeBytes,
        ),
      );
    } catch (error) {
      return Left<AppException, UploadChunkResult>(
        FailureMapper.from(error, identifier: '$_identifier.fetchStatus'),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> cancelSession(String uploadId) async {
    try {
      await backend.cancelUpload(uploadId);
      return const Right<AppException, bool>(true);
    } catch (error) {
      return Left<AppException, bool>(
        FailureMapper.from(error, identifier: '$_identifier.cancelSession'),
      );
    }
  }
}
