import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// Where a failure came from. Lets the UI decide whether a retry makes sense.
enum FailureSource { network, server, local, validation, unknown }

/// Error codes used by everything that fails *before* or *around* the network.
///
/// The HTTP-shaped codes intentionally mirror real status codes so that a
/// single `switch (exception.statusCode)` in the UI keeps working.
class LocalErrorCodes {
  const LocalErrorCodes._();

  /// Generic local failure (file system, Hive, ...).
  static const int localFailure = 1;

  /// Hive / box level failure.
  static const int databaseFailure = 2;

  /// Local record does not exist (or was deleted under us).
  static const int notFound = 404;

  /// Not allowed to do this (permission denied, missing grant).
  static const int permissionDenied = 403;

  /// The file is larger than the 500 MB rule.
  static const int fileTooLarge = 413;

  /// Extension / mime type is not accepted.
  static const int unsupportedMedia = 415;

  /// Nothing to sync with: no connection, or sync is disabled.
  static const int noConnection = 503;

  /// Timed out locally (hashing, copying, waiting on a lock).
  static const int timeout = 408;

  /// Payload could not be parsed into a model.
  static const int invalidPayload = 422;

  /// Sync engine level failure (worker, queue, handler).
  static const int syncFailure = 500;
}

extension AppExceptionFailureSource on AppException {
  /// Classifies an exception so callers can react without string matching.
  FailureSource get source {
    switch (statusCode) {
      case LocalErrorCodes.noConnection:
      case LocalErrorCodes.timeout:
        return FailureSource.network;
      case 400:
      case 401:
      case 402:
      case 403:
      case 404:
      case 405:
      case 409:
      case 410:
      case 429:
        return FailureSource.server;
      case LocalErrorCodes.invalidPayload:
        return FailureSource.validation;
      case LocalErrorCodes.localFailure:
      case LocalErrorCodes.databaseFailure:
      case LocalErrorCodes.permissionDenied:
      case LocalErrorCodes.fileTooLarge:
      case LocalErrorCodes.unsupportedMedia:
      case LocalErrorCodes.syncFailure:
        return FailureSource.local;
      default:
        if (statusCode >= 500) return FailureSource.server;
        return FailureSource.unknown;
    }
  }

  /// Retryable problems are the ones a later attempt can realistically fix.
  bool get isRetryable {
    if (validationErrors != null) return false;
    switch (statusCode) {
      case LocalErrorCodes.noConnection:
      case LocalErrorCodes.timeout:
      case LocalErrorCodes.localFailure:
      case LocalErrorCodes.databaseFailure:
      case LocalErrorCodes.syncFailure:
      case 408:
      case 429:
      case 500:
      case 502:
      case 503:
      case 504:
        return true;
      default:
        return false;
    }
  }

  /// True when the user's session is gone and the app should sign out.
  bool get isUnauthorized => statusCode == 401;
}
