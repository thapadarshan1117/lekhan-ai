import 'dart:developer';

import 'package:lekhan_ai/core/sync/sync_pull_runner.dart';
import 'package:lekhan_ai/core/sync/sync_state.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/sync/data/datasources/sync_remote_datasource.dart';
import 'package:lekhan_ai/features/sync/data/services/sync_pull_applier.dart';

/// Pulls a bounded sequence of incremental changes and applies parent records
/// before children. A successful page is not checkpointed until the entire
/// pull succeeds, so a crash safely replays idempotent updates on next launch.
class SyncPullService implements SyncPullRunner {
  const SyncPullService({
    required this.remote,
    required this.applier,
    required this.checkpointStore,
    this.pageSize = 100,
    this.maxPages = 100,
  });

  final SyncRemoteDataSource remote;
  final SyncPullApplier applier;
  final SyncCheckpointStore checkpointStore;
  final int pageSize;
  final int maxPages;

  @override
  Future<String?> pull() async {
    try {
      final DateTime? since = await checkpointStore.lastPulledAt();
      final List<Map<String, dynamic>> changes = <Map<String, dynamic>>[];
      DateTime? serverTime;
      String? cursor;
      int page = 1;
      bool hasMore = true;
      int pagesRead = 0;

      while (hasMore && pagesRead < maxPages) {
        final result = await remote.pullChanges(
          since: since,
          page: page,
          pageSize: pageSize,
          cursor: cursor,
          entityTypes: const <String>[
            'project',
            'book',
            'chapter',
            'chapter_source',
            'progress',
          ],
        );
        final SyncPullResponse? response = result.valueOrNull;
        if (response == null) {
          return result.errorOrNull?.message ?? 'Could not download server changes.';
        }

        changes.addAll(response.changes);
        serverTime = response.serverTime ?? serverTime;
        cursor = response.nextCursor;
        page = response.nextPage ?? (page + 1);
        hasMore = response.hasMore;
        pagesRead++;
      }

      if (hasMore) {
        return 'There are more server changes than one sync pass can process. Try syncing again.';
      }

      changes.sort(_compareChanges);
      for (final Map<String, dynamic> change in changes) {
        await applier.apply(change);
      }

      await checkpointStore.markPulled(serverTime ?? DateTime.now());
      return null;
    } catch (error, stackTrace) {
      log('SyncPullService.pull failed', error: error, stackTrace: stackTrace);
      return 'Could not apply the latest server changes.';
    }
  }

  static int _compareChanges(
    Map<String, dynamic> first,
    Map<String, dynamic> second,
  ) {
    final int byEntity = _rank(first).compareTo(_rank(second));
    if (byEntity != 0) return byEntity;

    final DateTime firstUpdated = _updatedAt(first);
    final DateTime secondUpdated = _updatedAt(second);
    return firstUpdated.compareTo(secondUpdated);
  }

  static int _rank(Map<String, dynamic> change) {
    final String entity = JsonUtils.asString(
      change['entity_type'] ??
          change['entityType'] ??
          change['entity'] ??
          change['resource_type'] ??
          change['type'],
    ).toLowerCase();
    if (entity == 'project' || entity == 'projects') return 0;
    if (entity == 'book' || entity == 'books') return 1;
    if (entity == 'chapter' || entity == 'chapters') return 2;
    if (entity == 'chapter_source' || entity == 'source' || entity == 'sources') {
      return 3;
    }
    return 4;
  }

  static DateTime _updatedAt(Map<String, dynamic> change) {
    final Map<String, dynamic> data = JsonUtils.asMap(
      change['payload'] ?? change['data'],
    );
    return JsonUtils.asDateTime(
          data['updated_at'] ??
              data['updatedAt'] ??
              change['updated_at'] ??
              change['updatedAt'] ??
              change['timestamp'],
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
