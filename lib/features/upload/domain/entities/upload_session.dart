import 'package:equatable/equatable.dart';
import 'package:lekhan_ai/core/constants/file_constants.dart';

/// Lifecycle of a resumable upload session.
enum UploadSessionStatus {
  /// Created locally, not initiated with the backend yet.
  pending,

  /// The backend handed out an upload URL; chunks may be sent.
  active,

  /// All bytes acknowledged; the backend is finalising the Drive copy.
  completing,

  /// Finished: the file lives on the server (and in Drive).
  completed,

  /// Transient problem; the offset is kept so the session can be resumed.
  failed,

  /// The session URL is no longer valid; a new session is needed.
  expired,

  /// Deliberately abandoned.
  cancelled;

  bool get isOpen =>
      this == UploadSessionStatus.pending ||
      this == UploadSessionStatus.active ||
      this == UploadSessionStatus.completing ||
      this == UploadSessionStatus.failed;

  static UploadSessionStatus fromString(String? raw) {
    if (raw == null) return UploadSessionStatus.pending;
    final String needle = raw.trim().toLowerCase();
    for (final UploadSessionStatus status in UploadSessionStatus.values) {
      if (status.name == needle) return status;
    }
    return UploadSessionStatus.pending;
  }
}

/// The state of one file's transfer.
///
/// This is where the *byte offset* lives, separately from the `ChapterSource`
/// record. That separation is what makes a 500 MB upload survive a lost
/// connection: the next attempt asks the server where it stopped instead of
/// starting again at zero.
class UploadSession extends Equatable {
  const UploadSession({
    required this.id,
    required this.sourceId,
    required this.chapterId,
    required this.totalBytes,
    required this.createdAt,
    required this.updatedAt,
    this.uploadId,
    this.uploadUrl,
    this.method = 'PUT',
    this.bytesUploaded = 0,
    this.chunkSize = FileConstants.uploadChunkSizeBytes,
    this.status = UploadSessionStatus.pending,
    this.expiresAt,
    this.attemptCount = 0,
    this.remoteFileId,
    this.driveFileId,
    this.errorMessage,
  });

  final String id;

  /// Local id of the [ChapterSource] this session belongs to.
  final String sourceId;
  final String chapterId;

  /// Server-side session id, once initiated.
  final String? uploadId;

  /// Where chunks must be sent. Backend-provided (it proxies to Drive).
  final String? uploadUrl;

  /// HTTP verb for the chunk requests.
  final String method;

  final int totalBytes;

  /// Server-acknowledged offset: the byte the next chunk starts at.
  final int bytesUploaded;

  final int chunkSize;
  final UploadSessionStatus status;
  final DateTime? expiresAt;
  final int attemptCount;
  final String? remoteFileId;
  final String? driveFileId;
  final String? errorMessage;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isExpired {
    final DateTime? expiry = expiresAt;
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry);
  }

  /// True when the backend knows about this session and it can be resumed.
  bool get isResumable =>
      uploadUrl != null &&
      uploadUrl!.isNotEmpty &&
      status.isOpen &&
      !isExpired;

  bool get isComplete => status == UploadSessionStatus.completed;

  int get remainingBytes {
    final int remaining = totalBytes - bytesUploaded;
    return remaining > 0 ? remaining : 0;
  }

  double get progress {
    if (totalBytes <= 0) return 0;
    return (bytesUploaded / totalBytes).clamp(0, 1).toDouble();
  }

  UploadSession copyWith({
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
    return UploadSession(
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

  /// Fresh session parameters after an expiry or a server-side reset.
  UploadSession reset({
    required DateTime now,
    UploadSessionStatus status = UploadSessionStatus.expired,
  }) {
    return UploadSession(
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
  List<Object?> get props => <Object?>[
        id,
        sourceId,
        chapterId,
        uploadId,
        uploadUrl,
        method,
        totalBytes,
        bytesUploaded,
        chunkSize,
        status,
        expiresAt,
        attemptCount,
        remoteFileId,
        driveFileId,
        errorMessage,
        createdAt,
        updatedAt,
      ];
}
