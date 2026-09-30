import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';



abstract class NetworkService {
  String get baseUrl;
  Map<String, Object> get headers;
  void updateHeader(Map<String, dynamic> data);

  Future<Either<AppException, Response>> get(
    String endpoint, {
    
    Map<String, dynamic>? queryParameters,


  });

  Future<Either<AppException, Response>> post(
    String endpoint, {
    Map<String, dynamic>? data,
  });

  Future<Either<AppException, Response>> postMultipart(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? additionalHeaders,
  });

  Future<Either<AppException, Response>> put(
    String endpoint, {
    Map<String, dynamic>? data,
  });
   Future<Either<AppException, Response>> patch(
    String endpoint, {
    Map<String, dynamic>? data,
  });

  Future<Either<AppException, Response>> putFormData(
    String endpoint, {
    Map<String, dynamic>? data,
  });

  Future<Either<AppException, Response>> putMultipart(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? additionalHeaders,
  });

  Future<Either<AppException, Response>> patchMultipart(
    String endpoint, {
    Object? data,
    Map<String, dynamic>? additionalHeaders,
  });

  Future<Either<AppException, Response>> delete(
    String endpoint, {
    Map<String, dynamic>? data,
  });
}
