
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CustomLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('*** Request ***');
    debugPrint('URI: ${options.uri}');
    debugPrint('Method: ${options.method}');
    debugPrint('Headers: ${options.headers}');
    debugPrint('Data: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('*** Response ***');
    debugPrint('URI: ${response.requestOptions.uri}');
    debugPrint('Status Code: ${response.statusCode}');
    // debugPrint('Headers: ${response.headers}');

    if (kDebugMode) {
      debugPrint('Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('*** Error ***');
    debugPrint('URI: ${err.requestOptions.uri}');
    debugPrint('Message: ${err.message}');
    if (err.response != null) {
      debugPrint('Status Code: ${err.response?.statusCode}');
      debugPrint('Headers: ${err.response?.headers}');
      if (kDebugMode) {
        debugPrint('Data: ${err.response?.data ?? ''}');
      }
    }
    handler.next(err);
  }
}
