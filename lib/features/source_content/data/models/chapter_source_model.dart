import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/enums/processing_status.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/enums/upload_status.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';

/// Serialisation for [ChapterSource].
class ChapterSourceModel extends ChapterSource {
  const ChapterSourceModel({
    required super.id,
    required super.chapterId,
    required super.bookId,
    required super.projectId,
    required super.name,
    required super.localPath,
    required super.createdAt,
    required super.updatedAt,
    super.remoteId,
    super.sourceType,
    super.mimeType,
    super.extension,
    super.fileSize,
    super.duration,
    super.uploadStatus,
    super.processingStatus,
    super.uploadProgress,
    super.remoteFileId,
    super.driveFileId,
    super.checksum,
    super.createdBy,
    super.errorMessage,
    super.lastSyncedAt,
    super.isDirty,
    super.isDeleted,
  });

  factory ChapterSourceModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = JsonUtils.asMap(json);
    final DateTime created =
        JsonUtils.asDateTime(data[DatabaseTables.fieldCreatedAt]) ??
            DateTime.now();

    return ChapterSourceModel(
      id: JsonUtils.asString(data[DatabaseTables.fieldId]),
      remoteId: JsonUtils.asStringOrNull(data[DatabaseTables.fieldRemoteId]),
      chapterId: JsonUtils.asString(data['chapter_id']),
      bookId: JsonUtils.asString(data['book_id']),
      projectId: JsonUtils.asString(data['project_id']),
      name: JsonUtils.asString(data['name']),
      localPath: JsonUtils.asString(data['local_path']),
      sourceType: SourceType.fromString(
        JsonUtils.asStringOrNull(data['source_type']),
      ),
      mimeType: JsonUtils.asString(
        data['mime_type'],
        fallback: 'application/octet-stream',
      ),
      extension: JsonUtils.asString(data['extension']),
      fileSize: JsonUtils.asInt(data['file_size']),
      duration: JsonUtils.asDuration(data['duration_seconds']),
      uploadStatus: UploadStatus.fromString(
        JsonUtils.asStringOrNull(data['upload_status']),
      ),
      processingStatus: ProcessingStatus.fromString(
        JsonUtils.asStringOrNull(data['processing_status']),
      ),
      uploadProgress: JsonUtils.asDouble(data['upload_progress']),
      remoteFileId: JsonUtils.asStringOrNull(data['remote_file_id']),
      driveFileId: JsonUtils.asStringOrNull(
        data[DatabaseTables.fieldDriveFileId],
      ),
      checksum: JsonUtils.asString(data['checksum']),
      createdBy: JsonUtils.asStringOrNull(data['created_by']),
      errorMessage: JsonUtils.asStringOrNull(
        data[DatabaseTables.fieldError],
      ),
      createdAt: created,
      updatedAt:
          JsonUtils.asDateTime(data[DatabaseTables.fieldUpdatedAt]) ?? created,
      lastSyncedAt: JsonUtils.asDateTime(data[DatabaseTables.fieldLastSyncedAt]),
      isDirty: JsonUtils.asBool(data[DatabaseTables.fieldIsDirty]),
      isDeleted: JsonUtils.asBool(data[DatabaseTables.fieldIsDeleted]),
    );
  }

  /// Builds the record from what the file store just measured.
  factory ChapterSourceModel.fromStoredFile({
    required String id,
    required String chapterId,
    required String bookId,
    required String projectId,
    required String name,
    required String localPath,
    required String mimeType,
    required String extension,
    required int fileSize,
    required String checksum,
    required SourceType sourceType,
    Duration? duration,
    String? createdBy,
    DateTime? now,
  }) {
    final DateTime stamp = now ?? DateTime.now();
    return ChapterSourceModel(
      id: id,
      chapterId: chapterId,
      bookId: bookId,
      projectId: projectId,
      name: name,
      localPath: localPath,
      mimeType: mimeType,
      extension: extension,
      fileSize: fileSize,
      checksum: checksum,
      sourceType: sourceType,
      duration: duration,
      createdBy: createdBy,
      uploadStatus: UploadStatus.pending,
      processingStatus: ProcessingStatus.notStarted,
      uploadProgress: 0,
      createdAt: stamp,
      updatedAt: stamp,
      isDirty: true,
    );
  }

  factory ChapterSourceModel.fromEntity(ChapterSource source) {
    return ChapterSourceModel(
      id: source.id,
      remoteId: source.remoteId,
      chapterId: source.chapterId,
      bookId: source.bookId,
      projectId: source.projectId,
      name: source.name,
      localPath: source.localPath,
      sourceType: source.sourceType,
      mimeType: source.mimeType,
      extension: source.extension,
      fileSize: source.fileSize,
      duration: source.duration,
      uploadStatus: source.uploadStatus,
      processingStatus: source.processingStatus,
      uploadProgress: source.uploadProgress,
      remoteFileId: source.remoteFileId,
      driveFileId: source.driveFileId,
      checksum: source.checksum,
      createdBy: source.createdBy,
      errorMessage: source.errorMessage,
      lastSyncedAt: source.lastSyncedAt,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
      isDirty: source.isDirty,
      isDeleted: source.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      DatabaseTables.fieldId: id,
      DatabaseTables.fieldRemoteId: remoteId,
      'chapter_id': chapterId,
      'book_id': bookId,
      'project_id': projectId,
      'name': name,
      'local_path': localPath,
      'source_type': sourceType.value,
      'mime_type': mimeType,
      'extension': extension,
      'file_size': fileSize,
      'duration_seconds': duration?.inSeconds,
      'upload_status': uploadStatus.value,
      'processing_status': processingStatus.value,
      'upload_progress': uploadProgress,
      'remote_file_id': remoteFileId,
      DatabaseTables.fieldDriveFileId: driveFileId,
      'checksum': checksum,
      'created_by': createdBy,
      DatabaseTables.fieldError: errorMessage,
      DatabaseTables.fieldCreatedAt: createdAt.toIso8601String(),
      DatabaseTables.fieldUpdatedAt: updatedAt.toIso8601String(),
      DatabaseTables.fieldLastSyncedAt: lastSyncedAt?.toIso8601String(),
      DatabaseTables.fieldIsDirty: isDirty,
      DatabaseTables.fieldIsDeleted: isDeleted,
    };
  }

  /// Metadata pushed to the backend when the source record is created. The
  /// bytes travel separately, through the resumable upload session.
  Map<String, dynamic> toMetadataJson({String? chapterRemoteId}) {
    return <String, dynamic>{
      'name': name,
      'source_type': sourceType.value,
      'mime_type': mimeType,
      'extension': extension,
      'size': fileSize,
      'checksum': checksum,
      if (duration != null) 'duration_seconds': duration!.inSeconds,
      if (chapterRemoteId != null) 'chapter_id': chapterRemoteId,
    };
  }

  ChapterSourceModel withUploadState({
    UploadStatus? uploadStatus,
    double? uploadProgress,
    String? errorMessage,
    bool clearError = false,
    String? remoteId,
    String? remoteFileId,
    String? driveFileId,
    DateTime? at,
  }) {
    return ChapterSourceModel(
      id: id,
      remoteId: remoteId ?? this.remoteId,
      chapterId: chapterId,
      bookId: bookId,
      projectId: projectId,
      name: name,
      localPath: localPath,
      sourceType: sourceType,
      mimeType: mimeType,
      extension: extension,
      fileSize: fileSize,
      duration: duration,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      processingStatus: processingStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      remoteFileId: remoteFileId ?? this.remoteFileId,
      driveFileId: driveFileId ?? this.driveFileId,
      checksum: checksum,
      createdBy: createdBy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSyncedAt: lastSyncedAt,
      createdAt: createdAt,
      updatedAt: at ?? DateTime.now(),
      isDirty: isDirty,
      isDeleted: isDeleted,
    );
  }

  ChapterSourceModel markSynced({String? remoteId, DateTime? at}) {
    final DateTime stamp = at ?? DateTime.now();
    return ChapterSourceModel(
      id: id,
      remoteId: remoteId ?? this.remoteId,
      chapterId: chapterId,
      bookId: bookId,
      projectId: projectId,
      name: name,
      localPath: localPath,
      sourceType: sourceType,
      mimeType: mimeType,
      extension: extension,
      fileSize: fileSize,
      duration: duration,
      uploadStatus: uploadStatus,
      processingStatus: processingStatus,
      uploadProgress: uploadProgress,
      remoteFileId: remoteFileId,
      driveFileId: driveFileId,
      checksum: checksum,
      createdBy: createdBy,
      errorMessage: errorMessage,
      lastSyncedAt: stamp,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDirty: false,
      isDeleted: isDeleted,
    );
  }

  @override
  ChapterSourceModel copyWith({
    String? id,
    String? remoteId,
    String? chapterId,
    String? bookId,
    String? projectId,
    String? name,
    String? localPath,
    SourceType? sourceType,
    String? mimeType,
    String? extension,
    int? fileSize,
    Duration? duration,
    UploadStatus? uploadStatus,
    ProcessingStatus? processingStatus,
    double? uploadProgress,
    String? remoteFileId,
    String? driveFileId,
    String? checksum,
    String? createdBy,
    String? errorMessage,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return ChapterSourceModel(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      chapterId: chapterId ?? this.chapterId,
      bookId: bookId ?? this.bookId,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      localPath: localPath ?? this.localPath,
      sourceType: sourceType ?? this.sourceType,
      mimeType: mimeType ?? this.mimeType,
      extension: extension ?? this.extension,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      processingStatus: processingStatus ?? this.processingStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      remoteFileId: remoteFileId ?? this.remoteFileId,
      driveFileId: driveFileId ?? this.driveFileId,
      checksum: checksum ?? this.checksum,
      createdBy: createdBy ?? this.createdBy,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
