/// Endpoints used by the offline / sync layer.
///
/// [ApiConfigs] already owns every endpoint that existed before this feature
/// set; nothing there was touched. These are additive and follow the same
/// relative-path convention (they are appended to `ApiConfigs.baseUrl` by
/// `NetworkService`).
///
/// NOTE: the paths below are the contract this client expects from the
/// backend. If the server names them differently, this file is the only place
/// that has to change.
class ApiConstants {
  const ApiConstants._();

  // ---------------------------------------------------------------------------
  // Read models
  // ---------------------------------------------------------------------------

  static const String projects = '/projects';
  static String projectDetail(String projectId) => '/projects/$projectId';

  static const String books = '/books';
  static String bookDetail(String bookId) => '/books/$bookId';
  static String projectBooks(String projectId) => '/projects/$projectId/books';

  static const String chapters = '/chapters';
  static String chapterDetail(String chapterId) => '/chapters/$chapterId';
  static String bookChapters(String bookId) => '/books/$bookId/chapters';

  static String chapterSources(String chapterId) =>
      '/chapters/$chapterId/sources';
  static String sourceDetail(String sourceId) => '/sources/$sourceId';

  // ---------------------------------------------------------------------------
  // Uploads (session based, resumable)
  // ---------------------------------------------------------------------------

  static const String initiateUpload = '/uploads/initiate';
  static String completeUpload(String uploadId) => '/uploads/$uploadId/complete';
  static String uploadStatus(String uploadId) => '/uploads/$uploadId/status';
  static String cancelUpload(String uploadId) => '/uploads/$uploadId/cancel';

  // ---------------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------------

  static const String syncPush = '/sync/push';
  static const String syncPull = '/sync/pull';
  static const String syncStatus = '/sync/status';
}
