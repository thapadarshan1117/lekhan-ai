import 'package:equatable/equatable.dart';
import 'package:lekhan_ai/core/enums/processing_status.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/enums/upload_status.dart';
import 'package:lekhan_ai/core/utils/file_utils.dart';

/// A piece of raw material for a chapter: an interview recording, a video, a
/// PDF, a scan of a diary page.
///
/// The bytes live in the app's file store; this record only knows *about* them.
/// [uploadStatus] (did the bytes arrive at the backend?) and [processingStatus]
/// (has the AI pipeline finished?) are deliberately separate questions.
class ChapterSource extends Equatable {
  const ChapterSource({
    required this.id,
    required this.chapterId,
    required this.bookId,
    required this.projectId,
    required this.name,
    required this.localPath,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.sourceType = SourceType.document,
    this.mimeType = 'application/octet-stream',
    this.extension = '',
    this.fileSize = 0,
    this.duration,
    this.uploadStatus = UploadStatus.pending,
    this.processingStatus = ProcessingStatus.notStarted,
    this.uploadProgress = 0,
    this.remoteFileId,
    this.driveFileId,
    this.checksum = '',
    this.createdBy,
    this.errorMessage,
    this.lastSyncedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  final String id;
  final String? remoteId;

  /// Local ids of the whole ancestor chain: the file path needs them and the
  /// offline layer must not depend on a join to build it.
  final String chapterId;
  final String bookId;
  final String projectId;

  /// Display name, i.e. the file name as the user saw it.
  final String name;

  /// Absolute path inside the app's documents directory.
  final String localPath;

  /// When the record was created on this device. Never overwritten by the
  /// server, so it doubles as a stable local ordering key.
  final DateTime createdAt;

  /// Last local modification.
  final DateTime updatedAt;

  final SourceType sourceType;
  final String mimeType;
  final String extension;
  final int fileSize;

  /// Only meaningful for audio/video.
  final Duration? duration;

  final UploadStatus uploadStatus;
  final ProcessingStatus processingStatus;

  /// 0..1 of the *current attempt*; the authoritative byte offset lives in the
  /// upload session so a resume never restarts from zero.
  final double uploadProgress;

  /// Id the backend assigned once the record exists server-side.
  final String? remoteFileId;

  /// Google Drive file id, set by the backend after the upload completes.
  final String? driveFileId;

  /// SHA-256 of the stored file: identity that does not depend on the name.
  final String checksum;

  final String? createdBy;
  final String? errorMessage;
  final DateTime? lastSyncedAt;
  final bool isDirty;
  final bool isDeleted;

  // ---------------------------------------------------------------------------
  // Derived state
  // ---------------------------------------------------------------------------

  bool get isUploaded => uploadStatus == UploadStatus.uploaded;

  bool get hasFailed => uploadStatus == UploadStatus.failed;

  /// True while the file only exists on this device.
  bool get isLocalOnly => remoteId == null || remoteId!.isEmpty;

  /// What the source card should say under the file name.
  String get statusLabel {
    if (hasFailed) {
      return errorMessage ?? 'Upload failed. Tap to retry.';
    }
    if (!isUploaded) return uploadStatus.label;
    if (processingStatus == ProcessingStatus.completed) return 'Ready';
    return processingStatus.label;
  }

  String get readableSize => FileUtils.formatBytes(fileSize);

  String get readableDuration =>
      duration == null ? '' : FileUtils.formatDuration(duration!);

  int get progressPercent =>
      (uploadProgress.clamp(0, 1) * 100).round().clamp(0, 100);

  ChapterSource copyWith({
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
    return ChapterSource(
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

  @override
  List<Object?> get props => <Object?>[
        id,
        remoteId,
        chapterId,
        bookId,
        projectId,
        name,
        localPath,
        sourceType,
        mimeType,
        extension,
        fileSize,
        duration,
        uploadStatus,
        processingStatus,
        uploadProgress,
        remoteFileId,
        driveFileId,
        checksum,
        createdBy,
        errorMessage,
        lastSyncedAt,
        createdAt,
        updatedAt,
        isDirty,
        isDeleted,
      ];
}
