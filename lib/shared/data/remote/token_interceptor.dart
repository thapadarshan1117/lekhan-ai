import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decode_full/jwt_decode_full.dart';
import 'package:lekhan_ai/core/config/api/api_configs.dart';
import 'package:lekhan_ai/core/router/route_manager.dart';
import 'package:lekhan_ai/shared/data/local/token_storage_service.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_repository.dart';



class TokenInterceptor extends QueuedInterceptorsWrapper {
  final Dio dio;
  final TokenStorageService tokenStorageService;
  final UserRepository userRepository;

  static Future<Response?>? _refreshTokenRequest;
  static const int _tokenExpiryThreshold = 5; // Refresh before 5 seconds
  static bool _isRefreshing = false; // Prevent multiple refresh attempts
  static bool _isHandlingSessionExpiration =
      false; // Prevent multiple session expiration handling

  TokenInterceptor(this.dio, this.tokenStorageService, this.userRepository);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final accessToken = await tokenStorageService.getAccessToken();
      debugPrint(
          '🔑 Request to: ${options.path} with token: ${accessToken != null ? 'Present' : 'None'}');

      if (accessToken == null) {
        _handleNoToken(options, handler);
        return;
      }

      if (_shouldRefreshToken(accessToken)) {
        debugPrint('🔄 Token expired, refreshing...');
        await _handleTokenRefresh();
        final newToken = await tokenStorageService.getAccessToken();

        if (newToken == null) {
          _handleNoToken(options, handler);
          return;
        }

        options.headers['Authorization'] = 'Bearer $newToken';
      } else {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      handler.next(options);
    } catch (error, stackTrace) {
      debugPrint('❌ Error in onRequest: $error\n$stackTrace');
      handler.reject(DioException(
        requestOptions: options,
        error: error,
        type: DioExceptionType.unknown,
      ));
    }
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // Log the error for debugging
    debugPrint(
        '🔴 Error for ${err.requestOptions.path}: ${err.response?.statusCode}');

    if (!_isTokenExpiredError(err)) {
      handler.next(err);
      return;
    }

    debugPrint(
        '🔴 401 Unauthorized - Attempting token refresh for ${err.requestOptions.path}');

    try {
      // First check if we have a refresh token
      final refreshToken = await tokenStorageService.getRefreshToken();
      if (refreshToken == null) {
        debugPrint('⚠️ No refresh token available for 401 response');
        await _handleSessionExpiration();
        handler.next(err);
        return;
      }

      // Try to refresh and retry
      final response = await _retryRequestWithNewToken(err.requestOptions);
      handler.resolve(response);
    } catch (error) {
      // Log the specific error when token refresh fails
      debugPrint('❌ Token refresh failed: $error');

      // If it's a 401 even after refresh, handle session expiration
      if (error is DioException && _isTokenExpiredError(error)) {
        await _handleSessionExpiration();
      }

      handler.reject(err);
    }
  }

  bool _shouldRefreshToken(String token) {
    try {
      final decodedToken = jwtDecode(token);
      final expiration = decodedToken.payload['exp'];

      if (expiration == null) return true;

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
        (expiration as num).toInt() * 1000,
      );

      final shouldRefresh = DateTime.now().isAfter(
        expirationTime.subtract(const Duration(seconds: _tokenExpiryThreshold)),
      );

      debugPrint(
          '🕒 Token expiration: ${expirationTime.toLocal()}. Should refresh: $shouldRefresh');
      return shouldRefresh;
    } catch (e) {
      debugPrint('❌ Error decoding token: $e');
      return true; // If decoding fails, assume the token is invalid
    }
  }

  Future<void> _handleTokenRefresh() async {
    if (_isRefreshing) {
      debugPrint('🔄 Token refresh already in progress');
      try {
        // Wait for the existing refresh operation to complete
        await _refreshTokenRequest;
      } catch (e) {
        debugPrint('Error waiting for refresh: $e');
      }
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await tokenStorageService.getRefreshToken();
      debugPrint(
          'Refresh Token Retrieved: ${refreshToken != null ? '${refreshToken.substring(0, min(20, refreshToken.length))}...' : 'null'}');

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('! No refresh token available');
        throw Exception('No refresh token available');
      }

      _refreshTokenRequest = _refreshToken(refreshToken);
      final response = await _refreshTokenRequest;

      if (response == null) {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConfigs.getAccessToken),
          error: 'Token refresh failed - No response data',
          type: DioExceptionType.unknown,
        );
      }

      if (response.data == null) {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConfigs.getAccessToken),
          error: 'Token refresh failed - Empty response data',
          type: DioExceptionType.badResponse,
        );
      }

      final newToken = response.data?['data']['access'];

      if (newToken == null) {
        throw DioException(
          requestOptions: RequestOptions(path: ApiConfigs.getAccessToken),
          error: 'Token refresh failed - No access token in response',
        );
      }

      await tokenStorageService.saveAccessToken(newToken);
      debugPrint('✅ New access token saved successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error in _handleTokenRefresh: $e\n$stackTrace');
      await _handleSessionExpiration();
      rethrow; // Re-throw to let caller handle it
    } finally {
      _refreshTokenRequest = null;
      _isRefreshing = false;
    }
  }

  Future<Response?> _refreshToken(String refreshToken) async {
    try {
      debugPrint('🔄 Refreshing token...');
      log('Refresh Token: $refreshToken');

      // Create a separate Dio instance for token refresh
      final refreshDio = Dio();

      // Use the correct URL format combining base URL and path
      final refreshUrl = ApiConfigs.baseUrl + ApiConfigs.getAccessToken;
      debugPrint('Refresh URL: $refreshUrl');

      final response = await refreshDio.post(
        refreshUrl,
        data: {'refresh': refreshToken},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true, // Don't throw for any status code
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      debugPrint(
          'Token refresh response: Status ${response.statusCode}, Data: ${response.data}');

      if (response.statusCode == 200) {
        debugPrint('✅ Token refresh successful');
        return response;
      } else {
        debugPrint('❌ Token refresh failed: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException during refresh: ${e.type.name}');
      if (e.error != null) {
        debugPrint('Error details: ${e.error}');
      }
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error during refresh: $e\n$stackTrace');
      return null;
    }
  }

  Future<Response<dynamic>> _retryRequestWithNewToken(
      RequestOptions requestOptions) async {
    try {
      await _handleTokenRefresh();
      final newToken = await tokenStorageService.getAccessToken();

      if (newToken == null) {
        throw DioException(
          requestOptions: requestOptions,
          error: 'Could not refresh token',
          type: DioExceptionType.unknown,
        );
      }

      // Create a new options object with the new token
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
      debugPrint('🔄 Retrying request with new token: ${requestOptions.path}');

      return dio.fetch(requestOptions);
    } catch (e) {
      debugPrint('Failed to retry request: $e');
      rethrow;
    }
  }

  Future<void> _handleSessionExpiration() async {
    // Prevent multiple session expiration handling
    if (_isHandlingSessionExpiration) {
      return;
    }

    _isHandlingSessionExpiration = true;
    debugPrint('🔴 Session expired - Logging out user');

    try {
      await Future.wait([
        tokenStorageService.deleteTokens(),
        userRepository.deleteUser(),
      ]).timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint('⚠️ Timeout while handling session expiration');
        return Future.error('Timeout while handling session expiration');
      });

      // Clear interceptors to stop further requests

      // Navigate to login page
      RouterManager.router.go('/login');
    } catch (e) {
      debugPrint('❌ Error during session expiration handling: $e');
      // Even if cleanup fails, try to navigate to login
      RouterManager.router.go('/login');
    } finally {
      _isHandlingSessionExpiration = false;
    }
  }

  void _handleNoToken(
      RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('⚠️ No access token available for: ${options.path}');

    // Add a delay before navigation to prevent rapid redirects
    Future.delayed(const Duration(milliseconds: 100), () {
      RouterManager.router.go('/login');
    });

    handler.reject(DioException(
      requestOptions: options,
      type: DioExceptionType.unknown,
      error: 'No access token available',
    ));
  }

  bool _isTokenExpiredError(DioException error) {
    return error.response?.statusCode == 401;
  }
}

// Helper function for string safety
int min(int a, int b) {
  return a < b ? a : b;
}
