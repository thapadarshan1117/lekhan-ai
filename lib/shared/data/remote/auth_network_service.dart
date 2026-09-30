
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/config/api/api_configs.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/globals.dart';
import 'package:lekhan_ai/shared/mixins/exception_handler_mixin.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart'
as response;
import 'package:lekhan_ai/shared/data/remote/network_service.dart';



class AuthNetworkService extends NetworkService with ExceptionHandlerMixin {
  final Dio dio;

  AuthNetworkService({required this.dio}) {
    if (!kTestMode) {
      dio.options = dioBaseOptions;
       if (kDebugMode) {
        dio.interceptors.add(LogInterceptor(
          request: true,
          
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (Object object) {
            debugPrint('🌐 Auth LOG: $object');
          },
        
        
        ));
      }
    }
  }

  BaseOptions get dioBaseOptions => BaseOptions(
        baseUrl: baseUrl,
        headers: headers,
        connectTimeout: const Duration(milliseconds: 10000),
      );

  @override
  String get baseUrl => ApiConfigs.baseUrl;

  @override
  Map<String, Object> get headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  @override
  Map<String, dynamic>? updateHeader(Map<String, dynamic> data) {
    final header = {...data, ...headers};
    if (!kTestMode) {
      dio.options.headers = header;
    }
    return header;
  }

  @override
  Future<Either<AppException, response.Response>> post(String endpoint,
      {Map<String, dynamic>? data, Object? formData}) {
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    final result = handleException(
      () => dio.post(
        endpoint,
        data: data,
      ),
      endpoint: endpoint,
    );
    return result;
  }

  @override
  Future<Either<AppException, response.Response>> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) {
    final res = handleException(
      () => dio.get(
        endpoint,
        queryParameters: queryParameters,
      ),
      endpoint: endpoint,
    );
    return res;
  }

  @override
  Future<Either<AppException, response.Response>> postMultipart(String endpoint,
      {Object? data, Map<String, dynamic>? additionalHeaders}) {
    final result = handleException(
      () => dio.post(
        endpoint,
        data: data,
        options: Options(
          headers: {
            ...additionalHeaders ?? {},
          },
        ),
      ),
      endpoint: endpoint,
    );
    return result;
  }

  @override
  Future<Either<AppException, response.Response>> delete(String endpoint,
      {Map<String, dynamic>? data}) {
    final res = handleException(
      () => dio.delete(
        endpoint,
        queryParameters: data,
      ),
      endpoint: endpoint,
    );
    return res;
  }
    @override
        Future<Either<AppException, response.Response>> patch(String endpoint,
            {Map<String, dynamic>? data}) {
          final res = handleException(
            () => dio.patch(
              endpoint,
              data: data,
            ),
            endpoint: endpoint,
          );
          return res;
        }

  @override
  Future<Either<AppException, response.Response>> put(String endpoint,
      {Map<String, dynamic>? data}) {
    final res = handleException(
      () => dio.put(
        endpoint,
        data: data,
      ),
      endpoint: endpoint,
    );
    return res;
  }
    @override
  Future<Either<AppException, response.Response>> putFormData(String endpoint,
      {Map<String, dynamic>? data}) {
    final formData = FormData.fromMap(data ?? {});
    final res = handleException(
      () => dio.put(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      ),
      endpoint: endpoint,
    );
    return res;
  }

  @override
  Future<Either<AppException, response.Response>> putMultipart(String endpoint,
      {Object? data, Map<String, dynamic>? additionalHeaders}) {
    final result = handleException(
      () => dio.put(
        endpoint,
        data: data,
        options: Options(
          headers: {
            ...additionalHeaders ?? {},
          },
        ),
      ),
      endpoint: endpoint,
    );
    return result;
  }

  @override
  Future<Either<AppException, response.Response>> patchMultipart(String endpoint,
      {Object? data, Map<String, dynamic>? additionalHeaders}) {
    final result = handleException(
      () => dio.patch(
        endpoint,
        data: data,
        options: Options(
          headers: {
            ...additionalHeaders ?? {},
          },
        ),
      ),
      endpoint: endpoint,
    );
    return result;
  }
}
