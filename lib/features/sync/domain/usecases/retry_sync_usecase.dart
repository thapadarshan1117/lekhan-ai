import 'package:lekhan_ai/features/sync/domain/repositories/sync_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// The "Retry failed" button in the sync centre.
class RetrySyncUsecase implements UsecaseWithParam<int, RetrySyncParams> {
  const RetrySyncUsecase({required this.repository});

  final SyncRepository repository;

  @override
  Future<Either<AppException, int>> call(RetrySyncParams params) {
    return repository.retryFailed(resetAttempts: params.resetAttempts);
  }
}

class RetrySyncParams {
  const RetrySyncParams({this.resetAttempts = false});

  /// `true` when the user explicitly asks to try again from scratch, even for
  /// tasks that already exhausted their attempt budget.
  final bool resetAttempts;
}

/// Retry or cancel a single queue item.
class RetrySingleTaskUsecase implements UsecaseWithParam<bool, String> {
  const RetrySingleTaskUsecase({required this.repository});

  final SyncRepository repository;

  @override
  Future<Either<AppException, bool>> call(String taskId) {
    return repository.retryTask(taskId);
  }
}

class CancelSyncTaskUsecase implements UsecaseWithParam<bool, String> {
  const CancelSyncTaskUsecase({required this.repository});

  final SyncRepository repository;

  @override
  Future<Either<AppException, bool>> call(String taskId) {
    return repository.cancelTask(taskId);
  }
}
