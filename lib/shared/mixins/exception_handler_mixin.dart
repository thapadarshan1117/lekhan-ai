import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart'
    as response
    show Response;
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/exceptions/validation_exception.dart';

mixin ExceptionHandlerMixin on NetworkService {
  Future<Either<AppException, response.Response>>
  handleException<T extends Object>(
    Future<Response<dynamic>> Function() handler, {
    String endpoint = '',
  }) async {
    try {
      final res = await handler();
      return Right(
        response.Response(
          statusCode: res.statusCode ?? 200,
          data: res.data,
          statusMessage: res.statusMessage,
        ),
      );
    } catch (e) {
      String message = '';
      String identifier = '';
      ValidationError? validationErrors;

      int statusCode = 0;
      Map<String, dynamic> data = {};
      switch (e.runtimeType) {
        case const (SocketException):
          e as SocketException;
          message = 'Unable to connect to the server.';
          statusCode = 0;
          identifier = 'Socket Exception ${e.message}\n at  $endpoint';
          break;

        case const (DioException):
          e as DioException;

          if (e.response?.statusCode == 422) {
            debugPrint('Validation Error ${e.message}\n at  $endpoint');
            message =
                _extractValidationMessageFromData(e.response?.data) ??
                _extractMessage(e) ??
                'Invalid data provided. Please check your input.';
            statusCode = 422;
            identifier = 'Validation Error ${e.message}\n at  $endpoint';

            final dynamic validationRaw = _extractValidationPayload(
              e.response?.data,
            );
            if (validationRaw is Map<String, dynamic>) {
              validationErrors = ValidationError.fromJson(validationRaw);
            } else if (validationRaw is Map) {
              validationErrors = ValidationError.fromJson(
                validationRaw.cast<String, dynamic>(),
              );
            }

            break;
          }
          message = getDioErrorMessage(e);
          statusCode = e.response?.statusCode ?? 1;
          identifier = 'DioException ${e.message} \nat  $endpoint';
          data = e.response?.statusCode == 403 ? e.response?.data : {};
          break;

        default:
          message = 'Unknown error occurred';
          statusCode = 2;
          identifier = 'Unknown error ${e.toString()}\n at $endpoint';
      }
      return Left(
        AppException(
          message: message,
          statusCode: statusCode,
          identifier: identifier,
          data: data,
          validationErrors: validationErrors,
        ),
      );
    }
  }

  String getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet and try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond. Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badResponse:
        return _handleHttpStatusCodes(e);
      case DioExceptionType.badCertificate:
        return 'Security certificate error. Please try again later.';
      default:
        return _extractMessage(e) ?? 'Something went wrong. Please try again.';
    }
  }

  /// Safely extract message from common API error payload shapes.
  String? _extractMessage(DioException e) {
    return _extractMessageFromData(e.response?.data);
  }

  String? _extractMessageFromData(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      final normalized = data.trim();
      if (normalized.isEmpty) return null;

      // Some APIs return JSON encoded as text.
      try {
        final decoded = jsonDecode(normalized);
        return _extractMessageFromData(decoded) ?? normalized;
      } catch (_) {
        return normalized;
      }
    }

    // Handles payloads like ["Invalid email or password"].
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is String && first.trim().isNotEmpty) {
        return first.trim();
      }
      return _extractMessageFromData(first) ?? first.toString();
    }

    if (data is Map) {
      final directMessage = _firstNonEmptyString([
        data['message'],
        data['detail'],
        data['error'],
      ]);
      if (directMessage != null) return directMessage;

      final nonFieldMessage = _extractMessageFromData(data['non_field_errors']);
      if (nonFieldMessage != null && nonFieldMessage.isNotEmpty) {
        return nonFieldMessage;
      }

      final errorsMessage = _extractMessageFromData(data['errors']);
      if (errorsMessage != null && errorsMessage.isNotEmpty) {
        return errorsMessage;
      }

      // Fallback for nested field errors like:
      // {"old_password": {"old_password": "Your current password doesn't match."}}
      final nestedFieldMessage = _extractFirstNestedMessage(data.values);
      if (nestedFieldMessage != null && nestedFieldMessage.isNotEmpty) {
        return nestedFieldMessage;
      }
    }

    return null;
  }

  String? _extractValidationMessageFromData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final dynamic error = data['error'];
      final fromError = _extractValidationMessageFromError(error);
      if (fromError != null && fromError.isNotEmpty) {
        return fromError;
      }

      final dynamic errors = data['errors'];
      final fromErrors = _extractValidationMessageFromError(errors);
      if (fromErrors != null && fromErrors.isNotEmpty) {
        return fromErrors;
      }
    }

    return null;
  }

  String? _extractValidationMessageFromError(dynamic error) {
    if (error == null) return null;

    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }

    if (error is List) {
      for (final item in error) {
        if (item is Map) {
          final msg = item['msg']?.toString().trim();
          if (msg != null && msg.isNotEmpty) {
            return msg;
          }
        }

        final nested = _extractValidationMessageFromError(item);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
      return null;
    }

    if (error is Map) {
      final directMessage = _firstNonEmptyString([
        error['msg'],
        error['message'],
        error['detail'],
      ]);
      if (directMessage != null) return directMessage;

      for (final value in error.values) {
        final nested = _extractValidationMessageFromError(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
  }

  String? _firstNonEmptyString(List<dynamic> candidates) {
    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return null;
  }

  String? _extractFirstNestedMessage(Iterable<dynamic> values) {
    for (final value in values) {
      final nestedMessage = _extractMessageFromData(value);
      if (nestedMessage != null && nestedMessage.isNotEmpty) {
        return nestedMessage;
      }
    }
    return null;
  }

  dynamic _extractValidationPayload(dynamic data) {
    if (data is! Map) return null;

    final dynamic errors = data['errors'];
    if (errors != null) return errors;

    final dynamic error = data['error'];
    if (error is List) {
      final Map<String, List<String>> mapped = <String, List<String>>{};
      for (final item in error) {
        if (item is! Map) continue;
        final key = item['path']?.toString();
        final msg = item['msg']?.toString();
        if (key == null || key.isEmpty || msg == null || msg.isEmpty) continue;
        mapped.putIfAbsent(key, () => <String>[]).add(msg);
      }
      return mapped.isEmpty ? null : mapped;
    }

    return error;
  }

  String _handleHttpStatusCodes(DioException e) {
    final statusCode = e.response?.statusCode;
    final serverMessage = _extractMessage(e);

    switch (statusCode) {
      // Major 4xx Client Errors - User needs to take action
      case 400:
        return serverMessage ??
            'Invalid request. Please check your input and try again.';
      case 401:
        return serverMessage ?? 'Session expired. Please login again.';
      case 403:
        return serverMessage ??
            'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return serverMessage ?? 'The requested item was not found.';
      case 422:
        return serverMessage ??
            'Invalid data provided. Please check your input.';
      case 429:
        return serverMessage ??
            'Too many requests. Please wait a moment and try again.';

      // Major 5xx Server Errors - Server issues
      case 500:
        return 'Server error occurred. Please try again later.';
      case 502:
        return 'Service temporarily unavailable. Please try again later.';
      case 503:
        return 'Service is currently down for maintenance. Please try again later.';
      case 504:
        // Don’t parse message here — always fallback
        return 'Server timeout. Please try again later.';

      // General category-based errors for other codes
      default:
        if (statusCode != null) {
          if (statusCode >= 400 && statusCode < 500) {
            return serverMessage ??
                'Request error. Please check your input and try again.';
          } else if (statusCode >= 500 && statusCode < 600) {
            return serverMessage ?? 'Server error. Please try again later.';
          } else if (statusCode >= 300 && statusCode < 400) {
            return serverMessage ?? 'Redirect error. Please try again.';
          }
        }
        return serverMessage ?? 'Something went wrong. Please try again later.';
    }
  }
}
