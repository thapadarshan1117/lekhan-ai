import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Per-change verdict returned by `POST /sync/push`.
class SyncChangeResult {
  const SyncChangeResult({
    required this.localId,
    this.remoteId,
    this.status,
    this.error,
  });

  final String localId;

  /// Server id of the record, once it exists remotely.
  final String? remoteId;

  /// `accepted`, `rejected`, `conflict`, ...
  final String? status;
  final String? error;

  /// Anything that is not explicitly a rejection counts as accepted, so an
  /// older backend that answers `200 null` still works.
  bool get isAccepted {
    final String? value = status?.toLowerCase();
    if (value == null || value.isEmpty) return true;
    return value == 'accepted' ||
        value == 'ok' ||
        value == 'success' ||
        value == 'created' ||
        value == 'updated';
  }

  bool get isConflict => status?.toLowerCase() == 'conflict';

  factory SyncChangeResult.fromJson(Map<String, dynamic> json) {
    return SyncChangeResult(
      localId: JsonUtils.asString(
        json['local_id'],
        fallback: JsonUtils.asString(json['localId']),
      ),
      remoteId: JsonUtils.asStringOrNull(
        json['remote_id'] ?? json['remoteId'],
      ),
      status: JsonUtils.asStringOrNull(json['status']),
      error: JsonUtils.asStringOrNull(json['error'] ?? json['message']),
    );
  }
}

class SyncPushResponse {
  const SyncPushResponse({required this.results, this.serverTime});

  final List<SyncChangeResult> results;
  final DateTime? serverTime;

  SyncChangeResult? resultFor(String localId) {
    for (final SyncChangeResult result in results) {
      if (result.localId == localId) return result;
    }
    return null;
  }

  factory SyncPushResponse.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> raw = JsonUtils.asMapList(
      json['results'] ?? json['changes'] ?? json['data'],
    );
    return SyncPushResponse(
      results: raw.map<SyncChangeResult>(SyncChangeResult.fromJson).toList(),
      serverTime: JsonUtils.asDateTime(json['server_time']),
    );
  }
}

class SyncPullResponse {
  const SyncPullResponse({
    required this.changes,
    this.deletedIds = const <String>[],
    this.serverTime,
  });

  final List<Map<String, dynamic>> changes;
  final List<String> deletedIds;
  final DateTime? serverTime;

  factory SyncPullResponse.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> raw = JsonUtils.asMapList(
      json['changes'] ?? json['results'] ?? json['data'],
    );

    final List<String> deleted = <String>[];
    for (final Map<String, dynamic> change in raw) {
      if (JsonUtils.asBool(change['is_deleted']) ||
          JsonUtils.asBool(change['deleted'])) {
        final String id = JsonUtils.asString(change['id']);
        if (id.isNotEmpty) deleted.add(id);
      }
    }

    return SyncPullResponse(
      changes: raw,
      deletedIds: deleted,
      serverTime: JsonUtils.asDateTime(json['server_time']),
    );
  }
}

abstract class SyncRemoteDataSource {
  /// Pushes a batch of local changes.
  Future<Either<AppException, SyncPushResponse>> pushChanges({
    required List<Map<String, dynamic>> changes,
  });

  /// Pulls everything that changed on the server since [since].
  Future<Either<AppException, SyncPullResponse>> pullChanges({
    DateTime? since,
    List<String>? entityTypes,
    int page,
  });

  /// Backend view of the queue: useful before a pull to know whether it is
  /// worth doing at all.
  Future<Either<AppException, Map<String, dynamic>>> fetchStatus();
}

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  const SyncRemoteDataSourceImpl({required this.networkService});

  final NetworkService networkService;

  static const String _identifier = 'SyncRemoteDataSourceImpl';

  @override
  Future<Either<AppException, SyncPushResponse>> pushChanges({
    required List<Map<String, dynamic>> changes,
  }) async {
    try {
      final Either<AppException, Response> response = await networkService.post(
        ApiConstants.syncPush,
        data: <String, dynamic>{'changes': changes},
      );

      return response.fold(
        (AppException exception) =>
            Left<AppException, SyncPushResponse>(exception),
        (Response result) {
          final Map<String, dynamic> data = JsonUtils.asMap(result.data);
          return Right<AppException, SyncPushResponse>(
            SyncPushResponse.fromJson(data),
          );
        },
      );
    } catch (error) {
      return Left<AppException, SyncPushResponse>(
        FailureMapper.from(error, identifier: '$_identifier.pushChanges'),
      );
    }
  }

  @override
  Future<Either<AppException, SyncPullResponse>> pullChanges({
    DateTime? since,
    List<String>? entityTypes,
    int page = 1,
  }) async {
    try {
      final Either<AppException, Response> response = await networkService.post(
        ApiConstants.syncPull,
        data: <String, dynamic>{
          if (since != null) 'since': since.toUtc().toIso8601String(),
          if (entityTypes != null && entityTypes.isNotEmpty)
            'entity_types': entityTypes,
          'p': page,
        },
      );

      return response.fold(
        (AppException exception) =>
            Left<AppException, SyncPullResponse>(exception),
        (Response result) {
          final Map<String, dynamic> data = JsonUtils.asMap(result.data);
          return Right<AppException, SyncPullResponse>(
            SyncPullResponse.fromJson(data),
          );
        },
      );
    } catch (error) {
      return Left<AppException, SyncPullResponse>(
        FailureMapper.from(error, identifier: '$_identifier.pullChanges'),
      );
    }
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> fetchStatus() async {
    try {
      final Either<AppException, Response> response =
          await networkService.get(ApiConstants.syncStatus);

      return response.fold(
        (AppException exception) =>
            Left<AppException, Map<String, dynamic>>(exception),
        (Response result) => Right<AppException, Map<String, dynamic>>(
          JsonUtils.asMap(result.data),
        ),
      );
    } catch (error) {
      return Left<AppException, Map<String, dynamic>>(
        FailureMapper.from(error, identifier: '$_identifier.fetchStatus'),
      );
    }
  }
}
