import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class EnhancedLogInterceptor extends Interceptor {
  final bool logRequest;
  final bool logResponse;
  final bool logError;
  final bool logHeaders;
  final bool logBody;
  final int maxBodyLength;

  EnhancedLogInterceptor({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
    this.logHeaders = true,
    this.logBody = true,
    this.maxBodyLength = 1000,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequest) {
      _logRequest(options);
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logResponse) {
      _logResponse(response);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logError) {
      _logError(err);
    }
    super.onError(err, handler);
  }

  void _logRequest(RequestOptions options) {
    debugPrint('');
    debugPrint('🚀 ===== REQUEST =====');
    debugPrint('🚀 ${options.method} ${options.uri}');
    
    if (logHeaders && options.headers.isNotEmpty) {
      debugPrint('🚀 Headers:');
      options.headers.forEach((key, value) {
        if (key.toLowerCase().contains('auth') || key.toLowerCase().contains('token')) {
          debugPrint('   $key: [HIDDEN]');
        } else {
          debugPrint('   $key: $value');
        }
      });
    }
    
    if (logBody && options.data != null) {
      final bodyString = options.data.toString();
      if (bodyString.length > maxBodyLength) {
        debugPrint('🚀 Body: ${bodyString.substring(0, maxBodyLength)}...[TRUNCATED]');
      } else {
        debugPrint('🚀 Body: $bodyString');
      }
    }
    debugPrint('🚀 ==================');
    debugPrint('');
  }

  void _logResponse(Response response) {
    debugPrint('');
    debugPrint('✅ ===== RESPONSE =====');
    debugPrint('✅ ${response.statusCode} ${response.requestOptions.uri}');
    
    if (logHeaders ) {
      debugPrint('✅ Headers:');
      response.headers.forEach((key, values) {
        debugPrint('   $key: ${values.join(', ')}');
      });
    }
    
    if (logBody && response.data != null) {
      final bodyString = response.data.toString();
      if (bodyString.length > maxBodyLength) {
        debugPrint('✅ Body: ${bodyString.substring(0, maxBodyLength)}...[TRUNCATED]');
      } else {
        debugPrint('✅ Body: $bodyString');
      }
    }
    debugPrint('✅ ====================');
    debugPrint('');
  }

  void _logError(DioException err) {
    debugPrint('');
    debugPrint('❌ ===== ERROR =====');
    debugPrint('❌ ${err.type} ${err.requestOptions.uri}');
    debugPrint('❌ Message: ${err.message}');
    
    if (err.response != null) {
      debugPrint('❌ Status: ${err.response?.statusCode}');
      if (logBody && err.response?.data != null) {
        debugPrint('❌ Error Body: ${err.response?.data}');
      }
    }
    debugPrint('❌ ==================');
    debugPrint('');
  }
}