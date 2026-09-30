import 'dart:async';
import 'dart:io';
import 'package:lekhan_ai/core/config/firebase/firebase_api_config.dart';
import 'package:lekhan_ai/features/notifications/domain/usecases/allow_notification_usecase.dart';
import 'package:lekhan_ai/features/notifications/presentation/bloc/notification_permission_state.dart';
import 'package:lekhan_ai/shared/data/local/notification_sync_state_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';

class NotificationPermissionCubit extends Cubit<NotificationPermissionState> {
  final FirebaseApi firebaseApi;
  final AllowNotificationUseCase allowNotificationUseCase;
  final NotificationSyncStateService syncStateService;

  DateTime? _lastPromptAt;
  StreamSubscription<String>? _tokenSub;

  NotificationPermissionCubit({
    required this.firebaseApi,
    required this.allowNotificationUseCase,
    required this.syncStateService,
  }) : super(NotificationPermissionInitial());

  bool _isFirebaseReady() {
    // Firebase.initializeApp might be skipped offline; avoid calling Messaging APIs then
    return Firebase.apps.isNotEmpty;
  }

  Future<void> checkStatus() async {
    emit(NotificationPermissionLoading());
    try {
      if (!_isFirebaseReady()) {
        final synced = await syncStateService.getTokenSyncedToServer();
        emit(NotificationPermissionStatus(
            authorized: false, tokenSynced: synced));
        return;
      }
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      await syncStateService.setSystemAuthorized(authorized);
      final synced = await syncStateService.getTokenSyncedToServer();
      emit(NotificationPermissionStatus(
          authorized: authorized, tokenSynced: synced));
    } catch (e) {
      emit(NotificationPermissionError(e.toString()));
    }
  }

  bool shouldPromptAgain({Duration cooldown = const Duration(hours: 24)}) {
    if (_lastPromptAt == null) return true;
    return DateTime.now().difference(_lastPromptAt!) > cooldown;
  }

  void markPromptShown() {
    _lastPromptAt = DateTime.now();
  }

  Future<void> requestAndRegisterToken() async {
    emit(NotificationPermissionLoading());
    try {
      if (!_isFirebaseReady()) {
        // Can't request via FirebaseMessaging when Firebase isn't ready; treat as denied
        emit(NotificationPermissionDenied());
        return;
      }
      // If already authorized, don't show OS dialog again; else request.
      final currentSettings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (currentSettings.authorizationStatus !=
              AuthorizationStatus.authorized &&
          currentSettings.authorizationStatus !=
              AuthorizationStatus.provisional) {
        final requested = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        if (requested.authorizationStatus != AuthorizationStatus.authorized &&
            requested.authorizationStatus != AuthorizationStatus.provisional) {
          emit(NotificationPermissionDenied());
          return;
        }
      }

      final token = await firebaseApi.ensureFCMToken();
      if (token == null || token.isEmpty) {
        // Token might arrive shortly via onTokenRefresh (especially on iOS). Listen once.
        _tokenSub?.cancel();
        final completer = Completer<void>();
        _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen(
          (newToken) async {
            try {
              if (newToken.isEmpty) return;
              final res = await allowNotificationUseCase(null);
              res.fold(
                (l) => emit(NotificationPermissionError(l.message)),
                (r) async {
                  await syncStateService.setTokenSyncedToServer(true);
                  await syncStateService.setLastToken(newToken);
                  await syncStateService.setLastSyncAt(DateTime.now());
                  emit(NotificationPermissionAuthorized());
             
                  await openBatteryOptimizationSettings();
                },
              );
            } finally {
              await _tokenSub?.cancel();
              _tokenSub = null;
              if (!completer.isCompleted) completer.complete();
            }
          },
        );

        // Safety timeout in case token never arrives
        await completer.future.timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            if (_tokenSub != null) {
              _tokenSub!.cancel();
              _tokenSub = null;
            }
            emit(NotificationPermissionError('Unable to obtain device token'));
          },
        );
        return;
      } else {
        final res = await allowNotificationUseCase(null);
        res.fold(
          (l) => emit(NotificationPermissionError(l.message)),
          (r) async {
            await syncStateService.setTokenSyncedToServer(true);
            await syncStateService.setLastToken(token);
            await syncStateService.setLastSyncAt(DateTime.now());
            emit(NotificationPermissionAuthorized());
            // After authorization, keep local reminders in sync and guide user to disable battery optimizations
        
            await openBatteryOptimizationSettings();
          },
        );
      }
    } catch (e) {
      emit(NotificationPermissionError(e.toString()));
    }
  }

  Future<void> openSystemSettingsAndRetry() async {
    // if (Platform.isAndroid) {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
    // } else {
    //   await openAppSettings();
    // }
    // Additionally prompt battery optimization settings on Android (important for Redmi/MIUI)
    await openBatteryOptimizationSettings();
    // Single delayed check then sync silently if needed (no polling loop)
    await Future.delayed(const Duration(seconds: 1));
    await autoSync();
  }

  /// Silent synchronization without prompting user; used on app start/resume.
  Future<void> autoSync() async {
    try {
      if (!_isFirebaseReady()) {
        // Persist and emit conservative status
        await syncStateService.setSystemAuthorized(false);
        final tokenSynced = await syncStateService.getTokenSyncedToServer();
        emit(NotificationPermissionStatus(
            authorized: false, tokenSynced: tokenSynced));
        return;
      }
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      await syncStateService.setSystemAuthorized(authorized);
      var tokenSynced = await syncStateService.getTokenSyncedToServer();

      if (authorized && !tokenSynced) {
        final token = await firebaseApi.ensureFCMToken();
        if (token != null && token.isNotEmpty) {
          final res = await allowNotificationUseCase(null);
          await res.fold((l) async {
            // Keep tokenSynced false; optionally log error
          }, (r) async {
            await syncStateService.setTokenSyncedToServer(true);
            await syncStateService.setLastToken(token);
            await syncStateService.setLastSyncAt(DateTime.now());
            tokenSynced = true;
          });
        }
      }
  
      emit(NotificationPermissionStatus(
          authorized: authorized, tokenSynced: tokenSynced));
    } catch (e) {
      emit(NotificationPermissionError(e.toString()));
    }
  }

  /// Opens battery optimization settings page on Android so the user can
  /// whitelist the app for background activity. Helps with Redmi/MIUI.
  Future<void> openBatteryOptimizationSettings() async {
    if (Platform.isAndroid) {
      try {
        await AppSettings.openAppSettings(
            type: AppSettingsType.batteryOptimization);
      } catch (_) {
        // Fallback to general settings if specific page is unavailable
        await AppSettings.openAppSettings();
      }
    }
  }

  @override
  Future<void> close() async {
    await _tokenSub?.cancel();
    _tokenSub = null;
    // ignore: invalid_use_of_protected_member
    return super.close();
  }
}
