/// Single place that owns every name used by the offline layer, both on the
/// file system and inside Hive.
///
/// Keeping the names here means a rename only ever has to happen once, and it
/// keeps magic strings out of the datasources.
class StorageConstants {
  const StorageConstants._();

  // ---------------------------------------------------------------------------
  // Hive
  // ---------------------------------------------------------------------------

  /// Prefix applied to every box so this app never collides with another
  /// Hive-using package in the same process.
  static const String boxPrefix = 'lekhan_';

  /// Box holding the schema version / migration bookkeeping.
  static const String metaBoxName = '${boxPrefix}meta_box';

  // ---------------------------------------------------------------------------
  // Local file store
  // ---------------------------------------------------------------------------

  /// Root folder inside the app documents directory.
  static const String appFolderName = 'lekhan_app';

  static const String projectsFolder = 'projects';
  static const String audioFolder = 'audio';
  static const String videoFolder = 'video';
  static const String documentsFolder = 'documents';
  static const String scansFolder = 'scans';
  static const String recordingsFolder = 'recordings';

  /// Scratch space for in-flight copies / recordings before they are moved into
  /// the final chapter folder. Everything here is safe to delete.
  static const String tempFolder = 'temp';

  /// Prefix used by [LocalFileStorage] when it stages a file before moving it.
  static const String stagingPrefix = '.staging_';

  // ---------------------------------------------------------------------------
  // Keys written through StorageService (SharedPreferences)
  // ---------------------------------------------------------------------------

  static const String lastSyncedAtKey = '${boxPrefix}last_synced_at';
  static const String lastSyncErrorKey = '${boxPrefix}last_sync_error';
  static const String syncWifiOnlyKey = '${boxPrefix}sync_wifi_only';
  static const String syncChargingOnlyKey = '${boxPrefix}sync_charging_only';
  static const String backgroundSyncEnabledKey =
      '${boxPrefix}background_sync_enabled';
  static const String maxParallelUploadsKey =
      '${boxPrefix}max_parallel_uploads';
  static const String schemaVersionKey = '${boxPrefix}schema_version';

  // ---------------------------------------------------------------------------
  // Defaults
  // ---------------------------------------------------------------------------

  static const bool defaultSyncWifiOnly = false;
  static const bool defaultSyncChargingOnly = false;
  static const bool defaultBackgroundSyncEnabled = true;
  static const int defaultMaxParallelUploads = 1;
}
