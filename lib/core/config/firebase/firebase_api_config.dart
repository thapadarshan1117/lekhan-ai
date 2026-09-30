import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:lekhan_ai/core/config/firebase/firebase_error_handler.dart';
import 'package:lekhan_ai/core/notifications/notification_controller.dart';
import 'package:lekhan_ai/shared/data/local/fcm_token_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lekhan_ai/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage? message) async {
  try {
    log('🔔 Background message received');
    // Ensure Firebase is initialized with proper options
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      log('✅ Firebase re-initialized for background message');
    }

    if (message != null) {
      log('📋 Background message data: ${message.data}');
      log('📋 Background message notification: title=${message.notification?.title}, body=${message.notification?.body}');
      // Store the route to be handled after app is fully initialized
      // Prefer structured notification payloads (notification_type + content_id)
      try {
        final pending = _buildPendingRouteFromData(message.data);
        pendingNotificationRoute = pending;
        log('✅ Background message pending route set: $pendingNotificationRoute');
      } catch (e) {
        log('❌ Error building pending route from background message: $e');
      }
    } else {
      
      log('⚠️ Background message is null');
    }
  } catch (e) {
    log('❌ Error handling background message: $e');
  }
}

class FirebaseApi {
  final FCMTokenService fcmTokenService = FCMTokenService();

  /// Handles message when app is opened from notification
  /// Sets the pending route for navigation after app is fully ready
  Future<void> handleMessage(RemoteMessage? message) async {
    if (message != null) {
      try {
        final pending = _buildPendingRouteFromData(message.data);
        pendingNotificationRoute = pending;
        log('Message opened app, pending route: $pendingNotificationRoute');
      } catch (e) {
        log('Error building pending route from message: $e');
      }
    }
  }

  Future<String?> ensureFCMToken() async {
    try {
      // If Firebase isn't initialized, skip and return null to avoid crashes
      if (Firebase.apps.isEmpty) {
        return null;
      }
      final token = await fcmTokenService.getOrCreateToken();
      if (token == null || token.isEmpty) {
        // Attempt one explicit refresh
        final refreshed = await FirebaseMessaging.instance.getToken();
        if (refreshed != null && refreshed.isNotEmpty) {
          await fcmTokenService.writeFCMToken(refreshed);
          log('🔔 FCM Token (refreshed): $refreshed');
          return refreshed;
        }
        return null;
      }
      log('🔔 FCM Token: $token');
      return token;
    } catch (e) {
      FirebaseErrorHandler.logError('ensureFCMToken', e);
      return null;
    }
  }

  Future<void> initPushNotifications() async {
    log('📱 Initializing push notifications...');
    
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    log('✅ Foreground notification options set');

    // Handle initial message (app opened from terminated state via notification)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      log('🔔 Initial message received from terminated state');
      try {
        final pending = _buildPendingRouteFromData(initialMessage.data);
        pendingNotificationRoute = pending;
        log('✅ Pending route set: $pendingNotificationRoute');
      } catch (e) {
        log('❌ Error building pending route from initial message: $e');
      }
    } else {
      log('ℹ️ No initial message (app not opened from notification)');
    }

    // Handle message when app is in background and opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('🔔 Message opened app - title: ${message.notification?.title}, body: ${message.notification?.body}');
      handleMessage(message);
    });

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    log('✅ Background message handler registered');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      log('🔔 Foreground message received - title: ${message.notification?.title}, body: ${message.notification?.body}');
      if (message.notification == null) {
        log('⚠️ Message has no notification payload - might be data-only message');
        return;
      }
      
      final notification = message.notification;
      if (notification == null) {
        log('⚠️ Notification is null');
        return;
      }

      // Only create notification if AwesomeNotifications is likely initialized
      try {
        log('📤 Creating awesome notification: ${notification.title}');
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notification.hashCode,
            channelKey: 'generic_channel',
            title: notification.title,
            body: notification.body,
            timeoutAfter: const Duration(minutes: 1),
            notificationLayout: NotificationLayout.Default,
            icon: 'resource://mipmap/launcher_icon',
            largeIcon: 'resource://mipmap/launcher_icon',
            payload: message.data
                .map((key, value) => MapEntry(key, value.toString())),
          ),
        );
        log('✅ Awesome notification created successfully');
      } catch (e) {
        log('❌ Error creating foreground notification: $e');
      }
    });
    log('✅ Foreground message listener registered');
  }

  Future<void> initNotifications() async {
    log('🚀 Starting FCM initialization...');
    
    try {
      if (Platform.isIOS) {
        log('📱 iOS detected - requesting notification permissions');
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        log('📋 iOS notification permission status: ${settings.authorizationStatus}');
        
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          log('✅ iOS notification permission GRANTED');
        } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
          log('❌ iOS notification permission DENIED');
        }
      } else if (Platform.isAndroid) {
        log('🤖 Android detected - requesting notification permission (POST_NOTIFICATIONS)');
        try {
          final status = await Permission.notification.request();
          log('📋 Android notification permission status: $status');
          
          if (status.isGranted) {
            log('✅ Android notification permission GRANTED');
          } else if (status.isDenied) {
            log('⚠️ Android notification permission DENIED - showing system dialog next app launch');
          } else if (status.isPermanentlyDenied) {
            log('❌ Android notification permission PERMANENTLY DENIED - user must enable in Settings');
          } else if (status.isRestricted) {
            log('⚠️ Android notification permission RESTRICTED by system');
          }
        } catch (e) {
          log('❌ Error requesting Android notification permission: $e');
        }
      }

      log('🔑 Attempting to get/create FCM token...');
      final fcmToken = await ensureFCMToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        log('✅ FCM Token obtained and saved: $fcmToken');
        await fcmTokenService.writeFCMToken(fcmToken);
      } else {
        log('❌ Failed to obtain FCM token');
      }

      await initPushNotifications();
      log('✅ FCM initialization complete!');
    } catch (e) {
      log('❌ Fatal error during FCM initialization: $e');
    }
  }
}

String getRoute(String? route) {
  switch (route) {
    case 'home':
      return '/home';
    case 'flashSale':
      return '/home';
    case 'profile':
      return '/profile';
    default:
      return '/home';
  }
}

String _buildPendingRouteFromData(Map<String, dynamic> data) {
  // If explicit route provided, use mapped route
  try {
    if (data.containsKey('route') && (data['route'] as String).isNotEmpty) {
      final mapped = getRoute(data['route'] as String?);
      return jsonEncode({'path': mapped});
    }

    final nType = (data['notification_type'] ?? data['type'])?.toString();
    final contentId =
        (data['content_id'] ?? data['contentId'] ?? data['id'])?.toString();

    if (nType == null || nType.isEmpty) {
      return jsonEncode({'path': getRoute(null)});
    }

    String path;
    Map<String, dynamic>? extra;

    switch (nType.toLowerCase()) {
      case 'system':
        path = '/notification';
        break;
      case 'insight':
        path = '/blog_detail_page';
        extra = contentId != null ? {'id': contentId} : null;
        break;
      case 'audio':
        path = '/audio_player_page';
        extra = contentId != null ? {'id': contentId} : null;
        break;
      case 'video':
        path = '/video_player_page';
        extra = contentId != null ? {'id': contentId} : null;
        break;
      default:
        path = getRoute(null);
    }

    return jsonEncode({'path': path, 'extra': extra});
  } catch (e) {
    return jsonEncode({'path': getRoute(null)});
  }
}
