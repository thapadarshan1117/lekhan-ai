/// Lifecycle of the *backend* pipeline once a file has arrived.
///
/// Kept separate from `UploadStatus` on purpose: "upload finished" is not the
/// same statement as "AI processing finished".
enum ProcessingStatus {
  notStarted('not_started'),
  queued('queued'),
  transcribing('transcribing'),
  diarizing('diarizing'),
  ingesting('ingesting'),
  completed('completed'),
  failed('failed');

  const ProcessingStatus(this.value);

  final String value;

  static ProcessingStatus fromString(String? raw) {
    if (raw == null) return ProcessingStatus.notStarted;
    final String needle = raw.trim().toLowerCase();
    for (final ProcessingStatus status in ProcessingStatus.values) {
      if (status.value == needle) return status;
    }
    return ProcessingStatus.notStarted;
  }

  bool get isRunning =>
      this == ProcessingStatus.queued ||
      this == ProcessingStatus.transcribing ||
      this == ProcessingStatus.diarizing ||
      this == ProcessingStatus.ingesting;

  bool get isTerminal =>
      this == ProcessingStatus.completed || this == ProcessingStatus.failed;

  String get label {
    switch (this) {
      case ProcessingStatus.notStarted:
        return 'Not processed yet';
      case ProcessingStatus.queued:
        return 'Queued';
      case ProcessingStatus.transcribing:
        return 'Transcribing';
      case ProcessingStatus.diarizing:
        return 'Identifying speakers';
      case ProcessingStatus.ingesting:
        return 'Reading content';
      case ProcessingStatus.completed:
        return 'Ready';
      case ProcessingStatus.failed:
        return 'Processing failed';
    }
  }
}
