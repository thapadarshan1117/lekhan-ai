import 'package:dio/dio.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/exceptions/validation_exception.dart';

/// Converts anything that can go wrong into the single error type the app
/// already speaks: [AppException] from `shared/exceptions/http_exception.dart`.
///
/// Note: this deliberately does *not* introduce a second `AppException` class
/// under `core/error`. Every datasource, repository and use case in this
/// project already returns `Either<AppException, T>`, so a parallel hierarchy
/// would force conversions at every boundary for no benefit. What was missing
/// was a single mapper for the non-HTTP paths (file system, Hive, permissions,
/// sync worker) - that is what this class provides.
class FailureMapper {
  const FailureMapper._();

  /// Wraps an arbitrary error/exception coming from local code.
  static AppException local(
    Object error, {
    required String identifier,
    String? message,
    int statusCode = LocalErrorCodes.localFailure,
  }) {
    return AppException(
      message: message ?? _cleanMessage(error) ?? 'Something went wrong',
      statusCode: statusCode,
      identifier: identifier,
      data: <String, dynamic>{'error': error.toString(), 'source': 'local'},
    );
  }

  /// Wraps an arbitrary error/exception coming from the network layer.
  static AppException from(
    Object error, {
    required String identifier,
    String? message,
    int statusCode = LocalErrorCodes.localFailure,
  }) {
    if (error is AppException) return error;
    if (error is DioException) {
      return fromDio(error, identifier: identifier);
    }
    return local(
      error,
      identifier: identifier,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Translates a Dio failure into a user-presentable [AppException].
  static AppException fromDio(
    DioException error, {
    required String identifier,
  }) {
    final int statusCode = _statusCodeFor(error);
    final Response<dynamic>? response = error.response;
    final dynamic payload = response?.data;

    String message =
        _messageFromPayload(payload) ??
        _messageForType(error.type) ??
        error.message ??
        'Something went wrong';

    ValidationError? validationErrors;
    if (error.type == DioExceptionType.badResponse) {
      validationErrors = _validationErrorsFrom(payload);
    }

    return AppException(
      message: message,
      statusCode: statusCode,
      identifier: identifier,
      data: <String, dynamic>{
        if (payload is Map) 'body': payload,
        'type': error.type.name,
        if (error.requestOptions.uri.toString().isNotEmpty)
          'url': error.requestOptions.uri.toString(),
      },
      validationErrors: validationErrors,
    );
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  static int _statusCodeFor(DioException error) {
    final int? fromResponse = error.response?.statusCode;
    if (fromResponse != null && fromResponse > 0) return fromResponse;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return LocalErrorCodes.timeout;

      case DioExceptionType.connectionError:
        return LocalErrorCodes.noConnection;

      case DioExceptionType.cancel:
        return LocalErrorCodes.localFailure;

      case DioExceptionType.badCertificate:
        return LocalErrorCodes.noConnection;

      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return LocalErrorCodes.noConnection;
    }
  }

  static String? _messageForType(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'The connection timed out. Please try again.';

      case DioExceptionType.sendTimeout:
        return 'Upload timed out. It will resume where it stopped.';

      case DioExceptionType.receiveTimeout:
        return 'The server took too long to respond.';

      case DioExceptionType.transformTimeout:
        return 'Processing timed out. Please try again.';

      case DioExceptionType.connectionError:
        return 'You appear to be offline. Your work is stored safely on this device.';

      case DioExceptionType.badCertificate:
        return 'The server certificate could not be verified.';

      case DioExceptionType.cancel:
        return 'The request was cancelled.';

      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return null;
    }
  }

  /// Digs a human message out of the many shapes a backend may answer with.
  static String? _messageFromPayload(dynamic payload) {
    if (payload == null) return null;
    if (payload is String) {
      final String trimmed = payload.trim();
      if (trimmed.isEmpty) return null;
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) return null;
      return trimmed;
    }
    if (payload is Map) {
      final Map<dynamic, dynamic> map = payload;
      for (final String key in <String>[
        'message',
        'detail',
        'error',
        'error_description',
        'non_field_errors',
      ]) {
        final dynamic value = map[key];
        if (value == null) continue;
        if (value is String && value.trim().isNotEmpty) return value;
        if (value is List && value.isNotEmpty) return value.first.toString();
      }
      // Django-style { "field": ["msg"] } validation envelope.
      final Map<String, dynamic>? errors = _errorMap(map);
      if (errors != null && errors.isNotEmpty) {
        final List<String> messages = <String>[];
        for (final dynamic value in errors.values) {
          if (value is List && value.isNotEmpty) {
            messages.add(value.first.toString());
          } else if (value is String && value.isNotEmpty) {
            messages.add(value);
          }
        }
        if (messages.isNotEmpty) return messages.first;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _errorMap(Map<dynamic, dynamic> payload) {
    for (final String key in <String>['errors', 'data']) {
      final dynamic value = payload[key];
      if (value is Map && value.isNotEmpty) {
        return value.map<String, dynamic>(
          (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
        );
      }
    }
    return null;
  }

  static ValidationError? _validationErrorsFrom(dynamic payload) {
    if (payload is! Map) return null;
    final Map<String, dynamic>? raw = _errorMap(payload);
    if (raw == null) return null;

    final Map<String, List<String>> errors = <String, List<String>>{};
    raw.forEach((String key, dynamic value) {
      if (value is List) {
        errors[key] = value
            .map<String>((dynamic item) => item.toString())
            .toList();
      } else if (value is String) {
        errors[key] = <String>[value];
      }
    });

    if (errors.isEmpty) return null;
    return ValidationError(errors: errors);
  }

  static String? _cleanMessage(Object error) {
    final String raw = error.toString();
    if (raw.isEmpty) return null;
    if (raw.length > 300) return '${raw.substring(0, 300)}...';
    return raw;
  }
}
