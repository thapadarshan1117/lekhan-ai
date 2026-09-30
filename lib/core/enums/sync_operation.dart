/// The verb of a queued unit of work.
enum SyncOperation {
  create('create'),
  update('update'),
  delete('delete'),

  /// Move the bytes of a locally stored file to the backend.
  uploadFile('upload_file'),

  /// Download server-side changes (handled by the pull pipeline, not the queue).
  pullMetadata('pull_metadata');

  const SyncOperation(this.value);

  final String value;

  static SyncOperation fromString(String? raw) {
    if (raw == null) return SyncOperation.update;
    final String needle = raw.trim().toLowerCase();
    for (final SyncOperation operation in SyncOperation.values) {
      if (operation.value == needle) return operation;
    }
    return SyncOperation.update;
  }

  /// Whether the operation touches only metadata.
  bool get isMetadata =>
      this == SyncOperation.create ||
      this == SyncOperation.update ||
      this == SyncOperation.delete ||
      this == SyncOperation.pullMetadata;
}

/// The noun of a queued unit of work.
enum SyncEntityType {
  project('project'),
  book('book'),
  chapter('chapter'),
  chapterSource('chapter_source'),
  uploadSession('upload_session'),

  /// Reading progress / word counts, batched separately from structure.
  progress('progress');

  const SyncEntityType(this.value);

  final String value;

  static SyncEntityType fromString(String? raw) {
    if (raw == null) return SyncEntityType.chapterSource;
    final String needle = raw.trim().toLowerCase();
    for (final SyncEntityType type in SyncEntityType.values) {
      if (type.value == needle) return type;
    }
    return SyncEntityType.chapterSource;
  }
}
