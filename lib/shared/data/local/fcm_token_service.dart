import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMTokenService {
  static const String _key = 'fcmToken';
    bool _refreshListenerAttached = false;


  FCMTokenService._internal();
  static final FCMTokenService _instance = FCMTokenService._internal();
  factory FCMTokenService() => _instance;

  /// Save FCM token
  Future<void> writeFCMToken(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, fcmToken);
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// Delete FCM token
  Future<void> deleteFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

    Future<String?> getOrCreateToken() async {
    final existing = await getFCMToken();
    if (existing != null && existing.isNotEmpty) {
      print('🔔 FCM Token (from cache): $existing');
      return existing;
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await writeFCMToken(token);
        print('🔔 FCM Token (freshly generated): $token');
      } else {
        _attachOnTokenRefresh();
      }
      return token;
    } catch (_) {
      // Swallow and let caller decide retry strategy
      _attachOnTokenRefresh();
      return null;
    }
  }

    void _attachOnTokenRefresh() {
    if (_refreshListenerAttached) return;
    _refreshListenerAttached = true;
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (newToken.isNotEmpty) {
        await writeFCMToken(newToken);
        print('🔔 FCM Token Refreshed: $newToken');
      }
    });
  }
}
