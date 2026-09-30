import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lekhan_ai/shared/data/local/token_storage_service.dart';

class SecureTokenStorageService implements TokenStorageService {
  final String _refreshTokenKey = 'sahara_app_refresh_token_patient';
  final String _accessTokenKey = 'sahara_app_access_token_patient';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> saveAccessToken(String accessToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    debugPrint("Access Token Saved");
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    debugPrint("Refresh Token Saved");
  }

  @override
  Future<String?> getAccessToken() async {
    final val = await _secureStorage.read(key: _accessTokenKey);
    debugPrint("Access Token Retrieved: $val");
    return val;
  }

  @override
  Future<String?> getRefreshToken() async {
    final val = await _secureStorage.read(key: _refreshTokenKey);
    debugPrint("Refresh Token Retrieved: $val");
    return val;
  }

  @override
  Future<void> deleteTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.deleteAll();
  }

  @override
  Future<void> deleteAccessToken() async {
    await _secureStorage.delete(key: _accessTokenKey);
  }
}
