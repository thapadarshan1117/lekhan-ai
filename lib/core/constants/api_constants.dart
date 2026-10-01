/// Endpoints used by the offline / sync layer.
///
/// These paths are the client/backend contract. The phone never calls Google
/// Drive directly: authenticated requests go to the Lekhan API, which owns
/// authorization, folder mapping, Drive credentials, and ingestion jobs.
class ApiConstants {
  const ApiConstants._();

  static String _segment(String value) => Uri.encodeComponent(value);

  // ---------------------------------------------------------------------------
  // Read models
  // ---------------------------------------------------------------------------

  static const String projects = '/projects';
  static String projectDetail(String projectId) =>
      '/projects/${_segment(projectId)}';

  static const String books = '/books';
  static String bookDetail(String bookId) => '/books/${_segment(bookId)}';
  static String projectBooks(String projectId) =>
      '/projects/${_segment(projectId)}/books';

  static const String chapters = '/chapters';
  static String chapterDetail(String chapterId) =>
      '/chapters/${_segment(chapterId)}';
  static String bookChapters(String bookId) =>
      '/books/${_segment(bookId)}/chapters';

  static String chapterSources(String chapterId) =>
      '/chapters/${_segment(chapterId)}/sources';
  static String sourceDetail(String sourceId) =>
      '/sources/${_segment(sourceId)}';

  // ---------------------------------------------------------------------------
  // Uploads (session based, resumable)
  // ---------------------------------------------------------------------------

  static const String initiateUpload = '/uploads/initiate';
  static String completeUpload(String uploadId) =>
      '/uploads/${_segment(uploadId)}/complete';
  static String uploadStatus(String uploadId) =>
      '/uploads/${_segment(uploadId)}/status';
  static String cancelUpload(String uploadId) =>
      '/uploads/${_segment(uploadId)}/cancel';

  // ---------------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------------

  static const String syncPush = '/sync/push';
  static const String syncPull = '/sync/pull';
  static const String syncStatus = '/sync/status';
}
