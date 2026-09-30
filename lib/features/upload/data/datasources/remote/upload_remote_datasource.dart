import 'dart:io';

// `hide Response`: this file also uses the app's own Response model, and the
// two names would otherwise collide (ambiguous_import).
import 'package:dio/dio.dart' hide Response;
import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// What the backend returns when a session is created.
class UploadInitiation {
  const UploadInitiation({
    required this.uploadId,
    required this.uploadUrl,
    required this.offset,
    required this.chunkSize,
    this.method = 'PUT',
    this.expiresAt,
    this.remoteSourceId,
    this.driveFolderId,
  });

  final String uploadId;
  final String uploadUrl;
  final int offset;
  final int chunkSize;
  final String method;
  final DateTime? expiresAt;
  final String? remoteSourceId;
  final String? driveFolderId;
}

/// Result of pushing one chunk (or of polling the session status).
class UploadChunkResult {
  const UploadChunkResult({
    required this.offset,
    required this.completed,
    this.remoteFileId,
    this.driveFileId,
    this.expired = false,
  });

  final int offset;
  final bool completed;
  final String? remoteFileId;
  final String? driveFileId;
  final bool expired;
}

/// Final server state after the last byte arrived.
class UploadCompletion {
  const UploadCompletion({
    this.remoteSourceId,
    this.remoteFileId,
    this.driveFileId,
    this.processingStatus,
  });

  final String? remoteSourceId;
  final String? remoteFileId;
  final String? driveFileId;
  final String? processingStatus;
}

/// Session based, resumable upload API.
///
/// The bytes never go straight to Google Drive from the phone: the backend
/// owns the Drive credentials, the folder mapping and the ingestion job, so the
/// device only ever talks to one endpoint it already authenticates against.
abstract class UploadRemoteDataSource {
  /// Asks the backend for an upload URL and the Drive destination.
  Future<Either<AppException, UploadInitiation>> initiateSession({
    required String sourceLocalId,
    required String chapterRemoteId,
    required String name,
    required String mimeType,
    required int sizeBytes,
    required String checksum,
    required String sourceType,
    int chunkSize,
  });

  /// Sends one chunk. [onProgress] reports bytes sent *within this chunk*.
  Future<Either<AppException, UploadChunkResult>> pushChunk({
    required String uploadUrl,
    required String method,
    required File file,
    required int offset,
    required int totalBytes,
    required int chunkSize,
    void Function(int sent, int total)? onProgress,
  });

  Future<Either<AppException, UploadCompletion>> completeSession({
    required String uploadId,
    required String checksum,
  });

  Future<Either<AppException, UploadChunkResult>> fetchStatus(String uploadId);

  Future<Either<AppException, bool>> cancelSession(String uploadId);
}

class UploadRemoteDataSourceImpl implements UploadRemoteDataSource {
  const UploadRemoteDataSourceImpl({
    required this.networkService,
    required this.dio,
  });

  final NetworkService networkService;

  /// The same authenticated Dio the app uses for everything else. Chunk
  /// requests need per-request timeouts, which `NetworkService` deliberately
  /// does not expose.
  final Dio dio;

  static const String _identifier = 'UploadRemoteDataSourceImpl';

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
      final Either<AppException, Response> response = await networkService.post(
        ApiConstants.initiateUpload,
        data: <String, dynamic>{
          'local_id': sourceLocalId,
          'chapter_id': chapterRemoteId,
          'name': name,
          'mime_type': mimeType,
          'size': sizeBytes,
          'checksum': checksum,
          'source_type': sourceType,
          'chunk_size': chunkSize,
        },
      );

      return response.fold(
        (AppException exception) => Left<AppException, UploadInitiation>(exception),
        (Response result) {
          final Map<String, dynamic> data = JsonUtils.unwrap(result.data);
          final String uploadUrl = JsonUtils.asString(data['upload_url']);
          final String uploadId = JsonUtils.asString(data['upload_id']);

          if (uploadUrl.isEmpty || uploadId.isEmpty) {
            return Left<AppException, UploadInitiation>(
              AppException(
                message: 'The server did not return an upload location.',
                statusCode: 422,
                identifier: '$_identifier.initiateSession.invalid',
              ),
            );
          }

          return Right<AppException, UploadInitiation>(
            UploadInitiation(
              uploadId: uploadId,
              uploadUrl: uploadUrl,
              offset: JsonUtils.asInt(data['offset']),
              chunkSize: JsonUtils.asInt(data['chunk_size'], fallback: chunkSize),
              method: JsonUtils.asString(data['method'], fallback: 'PUT'),
              expiresAt: JsonUtils.asDateTime(data['expires_at']),
              remoteSourceId: JsonUtils.asStringOrNull(data['source_id']),
              driveFolderId: JsonUtils.asStringOrNull(data['drive_folder_id']),
            ),
          );
        },
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
    RandomAccessFile? reader;
    try {
      reader = await file.open();
      await reader.setPosition(offset);

      final int remaining = totalBytes - offset;
      final int length = remaining < chunkSize ? remaining : chunkSize;
      final List<int> bytes = await reader.read(length);
      final int end = offset + bytes.length - 1;

      // No explicit annotation: the type is dio's Response, which is hidden
      // above to keep the app's Response unambiguous.
      final response = await dio.request<dynamic>(
        uploadUrl,
        data: bytes,
        options: Options(
          method: method,
          headers: <String, dynamic>{
            'Content-Range': 'bytes $offset-$end/$totalBytes',
            'Content-Type': 'application/octet-stream',
          },
          sendTimeout: const Duration(minutes: 10),
          receiveTimeout: const Duration(minutes: 2),
          // The backend answers 308 while the upload is incomplete.
          validateStatus: (int? status) => status != null && status < 500,
        ),
        onSendProgress: onProgress,
      );

      final int status = response.statusCode ?? 0;

      if (status == 401 || status == 403) {
        return Left<AppException, UploadChunkResult>(
          AppException(
            message: 'The upload could not be authorised. Please sign in again.',
            statusCode: status,
            identifier: '$_identifier.pushChunk.unauthorised',
          ),
        );
      }

      if (status == 404 || status == 410) {
        // Session is gone: a new one is needed.
        return Right<AppException, UploadChunkResult>(
          UploadChunkResult(offset: offset, completed: false, expired: true),
        );
      }

      final Map<String, dynamic> data = JsonUtils.unwrap(response.data);
      final int serverOffset =
          JsonUtils.asInt(data['offset'], fallback: offset + bytes.length);
      final bool completed =
          status == 200 || status == 201 || JsonUtils.asBool(data['completed']);

      return Right<AppException, UploadChunkResult>(
        UploadChunkResult(
          offset: serverOffset,
          completed: completed,
          remoteFileId: JsonUtils.asStringOrNull(data['remote_file_id']),
          driveFileId: JsonUtils.asStringOrNull(data['drive_file_id']),
        ),
      );
    } on DioException catch (error) {
      return Left<AppException, UploadChunkResult>(
        FailureMapper.fromDio(error, identifier: '$_identifier.pushChunk'),
      );
    } catch (error) {
      return Left<AppException, UploadChunkResult>(
        FailureMapper.from(error, identifier: '$_identifier.pushChunk'),
      );
    } finally {
      await reader?.close();
    }
  }

  @override
  Future<Either<AppException, UploadCompletion>> completeSession({
    required String uploadId,
    required String checksum,
  }) async {
    try {
      final Either<AppException, Response> response = await networkService.post(
        ApiConstants.completeUpload(uploadId),
        data: <String, dynamic>{'checksum': checksum},
      );

      return response.fold(
        (AppException exception) => Left<AppException, UploadCompletion>(exception),
        (Response result) {
          final Map<String, dynamic> data = JsonUtils.unwrap(result.data);
          return Right<AppException, UploadCompletion>(
            UploadCompletion(
              remoteSourceId: JsonUtils.asStringOrNull(data['source_id']),
              remoteFileId: JsonUtils.asStringOrNull(data['remote_file_id']),
              driveFileId: JsonUtils.asStringOrNull(data['drive_file_id']),
              processingStatus:
                  JsonUtils.asStringOrNull(data['processing_status']),
            ),
          );
        },
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
      final Either<AppException, Response> response =
          await networkService.get(ApiConstants.uploadStatus(uploadId));

      return response.fold(
        (AppException exception) =>
            Left<AppException, UploadChunkResult>(exception),
        (Response result) {
          final Map<String, dynamic> data = JsonUtils.unwrap(result.data);
          return Right<AppException, UploadChunkResult>(
            UploadChunkResult(
              offset: JsonUtils.asInt(data['offset']),
              completed: JsonUtils.asBool(data['completed']),
              remoteFileId: JsonUtils.asStringOrNull(data['remote_file_id']),
              driveFileId: JsonUtils.asStringOrNull(data['drive_file_id']),
              expired: JsonUtils.asBool(data['expired']),
            ),
          );
        },
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
      final Either<AppException, Response> response =
          await networkService.post(ApiConstants.cancelUpload(uploadId));

      return response.fold(
        (AppException exception) => Left<AppException, bool>(exception),
        (Response result) => const Right<AppException, bool>(true),
      );
    } catch (error) {
      return Left<AppException, bool>(
        FailureMapper.from(error, identifier: '$_identifier.cancelSession'),
      );
    }
  }
}
