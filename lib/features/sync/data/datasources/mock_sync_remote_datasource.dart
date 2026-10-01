import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/mock/mock_lekhan_backend.dart';
import 'package:lekhan_ai/features/sync/data/datasources/sync_remote_datasource.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// UI-only sync endpoint implementation. It accepts and pulls the same change
/// envelope as the API datasource, but all state stays in [MockLekhanBackend].
class MockSyncRemoteDataSource implements SyncRemoteDataSource {
  const MockSyncRemoteDataSource({required this.backend});

  final MockLekhanBackend backend;
  static const String _identifier = 'MockSyncRemoteDataSource';

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
      final List<Map<String, dynamic>> results =
          await backend.pushChanges(changes);
      return Right<AppException, SyncPushResponse>(
        SyncPushResponse.fromJson(<String, dynamic>{
          'results': results,
          'server_time': DateTime.now().toUtc().toIso8601String(),
        }),
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
      final int requestedPage =
          int.tryParse(cursor ?? '') ?? (page < 1 ? 1 : page);
      final Map<String, dynamic> envelope = await backend.pullChanges(
        since: since,
        page: requestedPage,
        pageSize: pageSize,
      );
      if (entityTypes == null || entityTypes.isEmpty) {
        return Right<AppException, SyncPullResponse>(
          SyncPullResponse.fromJson(envelope),
        );
      }

      final Set<String> allowed = entityTypes
          .map<String>((String type) => type.toLowerCase())
          .toSet();
      final List<Map<String, dynamic>> changes =
          (envelope['changes'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .where((Map<String, dynamic> change) => allowed.contains(
                    (change['entity_type'] ?? '').toString().toLowerCase(),
                  ))
              .toList(growable: false);
      return Right<AppException, SyncPullResponse>(
        SyncPullResponse.fromJson(<String, dynamic>{
          ...envelope,
          'changes': changes,
        }),
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
      return Right<AppException, Map<String, dynamic>>(
        await backend.fetchStatus(),
      );
    } catch (error) {
      return Left<AppException, Map<String, dynamic>>(
        FailureMapper.from(error, identifier: '$_identifier.fetchStatus'),
      );
    }
  }
}
