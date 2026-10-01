import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/sync/offline_session_guard.dart';
import 'package:lekhan_ai/core/sync/sync_manager.dart';
import 'package:lekhan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

class LogoutUsecase extends Usecase<String> {
  final AuthRepository authRepository;
  final SyncManager? syncManager;
  final OfflineSessionGuard? sessionGuard;

  LogoutUsecase({
    required this.authRepository,
    this.syncManager,
    this.sessionGuard,
  });

  @override
  Future<Either<AppException, String>> call() async {
    // Do not let an in-flight worker race with local account cleanup.
    await syncManager?.pause();
    final Either<AppException, String> result =
        await authRepository.logout();

    final bool succeeded = result.fold<bool>(
      (AppException _) => false,
      (String _) => true,
    );
    if (!succeeded) {
      syncManager?.resume();
      return result;
    }

    try {
      // Offline metadata, media, cursors, and queued requests belong to the
      // signed-out user. Clearing them prevents a later account from uploading
      // or viewing another user's cached records.
      await sessionGuard?.clearAfterLogout();
    } catch (error, stackTrace) {
      log('LogoutUsecase: local account cleanup failed',
          error: error, stackTrace: stackTrace);
    }
    return result;
  }
}
