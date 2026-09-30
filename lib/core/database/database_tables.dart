import 'package:lekhan_ai/core/constants/storage_constants.dart';

/// Physical layout of the local store: which Hive boxes exist, and the field
/// names that are shared between several entities.
///
/// Hive is schemaless, so this file is the schema: treat it as the single
/// source of truth for box names and cross-cutting keys.
class DatabaseTables {
  const DatabaseTables._();

  // ---------------------------------------------------------------------------
  // Boxes
  // ---------------------------------------------------------------------------

  static const String meta = StorageConstants.metaBoxName;

  static const String projects = '${StorageConstants.boxPrefix}projects_box';
  static const String books = '${StorageConstants.boxPrefix}books_box';
  static const String chapters = '${StorageConstants.boxPrefix}chapters_box';
  static const String chapterSources =
      '${StorageConstants.boxPrefix}chapter_sources_box';
  static const String uploadSessions =
      '${StorageConstants.boxPrefix}upload_sessions_box';
  static const String syncQueue = '${StorageConstants.boxPrefix}sync_queue_box';

  /// Opened on every start. Order matters only for readability.
  static const List<String> allBoxes = <String>[
    meta,
    projects,
    books,
    chapters,
    chapterSources,
    uploadSessions,
    syncQueue,
  ];

  /// Boxes that hold user data (and therefore get cleared on sign-out).
  static const List<String> userDataBoxes = <String>[
    projects,
    books,
    chapters,
    chapterSources,
    uploadSessions,
    syncQueue,
  ];

  // ---------------------------------------------------------------------------
  // Shared field names
  // ---------------------------------------------------------------------------

  /// Local identifier (uuid, created on device, never reused).
  static const String fieldId = 'id';

  /// Server identifier once the record has been accepted.
  static const String fieldRemoteId = 'remote_id';

  static const String fieldCreatedAt = 'created_at';
  static const String fieldUpdatedAt = 'updated_at';
  static const String fieldLastSyncedAt = 'last_synced_at';

  /// True while the local copy has changes the server has not seen.
  static const String fieldIsDirty = 'is_dirty';

  /// Soft delete marker: the row stays until the server confirms the delete,
  /// which keeps an offline delete recoverable.
  static const String fieldIsDeleted = 'is_deleted';

  static const String fieldDriveFolderId = 'drive_folder_id';
  static const String fieldDriveFileId = 'drive_file_id';
  static const String fieldError = 'error_message';
}
