import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:lekhan_ai/app/app.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/config/backend_mode.dart';
import 'package:lekhan_ai/core/sync/sync_bootstrap.dart';
import 'package:lekhan_ai/core/config/firebase/firebase_api_config.dart';
import 'package:lekhan_ai/core/notifications/notification_controller.dart';
import 'package:lekhan_ai/core/services/app_timezone_service.dart';
import 'package:lekhan_ai/core/utils/observer.dart';
import 'package:lekhan_ai/core/theme/domain/model/app_theme_config.dart';
import 'package:lekhan_ai/core/theme/domain/repository/app_theme_repository.dart';
import 'package:lekhan_ai/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    
    // The current UI-only stage stays fully local. Firebase/FCM can be enabled
    // with the live service integrations once mock mode is turned off.
    if (!BackendMode.useMockBackend) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } on FirebaseException catch (e) {
        if (e.code == 'duplicate-app') {
          debugPrint('ℹ️ Firebase already initialized (hot reload)');
        } else {
          rethrow;
        }
      }
    }
    
    AppTimezoneService.instance.initialize();

    // Initialize Awesome Notifications BEFORE Firebase
    debugPrint('📱 Initializing Awesome Notifications...');
    await AwesomeNotifications().initialize(
      // null channel means it will use the default
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'generic_channel',
          channelName: 'Generic notifications',
          channelDescription: 'Notification channel for generic messages',
          defaultColor: const Color(0xFF176B45),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          defaultRingtoneType: DefaultRingtoneType.Notification,
          enableVibration: true,
          enableLights: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic',
        ),
      ],
      debug: kDebugMode,
    );
    debugPrint('✅ Awesome Notifications initialized');

    // Set up notification action listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    );
    debugPrint('✅ Awesome Notifications listeners set');

    if (!BackendMode.useMockBackend) {
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    }

    await setUpServiceLocator();
    // Start the durable sync engine only after Hive, file storage, remotes,
    // local repositories, and the session guard are all ready.
    await sl<SyncBootstrap>().start();

    AppThemeConfig? cachedTheme;
    final cachedThemeRes =
        await sl<AppThemeRepository>().getCachedActiveTheme();
    cachedThemeRes.fold(
      (_) {},
      (theme) => cachedTheme = theme,
    );

    // Support both portrait and landscape so users can choose the orientation
    // that gives them the largest, clearest controls.
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (kDebugMode) {
      Bloc.observer = AppBlocObserver();
    }

    if (!BackendMode.useMockBackend) {
      final firebaseApi = FirebaseApi();
      // Request notifications permission early but don't await it
      unawaited(firebaseApi.initNotifications());
    }

    runApp(MyApp(initialThemeConfig: cachedTheme));
  }, (error, stackTrace) {
    debugPrint(
        'runZonedGuarded: Caught error in my root zone. $error $stackTrace');
    if (!kDebugMode && !BackendMode.useMockBackend) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  });
}
   
