import 'dart:async';

/// Lets any layer ask for a sync without depending on `SyncManager`.
///
/// Repositories publish here right after they persist a local change; the
/// bootstrap listens and runs the engine. Without this, a repository would need
/// the manager, the manager the worker, the worker the handlers and the
/// handlers the repositories - a cycle that DI cannot resolve.
class SyncRequestBus {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  /// Fires whenever something wants the queue drained.
  Stream<void> get onRequest => _controller.stream;

  /// Fire-and-forget: never blocks the write that triggered it.
  void request() {
    if (_controller.isClosed) return;
    _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}
