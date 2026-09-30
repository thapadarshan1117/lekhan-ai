import 'package:lekhan_ai/features/sync/domain/repositories/sync_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// "Sync now" / pull-to-refresh. Safe to call while a pass is already running:
/// the running pass wins and this call returns immediately.
class SyncNowUsecase implements UsecaseWithParam<bool, SyncNowParams> {
  const SyncNowUsecase({required this.repository});

  final SyncRepository repository;

  @override
  Future<Either<AppException, bool>> call(SyncNowParams params) {
    return repository.syncNow(force: params.force);
  }
}

class SyncNowParams {
  const SyncNowParams({this.force = false});

  /// `true` for an explicit user action.
  final bool force;
}
