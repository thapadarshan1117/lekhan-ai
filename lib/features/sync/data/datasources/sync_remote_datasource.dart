import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/core/utils/remote_json_utils.dart';
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
  final String? remoteId;
  final String? status;
  final String? error;

  /// Never assume an empty/malformed response means success. Missing
  /// confirmation must keep the local outbox task retryable.
  bool get isAccepted {
    final String? value = status?.trim().toLowerCase();
    if (value == null || value.isEmpty) return remoteId?.isNotEmpty == true;
    return const <String>{'accepted', 'ok', 'success', 'created', 'updated'}
        .contains(value);
  }

  bool get isConflict => status?.trim().toLowerCase() == 'conflict';

  factory SyncChangeResult.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = RemoteJsonUtils.record(json);
    return SyncChangeResult(
      localId: JsonUtils.asString(
        data['local_id'] ?? data['localId'] ?? data['client_id'],
      ),
      remoteId: JsonUtils.asStringOrNull(
        data['remote_id'] ?? data['remoteId'] ?? data['server_id'] ?? data['id'],
      ),
      status: JsonUtils.asStringOrNull(data['status']),
      error: JsonUtils.asStringOrNull(
        data['error'] ?? data['message'] ?? data['detail'],
      ),
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
    final Map<String, dynamic> data = RemoteJsonUtils.record(json);
    final dynamic raw =
        data['results'] ?? data['changes'] ?? data['items'] ?? data['data'];
    return SyncPushResponse(
      results: RemoteJsonUtils.records(raw ?? data)
          .map<SyncChangeResult>(SyncChangeResult.fromJson)
          .toList(growable: false),
      serverTime: JsonUtils.asDateTime(
        data['server_time'] ?? data['serverTime'],
      ),
    );
  }
}

class SyncPullResponse {
  const SyncPullResponse({
    required this.changes,
    this.deletedIds = const <String>[],
    this.serverTime,
    this.nextCursor,
    this.nextPage,
    this.hasMore = false,
  });

  final List<Map<String, dynamic>> changes;
  final List<String> deletedIds;
  final DateTime? serverTime;
  final String? nextCursor;
  final int? nextPage;
  final bool hasMore;

  factory SyncPullResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = RemoteJsonUtils.record(json);
    final dynamic raw =
        data['changes'] ?? data['results'] ?? data['items'] ?? data['data'];
    final List<Map<String, dynamic>> changes = <Map<String, dynamic>>[];

    if (raw != null) {
      changes.addAll(RemoteJsonUtils.records(raw));
    } else {
      // Also accept a resource-grouped pull envelope while the backend and
      // mobile sync endpoints converge on the canonical `changes` format.
      for (final MapEntry<String, String> entry in <MapEntry<String, String>>[
        const MapEntry<String, String>('projects', 'project'),
        const MapEntry<String, String>('books', 'book'),
        const MapEntry<String, String>('chapters', 'chapter'),
        const MapEntry<String, String>('sources', 'chapter_source'),
        const MapEntry<String, String>('chapter_sources', 'chapter_source'),
        const MapEntry<String, String>('deleted', ''),
      ]) {
        for (final Map<String, dynamic> record
            in RemoteJsonUtils.records(data[entry.key])) {
          changes.add(<String, dynamic>{
            if (entry.value.isNotEmpty) 'entity_type': entry.value,
            'operation': entry.key == 'deleted' ? 'delete' : 'update',
            'payload': record,
            if (entry.key == 'deleted') ...record,
          });
        }
      }
      if (changes.isEmpty &&
          (data.containsKey('entity_type') ||
              data.containsKey('entityType') ||
              data.containsKey('entity') ||
              data.containsKey('type')) &&
          RemoteJsonUtils.remoteId(data).isNotEmpty) {
        changes.add(data);
      }
    }

    final List<String> deleted = <String>[];
    deleted.addAll(
      JsonUtils.asStringList(data['deleted_ids'] ?? data['deletedIds'])
          .where((String id) => id.isNotEmpty),
    );
    for (final Map<String, dynamic> change in changes) {
      if (JsonUtils.asBool(change['is_deleted'] ?? change['deleted']) ||
          JsonUtils.asString(change['operation']).toLowerCase() == 'delete') {
        final String id = RemoteJsonUtils.remoteId(<String, dynamic>{
          ...change,
          ...RemoteJsonUtils.record(
            change['payload'] ?? change['data'] ?? change,
          ),
        });
        if (id.isNotEmpty) deleted.add(id);
      }
    }

    final String? cursor = JsonUtils.asStringOrNull(
      data['next_cursor'] ?? data['nextCursor'],
    );
    final int? page = JsonUtils.asIntOrNull(
      data['next_page'] ?? data['nextPage'],
    );
    final Map<String, dynamic> pagination =
        JsonUtils.asMap(data['pagination']);
    return SyncPullResponse(
      changes: changes,
      deletedIds: deleted.toSet().toList(growable: false),
      serverTime: JsonUtils.asDateTime(
        data['server_time'] ?? data['serverTime'],
      ),
      nextCursor: cursor,
      nextPage: page,
      hasMore: JsonUtils.asBool(
        data['has_more'] ??
            data['hasMore'] ??
            pagination['has_more'] ??
            pagination['hasMore'],
        fallback: cursor != null || page != null,
      ),
    );
  }
}

abstract class SyncRemoteDataSource {
  Future<Either<AppException, SyncPushResponse>> pushChanges({
    required List<Map<String, dynamic>> changes,
  });

  Future<Either<AppException, SyncPullResponse>> pullChanges({
    DateTime? since,
    List<String>? entityTypes,
    required int page,
    int pageSize = 100,
    String? cursor,
  });

  Future<Either<AppException, Map<String, dynamic>>> fetchStatus();
}

/// Real API implementation. The sync queue remains local and durable; only the
/// changes selected by its worker are sent to the authenticated backend.
class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  const SyncRemoteDataSourceImpl({required this.networkService});

  final NetworkService networkService;

  static const String _identifier = 'SyncRemoteDataSourceImpl';

  @override
  Future<Either<AppException, SyncPushResponse>> pushChanges({
    required List<Map<String, dynamic>> changes,
  }) async {
    if (changes.isEmpty) {
      return const Right<AppException, SyncPushResponse>(
        SyncPushResponse(results: <SyncChangeResult>[]),
      );
    }

    try {
      final Either<AppException, Response> result = await networkService.post(
        ApiConstants.syncPush,
        data: <String, dynamic>{'changes': changes},
      );
      return result.fold(
        (AppException error) => Left<AppException, SyncPushResponse>(error),
        (Response response) => Right<AppException, SyncPushResponse>(
          SyncPushResponse.fromJson(
            RemoteJsonUtils.record(response.data),
          ),
        ),
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
    int pageSize = 100,
    String? cursor,
  }) async {
    try {
      final Either<AppException, Response> result = await networkService.post(
        ApiConstants.syncPull,
        data: <String, dynamic>{
          if (since != null) 'since': since.toUtc().toIso8601String(),
          if (entityTypes != null) 'entity_types': entityTypes,
          'page': page,
          'page_size': pageSize,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      return result.fold(
        (AppException error) => Left<AppException, SyncPullResponse>(error),
        (Response response) => Right<AppException, SyncPullResponse>(
          SyncPullResponse.fromJson(
            RemoteJsonUtils.record(response.data),
          ),
        ),
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
      final Either<AppException, Response> result =
          await networkService.get(ApiConstants.syncStatus);
      return result.fold(
        (AppException error) => Left<AppException, Map<String, dynamic>>(error),
        (Response response) => Right<AppException, Map<String, dynamic>>(
          RemoteJsonUtils.record(response.data),
        ),
      );
    } catch (error) {
      return Left<AppException, Map<String, dynamic>>(
        FailureMapper.from(error, identifier: '$_identifier.fetchStatus'),
      );
    }
  }
}
