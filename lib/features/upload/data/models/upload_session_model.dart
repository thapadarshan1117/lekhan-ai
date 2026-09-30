import 'package:lekhan_ai/core/constants/file_constants.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/upload/domain/entities/upload_session.dart';

/// Serialisation for [UploadSession].
class UploadSessionModel extends UploadSession {
  const UploadSessionModel({
    required super.id,
    required super.sourceId,
    required super.chapterId,
    required super.totalBytes,
    required super.createdAt,
    required super.updatedAt,
    super.uploadId,
    super.uploadUrl,
    super.method,
    super.bytesUploaded,
    super.chunkSize,
    super.status,
    super.expiresAt,
    super.attemptCount,
    super.remoteFileId,
    super.driveFileId,
    super.errorMessage,
  });

  factory UploadSessionModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = JsonUtils.asMap(json);
    final DateTime created =
        JsonUtils.asDateTime(data['created_at']) ?? DateTime.now();

    return UploadSessionModel(
      id: JsonUtils.asString(data['id']),
      sourceId: JsonUtils.asString(data['source_id']),
      chapterId: JsonUtils.asString(data['chapter_id']),
      uploadId: JsonUtils.asStringOrNull(data['upload_id']),
      uploadUrl: JsonUtils.asStringOrNull(data['upload_url']),
      method: JsonUtils.asString(data['method'], fallback: 'PUT'),
      totalBytes: JsonUtils.asInt(data['total_bytes']),
      bytesUploaded: JsonUtils.asInt(data['bytes_uploaded']),
      chunkSize: JsonUtils.asInt(
        data['chunk_size'],
        fallback: FileConstants.uploadChunkSizeBytes,
      ),
      status: UploadSessionStatus.fromString(
        JsonUtils.asStringOrNull(data['status']),
      ),
      expiresAt: JsonUtils.asDateTime(data['expires_at']),
      attemptCount: JsonUtils.asInt(data['attempt_count']),
      remoteFileId: JsonUtils.asStringOrNull(data['remote_file_id']),
      driveFileId: JsonUtils.asStringOrNull(data['drive_file_id']),
      errorMessage: JsonUtils.asStringOrNull(data['error_message']),
      createdAt: created,
      updatedAt: JsonUtils.asDateTime(data['updated_at']) ?? created,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'source_id': sourceId,
      'chapter_id': chapterId,
      'upload_id': uploadId,
      'upload_url': uploadUrl,
      'method': method,
      'total_bytes': totalBytes,
      'bytes_uploaded': bytesUploaded,
      'chunk_size': chunkSize,
      'status': status.name,
      'expires_at': expiresAt?.toIso8601String(),
      'attempt_count': attemptCount,
      'remote_file_id': remoteFileId,
      'drive_file_id': driveFileId,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Covariant override: callers that hold a model keep a model after a reset
  /// (the base class can only promise an [UploadSession]).
  @override
  UploadSessionModel reset({
    required DateTime now,
    UploadSessionStatus status = UploadSessionStatus.expired,
  }) {
    return UploadSessionModel(
      id: id,
      sourceId: sourceId,
      chapterId: chapterId,
      totalBytes: totalBytes,
      chunkSize: chunkSize,
      status: status,
      createdAt: createdAt,
      updatedAt: now,
    );
  }

  @override
  UploadSessionModel copyWith({
    String? id,
    String? sourceId,
    String? chapterId,
    String? uploadId,
    String? uploadUrl,
    String? method,
    int? totalBytes,
    int? bytesUploaded,
    int? chunkSize,
    UploadSessionStatus? status,
    DateTime? expiresAt,
    int? attemptCount,
    String? remoteFileId,
    String? driveFileId,
    String? errorMessage,
    bool clearError = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UploadSessionModel(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      chapterId: chapterId ?? this.chapterId,
      uploadId: uploadId ?? this.uploadId,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      method: method ?? this.method,
      totalBytes: totalBytes ?? this.totalBytes,
      bytesUploaded: bytesUploaded ?? this.bytesUploaded,
      chunkSize: chunkSize ?? this.chunkSize,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      attemptCount: attemptCount ?? this.attemptCount,
      remoteFileId: remoteFileId ?? this.remoteFileId,
      driveFileId: driveFileId ?? this.driveFileId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
