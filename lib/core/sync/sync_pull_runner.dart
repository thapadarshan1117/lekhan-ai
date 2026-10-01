/// A pull step that applies server-owned changes to the local cache.
/// Returns null on success, or a user-safe message when the pull failed.
abstract interface class SyncPullRunner {
  Future<String?> pull();
}
