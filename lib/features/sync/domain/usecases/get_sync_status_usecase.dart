import 'package:lekhan_ai/core/sync/sync_state.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/features/sync/domain/repositories/sync_repository.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Status for the global indicator and the sync centre.
class GetSyncStatusUsecase {
  const GetSyncStatusUsecase({required this.repository});

  final SyncRepository repository;

  /// Current snapshot (for a synchronous first paint).
  SyncState call() => repository.currentState;

  /// Live status; emits immediately, then on every change.
  Stream<SyncState> watch() => repository.watchStatus();

  SyncState get current => repository.currentState;

  Future<List<SyncTask>> pending() async {
    final Either<AppException, List<SyncTask>> result =
        await repository.pendingTasks();
    return result.fold(
      (AppException _) => <SyncTask>[],
      (List<SyncTask> tasks) => tasks,
    );
  }

  Future<List<SyncTask>> failed() async {
    final Either<AppException, List<SyncTask>> result =
        await repository.failedTasks();
    return result.fold(
      (AppException _) => <SyncTask>[],
      (List<SyncTask> tasks) => tasks,
    );
  }

  Future<DateTime?> lastSyncedAt() => repository.lastSyncedAt();
}
