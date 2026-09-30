/// Lifecycle of a source file *transfer*.
///
/// Deliberately separate from `ProcessingStatus`: a file can be fully uploaded
/// while the backend is still transcribing it.
enum UploadStatus {
  /// Stored locally, queued, not touched yet.
  pending('pending'),

  /// Checksum / session preparation in progress.
  preparing('preparing'),

  /// Bytes are moving (or about to move) to the backend.
  uploading('uploading'),

  /// User or network paused the transfer; it can be resumed from the offset.
  paused('paused'),

  /// Backend has the complete file; the Drive copy is being finalised.
  uploaded('uploaded'),

  /// Permanently failed for this attempt-set; a retry can be triggered.
  failed('failed');

  const UploadStatus(this.value);

  /// Value persisted locally and sent to the API.
  final String value;

  static UploadStatus fromString(String? raw) {
    if (raw == null) return UploadStatus.pending;
    final String needle = raw.trim().toLowerCase();
    for (final UploadStatus status in UploadStatus.values) {
      if (status.value == needle) return status;
    }
    return UploadStatus.pending;
  }

  /// True when no further transfer work is required.
  bool get isTerminal => this == UploadStatus.uploaded;

  /// True when the sync worker may pick this record up again.
  bool get isActionable =>
      this == UploadStatus.pending ||
      this == UploadStatus.paused ||
      this == UploadStatus.failed;

  /// True when bytes are currently represented as in-flight.
  bool get isTransferring => this == UploadStatus.uploading;

  String get label {
    switch (this) {
      case UploadStatus.pending:
        return 'Waiting to upload';
      case UploadStatus.preparing:
        return 'Preparing';
      case UploadStatus.uploading:
        return 'Uploading';
      case UploadStatus.paused:
        return 'Paused';
      case UploadStatus.uploaded:
        return 'Uploaded';
      case UploadStatus.failed:
        return 'Upload failed';
    }
  }
}
