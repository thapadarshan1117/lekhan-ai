import 'dart:developer';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:lekhan_ai/core/router/route_manager.dart';

/// Stores the pending notification route when app is launched from terminated state.
/// This is consumed by the app after full initialization.
String? pendingNotificationRoute;

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final payload = receivedAction.payload;
    if (payload == null) return;

    // Prefer explicit route if provided (backwards compatible)
    final explicitRoute = payload['route'];
    if (explicitRoute != null && explicitRoute.isNotEmpty) {
      log('NotificationController: Action received for explicit route: $explicitRoute');
      await _navigateWithHomeStack(explicitRoute);
      return;
    }

    // New payload shape: { notification_type, content_id }
    final nType = (payload['notification_type'] ?? payload['type'])?.toString();
    final contentId =
        (payload['content_id'] ?? payload['contentId'] ?? payload['id'])
            ?.toString();

    if (nType == null || nType.isEmpty) return;

    log('NotificationController: Action received, type: $nType, id: $contentId');

    String path;
    Map<String, dynamic>? extra;

    switch (nType.toLowerCase()) {
      case 'system':
        path = '/notification';
        extra = null;
        break;
      case 'insight':
        path = '/blog_detail_page';
        extra = contentId != null ? {'id': contentId} : null;
        break;
      case 'audio':
        path = '/audio_player_page';
        extra = contentId != null ? {'id': contentId} : null;
        break;

      default:
        // Unknown type - do nothing
        return;
    }

    final target = {'path': path, 'extra': extra};

    // If the app is in terminated state handler will store pending route as string
    // Store as JSON string so handlePendingNotificationRoute can decode it.
    try {
      pendingNotificationRoute = jsonEncode(target);
    } catch (_) {
      pendingNotificationRoute = null;
    }

    await _navigateWithHomeStack(target);
  }

  /// Navigates to the target route while ensuring the correct home page
  /// is in the navigation stack based on user type.
  static Future<void> _navigateWithHomeStack(dynamic target) async {
    try {
      // Get the user's home route based on their type
      final homeRoute = await _getHomeRouteForCurrentUser();
      String targetPath;
      Map<String, dynamic>? extra;

      if (target is String) {
        targetPath = target;
      } else if (target is Map) {
        targetPath = (target['path'] as String?) ?? '';
        extra = (target['extra'] as Map<String, dynamic>?);
      } else {
        // unexpected target type
        return;
      }

      log('NotificationController: Home route: $homeRoute, Target: $targetPath');

      // If the target is already the home route, just go there
      if (targetPath == homeRoute) {
        RouterManager.router.go(targetPath);
        return;
      }

      // Replace stack with home, then push target on top with optional extra
      RouterManager.router.go(homeRoute);

      // Small delay to ensure home is loaded, then push target
      await Future.delayed(const Duration(milliseconds: 100));

      if (extra != null) {
        RouterManager.router.push(targetPath, extra: extra);
      } else {
        RouterManager.router.push(targetPath);
      }
    } catch (e) {
      log('NotificationController: Error navigating: $e');
      // Fallback: just go to the route directly
      try {
        if (target is String) {
          RouterManager.router.go(target);
        } else if (target is Map) {
          final p = (target['path'] as String?) ?? '';
          final ex = (target['extra'] as Map<String, dynamic>?);
          if (ex != null) {
            RouterManager.router.go(p);
          } else {
            RouterManager.router.go(p);
          }
        }
      } catch (_) {}
    }
  }

  /// Returns the home route based on the current user's type.
  static Future<String> _getHomeRouteForCurrentUser() async {
    return '/projects';
  }

  /// Call this method to navigate to a pending route after app is fully initialized.
  /// Should be called from the app's main widget after the router is ready.
  static Future<void> handlePendingNotificationRoute() async {
    final routeStr = pendingNotificationRoute;
    if (routeStr != null && routeStr.isNotEmpty) {
      pendingNotificationRoute = null;
      log('NotificationController: Handling pending route JSON: $routeStr');
      try {
        final decoded = jsonDecode(routeStr);
        await _navigateWithHomeStack(decoded);
      } catch (e) {
        // fallback: treat as plain route string
        await _navigateWithHomeStack(routeStr);
      }
    }
  }
}
