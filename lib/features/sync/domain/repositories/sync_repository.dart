import 'package:lekhan_ai/core/sync/sync_state.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Read side of the sync engine for the UI (indicator, sync centre).
abstract class SyncRepository {
  /// Emits the current state immediately, then on every change.
  Stream<SyncState> watchStatus();

  SyncState get currentState;

  Future<bool> isRunning();

  /// Runs a full pass. [force] is used by pull-to-refresh style gestures.
  Future<Either<AppException, bool>> syncNow({bool force});

  /// "Retry failed" in the sync centre.
  Future<Either<AppException, int>> retryFailed({bool resetAttempts});

  Future<Either<AppException, bool>> retryTask(String taskId);

  Future<Either<AppException, bool>> cancelTask(String taskId);

  Future<Either<AppException, List<SyncTask>>> pendingTasks();

  Future<Either<AppException, List<SyncTask>>> failedTasks();

  Future<Either<AppException, Map<String, dynamic>>> remoteStatus();

  Future<DateTime?> lastSyncedAt();
}
