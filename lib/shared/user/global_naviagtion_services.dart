import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

class GlobalNavigationService {
  static GlobalNavigationService? _instance;
  static GlobalNavigationService get instance => _instance ??= GlobalNavigationService._();
  
  GlobalNavigationService._();
  
  // Global navigator key (should match your router configuration)
  static final GlobalKey<NavigatorState> navigatorKey = 
      GlobalKey<NavigatorState>(debugLabel: 'root');
  
  String? _pendingRoute;
  Map<String, dynamic>? _pendingParams;
  bool _isAppReady = false;
  
  void markAppReady() {
    _isAppReady = true;
    log('🚀 GlobalNavigationService: App marked as ready');
    _processPendingNavigation();
  }
  
  bool get isAppReady => _isAppReady;
  
  /// Navigate to a specific route with optional parameters
  Future<bool> navigateTo(String route, {Map<String, dynamic>? params}) async {
    try {
      log('📍 GlobalNavigationService: Request to navigate to $route with params: $params');
      
      if (_canNavigateNow()) {
        return _performNavigation(route, params ?? {});
      } else {
        // Queue for later
        _pendingRoute = route;
        _pendingParams = params;
        log('📌 GlobalNavigationService: Navigation queued for when app is ready');
        
        // Try again after delays
        _scheduleRetries();
        return false;
      }
    } catch (e) {
      log('❌ GlobalNavigationService: Navigation error: $e');
      return false;
    }
  }
  
  void _scheduleRetries() {
    // Multiple retry attempts with increasing delays
    final delays = [100, 500, 1000, 2000, 5000]; // milliseconds
    
    for (int i = 0; i < delays.length; i++) {
      Future.delayed(Duration(milliseconds: delays[i]), () {
        if (_pendingRoute != null && _canNavigateNow()) {
          _processPendingNavigation();
        }
      });
    }
  }
  
  bool _canNavigateNow() {
    if (!_isAppReady) {
      log('🚫 GlobalNavigationService: App not ready');
      return false;
    }
    
    try {
      // Check if we have a valid navigator context
      final context = navigatorKey.currentContext;
      if (context != null) {
        final router = GoRouter.maybeOf(context);
        if (router != null) {
          log('✅ GlobalNavigationService: Router available');
          return true;
        }
      }
      
      // Check if navigator state is available
      if (navigatorKey.currentState != null) {
        log('✅ GlobalNavigationService: Navigator state available');
        return true;
      }
      
      log('🚫 GlobalNavigationService: No valid navigation context');
      return false;
    } catch (e) {
      log('❌ GlobalNavigationService: Error checking navigation readiness: $e');
      return false;
    }
  }
  
  void _processPendingNavigation() {
    if (_pendingRoute != null) {
      final route = _pendingRoute!;
      final params = _pendingParams ?? {};
      
      _pendingRoute = null;
      _pendingParams = null;
      
      log('🔄 GlobalNavigationService: Processing pending navigation to $route');
      _performNavigation(route, params);
    }
  }
  
  bool _performNavigation(String route, Map<String, dynamic> params) {
    try {
      final context = navigatorKey.currentContext;
      
      if (context != null) {
        final router = GoRouter.maybeOf(context);
        if (router != null) {
          if (params.isNotEmpty) {
            router.go(route, extra: params);
          } else {
            router.go(route);
          }
          log('✅ GlobalNavigationService: Successfully navigated to $route using router');
          return true;
        }
      }
      
      // Fallback to navigator state
      final navigatorState = navigatorKey.currentState;
      if (navigatorState != null && context != null) {
        final router = GoRouter.maybeOf(context);
        if (router != null) {
          if (params.isNotEmpty) {
            router.go(route, extra: params);
          } else {
            router.go(route);
          }
          log('✅ GlobalNavigationService: Successfully navigated to $route using navigator state');
          return true;
        }
      }
      
      log('❌ GlobalNavigationService: No valid router context for navigation');
      return false;
      
    } catch (e) {
      log('❌ GlobalNavigationService: Navigation failed: $e');
      return false;
    }
  }
  
  /// Navigate to route based on notification type
  Future<bool> navigateForNotificationType(String notificationType, {Map<String, dynamic>? data}) async {
    final route = _getRouteForNotificationType(notificationType);
    if (route == null) {
      log('⚠️ GlobalNavigationService: No route found for notification type: $notificationType');
      return false;
    }
    
    final params = _buildNavigationParams(notificationType, data ?? {});
    return navigateTo(route, params: params);
  }
  
  String? _getRouteForNotificationType(String notificationType) {
    switch (notificationType.toLowerCase()) {
      case 'assignment':
        return '/assignment';
      case 'announcement':
        return '/student-notifications';
      case 'grade':
        return '/assignment';
      case 'attendance':
        return '/student-attendance';
      case 'event':
      case 'holiday':
        return '/student-notifications'; // Fallback
      case 'fee':
        return '/student-notifications'; // Fallback
      case 'exam':
      case 'result':
        return '/student-academic-record';
      default:
        return null;
    }
  }
  
  Map<String, dynamic> _buildNavigationParams(String notificationType, Map<String, dynamic> data) {
    Map<String, dynamic> params = {};

    switch (notificationType.toLowerCase()) {
      case 'assignment':
      case 'grade':
        if (data.containsKey('assignment_id')) {
          params['assignmentId'] = data['assignment_id'];
        }
        if (data.containsKey('subject_id')) {
          params['subjectId'] = data['subject_id'];
        }
        break;

      case 'announcement':
        if (data.containsKey('announcement_id')) {
          params['announcementId'] = data['announcement_id'];
        }
        break;

      case 'attendance':
        if (data.containsKey('date')) {
          params['date'] = data['date'];
        }
        if (data.containsKey('class_id')) {
          params['classId'] = data['class_id'];
        }
        break;

      case 'event':
      case 'holiday':
        if (data.containsKey('event_id')) {
          params['eventId'] = data['event_id'];
        }
        if (data.containsKey('date')) {
          params['date'] = data['date'];
        }
        break;

      case 'fee':
        if (data.containsKey('fee_id')) {
          params['feeId'] = data['fee_id'];
        }
        if (data.containsKey('due_date')) {
          params['dueDate'] = data['due_date'];
        }
        break;

      case 'exam':
      case 'result':
        if (data.containsKey('exam_id')) {
          params['examId'] = data['exam_id'];
        }
        if (data.containsKey('result_id')) {
          params['resultId'] = data['result_id'];
        }
        if (data.containsKey('subject_id')) {
          params['subjectId'] = data['subject_id'];
        }
        break;
    }

    // Add common parameters
    if (data.containsKey('user_id')) {
      params['userId'] = data['user_id'];
    }

    return params;
  }
  
  void clearPendingNavigation() {
    _pendingRoute = null;
    _pendingParams = null;
  }
}