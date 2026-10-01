import 'package:lekhan_ai/core/config/backend_mode.dart';
import 'package:lekhan_ai/core/constants/storage_constants.dart';
import 'package:lekhan_ai/core/database/app_database.dart';
import 'package:lekhan_ai/core/storage/storage_manager.dart';
import 'package:lekhan_ai/core/sync/background_sync_scheduler.dart';
import 'package:lekhan_ai/core/sync/sync_state.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';
import 'package:lekhan_ai/shared/data/local/token_storage_service.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_repository.dart';

/// Keeps the durable queue and local media bound to one signed-in account.
/// Without this guard, a background task could upload one person's offline
/// work with another person's bearer token after logout/account switching.
class OfflineSessionGuard {
  const OfflineSessionGuard({
    required this.tokenStorage,
    required this.userRepository,
    required this.storageService,
    required this.database,
    required this.storageManager,
    required this.checkpointStore,
    required this.backgroundScheduler,
  });

  final TokenStorageService tokenStorage;
  final UserRepository userRepository;
  final StorageService storageService;
  final AppDatabase database;
  final StorageManager storageManager;
  final SyncCheckpointStore checkpointStore;
  final BackgroundSyncScheduler backgroundScheduler;

  /// Validates the session and prepares the device store before a user-triggered
  /// or startup sync. A changed account gets an isolated empty offline store.
  Future<bool> prepareForCurrentUser() async {
    if (BackendMode.useMockBackend) return true;

    final String? token = await tokenStorage.getAccessToken();
    if (token == null || token.trim().isEmpty) return false;

    final User? user = await _currentUser();
    final String userId = user?.userId.trim() ?? '';
    if (userId.isEmpty) return false;

    final Object? storedOwner = await storageService.get(
      StorageConstants.syncOwnerUserIdKey,
    );
    final String? owner = storedOwner?.toString();
    if (owner != null && owner.isNotEmpty && owner != userId) {
      await clearAccountData();
    }

    await storageService.set(StorageConstants.syncOwnerUserIdKey, userId);
    return true;
  }

  /// Rechecked before each sync pass/task; a token alone is not enough if the
  /// cached user identity has been cleared or changed.
  Future<bool> canSync() async {
    if (BackendMode.useMockBackend) return true;

    final String? token = await tokenStorage.getAccessToken();
    if (token == null || token.trim().isEmpty) return false;
    final User? user = await _currentUser();
    final String userId = user?.userId.trim() ?? '';
    if (userId.isEmpty) return false;
    final Object? storedOwner = await storageService.get(
      StorageConstants.syncOwnerUserIdKey,
    );
    return storedOwner?.toString() == userId;
  }

  /// Wipes account-owned records, queued requests, media, and sync cursors.
  /// Shared preferences and authentication state are deliberately retained.
  Future<void> clearAccountData() async {
    await backgroundScheduler.cancelAll();
    await database.clearUserData();
    await storageManager.clearUserFiles();
    await checkpointStore.reset();
  }

  /// Logout cleanup is called only after the auth use case has paused sync and
  /// successfully removed the user's credentials.
  Future<void> clearAfterLogout() async {
    await clearAccountData();
    await storageService.remove(StorageConstants.syncOwnerUserIdKey);
  }

  Future<User?> _currentUser() async {
    final result = await userRepository.getUser();
    return result.fold((_) => null, (User user) => user);
  }
}
