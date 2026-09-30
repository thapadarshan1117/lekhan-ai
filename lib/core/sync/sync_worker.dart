import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// What happened to a single queued task.
class SyncOutcome {
  const SyncOutcome.success({this.remoteId, this.message, this.progress})
      : succeeded = true,
        errorMessage = null;

  const SyncOutcome.failure(String error)
      : succeeded = false,
        errorMessage = error,
        remoteId = null,
        message = null,
        progress = null;

  final bool succeeded;

  /// Server id assigned to the record, when there is one.
  final String? remoteId;

  /// Optional note for logs / the sync centre (never shown as an error).
  final String? message;

  /// Optional completion progress, 0..1.
  final double? progress;

  final String? errorMessage;
}

/// Executes one class of queued work.
///
/// Handlers are registered in DI, which is what keeps the sync engine free of
/// any knowledge about chapters, Drive folders or upload sessions.
abstract class SyncTaskHandler {
  SyncEntityType get entityType;

  Set<SyncOperation> get supportedOperations;

  bool canHandle(SyncTask task) =>
      task.entityType == entityType &&
      supportedOperations.contains(task.operation);

  /// Performs the work. Reporting failure = throwing, or returning
  /// [SyncOutcome.failure]; the worker accepts both.
  Future<SyncOutcome> handle(SyncTask task);
}

/// Picks the handler for a task and normalises the failures.
class SyncWorker {
  SyncWorker({required List<SyncTaskHandler> handlers})
      : _handlers = List<SyncTaskHandler>.unmodifiable(handlers);

  final List<SyncTaskHandler> _handlers;

  List<SyncTaskHandler> get handlers => _handlers;

  bool canHandle(SyncTask task) => _handlerFor(task) != null;

  /// Which entity types survived DI wiring - handy when debugging an empty run.
  Set<SyncEntityType> get handledEntityTypes =>
      _handlers.map((SyncTaskHandler handler) => handler.entityType).toSet();

  Future<SyncOutcome> execute(SyncTask task) async {
    final SyncTaskHandler? handler = _handlerFor(task);
    if (handler == null) {
      return SyncOutcome.failure(
        'Nothing is registered to handle ${task.entityType.value} / '
        '${task.operation.value}.',
      );
    }

    try {
      return await handler.handle(task);
    } on AppException catch (error) {
      return SyncOutcome.failure(error.message);
    } catch (error) {
      return SyncOutcome.failure(error.toString());
    }
  }

  SyncTaskHandler? _handlerFor(SyncTask task) {
    for (final SyncTaskHandler handler in _handlers) {
      if (handler.canHandle(task)) return handler;
    }
    return null;
  }
}
