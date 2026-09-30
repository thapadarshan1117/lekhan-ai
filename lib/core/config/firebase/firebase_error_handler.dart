import 'package:flutter/foundation.dart';

/// Firebase error handling utility class
class FirebaseErrorHandler {
  /// Check if error is related to Firebase Installations Service
  static bool isInstallationsError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('firebase installations service') ||
        errorString.contains('installations service is unavailable') ||
        errorString.contains('fis auth token') ||
        errorString.contains('firebaseinstallationsexception');
  }

  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable') ||
        errorString.contains('dns') ||
        errorString.contains('socket');
  }

  /// Check if error is Firebase service unavailable
  static bool isServiceUnavailable(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('service is unavailable') ||
        errorString.contains('service unavailable') ||
        errorString.contains('temporarily unavailable') ||
        errorString.contains('please try again later');
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    if (isInstallationsError(error)) {
      return 'Firebase services are temporarily unavailable. The app will work with limited functionality.';
    } else if (isNetworkError(error)) {
      return 'Network connection issue. Please check your internet connection.';
    } else if (isServiceUnavailable(error)) {
      return 'Service temporarily unavailable. Please try again later.';
    } else {
      return 'An unexpected error occurred. The app will continue to work normally.';
    }
  }

  /// Log error with appropriate level
  static void logError(String context, dynamic error,
      [StackTrace? stackTrace]) {
    if (kDebugMode) {
      final prefix = isInstallationsError(error)
          ? '🔥'
          : isNetworkError(error)
              ? '📶'
              : isServiceUnavailable(error)
                  ? '⚠️'
                  : '❌';

      debugPrint('$prefix Firebase Error in $context: $error');
      if (stackTrace != null && !isInstallationsError(error)) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Check if error should be retried
  static bool shouldRetry(dynamic error) {
    return isNetworkError(error) || isServiceUnavailable(error);
  }

  /// Get retry delay based on attempt number
  static Duration getRetryDelay(int attemptNumber) {
    // Exponential backoff: 2s, 4s, 8s
    return Duration(seconds: 2 << (attemptNumber - 1));
  }
}
