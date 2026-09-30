import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/validation_exception.dart';

class AppException implements Exception {
  final String message;
  final int statusCode;
  final String identifier;
  final Map<String, dynamic>? data;
  final ValidationError? validationErrors;  

  AppException({
    required this.message,
    required this.statusCode,
    required this.identifier,
    this.data,
    this.validationErrors
  });
  
  @override
  String toString() {
    return 'statusCode=$statusCode\nmessage=$message\nidentifier=$identifier';
  }
}

extension HttpExceptionExtension on AppException {
  Left<AppException, Response> get toLeft => Left<AppException, Response>(this);
}
