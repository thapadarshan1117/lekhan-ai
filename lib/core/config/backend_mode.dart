/// Backend switch for development while the production Lekhan API is being
/// built. Keep the mock path as the default so the app never makes accidental
/// feature API calls before the server contract is ready.
class BackendMode {
  const BackendMode._();

  /// Set to false in one place when the real project/book/chapter/sync/upload
  /// endpoints are deployed and their response contract is verified.
  static const bool useMockBackend = true;
}
