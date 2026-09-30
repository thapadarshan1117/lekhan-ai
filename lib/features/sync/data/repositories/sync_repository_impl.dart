import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/sync/sync_manager.dart';
import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_state.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/sync/data/datasources/sync_remote_datasource.dart';
import 'package:lekhan_ai/features/sync/domain/repositories/sync_repository.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Thin, error-mapped facade over the sync engine.
///
/// The manager owns the behaviour; the repository exists so presentation code
/// keeps depending on the repository abstraction like every other feature.
class SyncRepositoryImpl implements SyncRepository {
  const SyncRepositoryImpl({
    required this.manager,
    required this.queue,
    required this.checkpointStore,
    required this.remote,
  });

  final SyncManager manager;
  final SyncQueue queue;
  final SyncCheckpointStore checkpointStore;
  final SyncRemoteDataSource remote;

  static const String _identifier = 'SyncRepositoryImpl';

  @override
  Stream<SyncState> watchStatus() => manager.watchStatus();

  @override
  SyncState get currentState => manager.currentState;

  @override
  Future<bool> isRunning() async => manager.isRunning;

  @override
  Future<Either<AppException, bool>> syncNow({bool force = false}) async {
    try {
      await manager.sync(
        trigger: force ? SyncTrigger.manual : SyncTrigger.push,
      );
      return const Right<AppException, bool>(true);
    } catch (error) {
      return Left<AppException, bool>(
        FailureMapper.from(error, identifier: '$_identifier.syncNow'),
      );
    }
  }

  @override
  Future<Either<AppException, int>> retryFailed({
    bool resetAttempts = false,
  }) async {
    try {
      final int before = await queue.countByStatus(SyncStatus.failed);
      await manager.retryFailed(resetAttempts: resetAttempts);
      return Right<AppException, int>(before);
    } catch (error) {
      return Left<AppException, int>(
        FailureMapper.from(error, identifier: '$_identifier.retryFailed'),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> retryTask(String taskId) async {
    try {
      await manager.retryTask(taskId);
      return const Right<AppException, bool>(true);
    } catch (error) {
      return Left<AppException, bool>(
        FailureMapper.from(error, identifier: '$_identifier.retryTask'),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> cancelTask(String taskId) async {
    try {
      await manager.cancelTask(taskId);
      return const Right<AppException, bool>(true);
    } catch (error) {
      return Left<AppException, bool>(
        FailureMapper.from(error, identifier: '$_identifier.cancelTask'),
      );
    }
  }

  @override
  Future<Either<AppException, List<SyncTask>>> pendingTasks() async {
    try {
      final List<SyncTask> tasks = await queue.all();
      final List<SyncTask> open = tasks
          .where((SyncTask task) =>
              task.status == SyncStatus.pending ||
              task.status == SyncStatus.inProgress)
          .toList();
      return Right<AppException, List<SyncTask>>(open);
    } catch (error) {
      return Left<AppException, List<SyncTask>>(
        FailureMapper.from(error, identifier: '$_identifier.pendingTasks'),
      );
    }
  }

  @override
  Future<Either<AppException, List<SyncTask>>> failedTasks() async {
    try {
      final List<SyncTask> tasks = await queue.all();
      final List<SyncTask> failed = tasks
          .where((SyncTask task) => task.status == SyncStatus.failed)
          .toList();
      return Right<AppException, List<SyncTask>>(failed);
    } catch (error) {
      return Left<AppException, List<SyncTask>>(
        FailureMapper.from(error, identifier: '$_identifier.failedTasks'),
      );
    }
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> remoteStatus() {
    return remote.fetchStatus();
  }

  @override
  Future<DateTime?> lastSyncedAt() => checkpointStore.lastSyncedAt();
}
