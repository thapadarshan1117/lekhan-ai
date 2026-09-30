import 'dart:async';
import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:lekhan_ai/core/database/app_database.dart';
import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';

/// Durable work queue that bridges the local database and the server.
///
/// Everything here is written in terms of the [SyncTask] document; the queue
/// itself has no idea what an upload or a chapter is.
abstract class SyncQueue {
  /// Adds a task. Pending duplicates of the same (entity, operation) are
  /// collapsed so a user editing a title five times offline still only pushes
  /// one update.
  Future<void> enqueue(SyncTask task, {bool replacePending = true});

  Future<void> enqueueAll(List<SyncTask> tasks, {bool replacePending = true});

  Future<List<SyncTask>> all();

  /// Due tasks, most urgent first.
  Future<List<SyncTask>> due({int limit = 20, DateTime? now});

  /// Highest priority due task, or null when there is nothing to do.
  Future<SyncTask?> nextDue({DateTime? now});

  Future<SyncTask?> findById(String id);

  Future<SyncTask?> findPending({
    required SyncEntityType entityType,
    required String entityId,
    SyncOperation? operation,
  });

  Future<int> countByStatus(SyncStatus status);

  Future<Map<SyncStatus, int>> counts();

  Future<void> markInProgress(String id, {DateTime? now});

  Future<void> markCompleted(String id, {String? remoteId, DateTime? now});

  Future<void> markFailed(
    String id, {
    required String error,
    Duration? retryAfter,
    bool permanent,
    DateTime? now,
  });

  Future<void> deferTask(
    String id, {
    Duration delay,
    String? reason,
    DateTime? now,
  });

  Future<void> updateProgress(
    String id,
    double progress, {
    int? bytesUploaded,
  });

  Future<void> remove(String id);

  /// Housekeeping: drop completed tasks that are older than [olderThan].
  Future<void> pruneCompleted({Duration olderThan = const Duration(days: 2)});

  /// Anything left `inProgress` after a crash goes back to `pending`.
  Future<void> resetStuck({DateTime? now});

  /// Retries every failed task whose attempt budget is not exhausted.
  Future<int> retryFailed({bool resetAttempts = false});

  /// Puts a single task back in the queue (used by "Retry" in the sync centre).
  Future<void> requeue(String id, {bool resetAttempts = false});

  Future<void> clear();

  /// Emits the full queue on subscribe and after every change.
  Stream<List<SyncTask>> watchAll();
}

class HiveSyncQueue implements SyncQueue {
  HiveSyncQueue({required this.database});

  final AppDatabase database;

  Box<dynamic> get _box => database.box(DatabaseTables.syncQueue);

  @override
  Future<void> enqueue(SyncTask task, {bool replacePending = true}) async {
    if (replacePending) {
      final SyncTask? existing = await findPending(
        entityType: task.entityType,
        entityId: task.entityId,
        operation: task.operation,
      );

      if (existing != null) {
        // Keep the original id and created_at: the work is the same, only the
        // payload got fresher.
        final SyncTask merged = task.copyWith(
          id: existing.id,
          createdAt: existing.createdAt,
          status: SyncStatus.pending,
          attemptCount: existing.attemptCount,
          updatedAt: DateTime.now(),
        );
        await _put(merged);
        return;
      }

      // A queued create that is deleted again never reached the server: drop
      // both and leave nothing behind.
      if (task.operation == SyncOperation.delete) {
        final SyncTask? pendingCreate = await findPending(
          entityType: task.entityType,
          entityId: task.entityId,
          operation: SyncOperation.create,
        );
        if (pendingCreate != null) {
          log(
            'HiveSyncQueue: collapsed create+delete for '
            '${task.entityType.value}/${task.entityId}',
          );
          await remove(pendingCreate.id);
          return;
        }
      }
    }

    await _put(task);
  }

  @override
  Future<void> enqueueAll(
    List<SyncTask> tasks, {
    bool replacePending = true,
  }) async {
    for (final SyncTask task in tasks) {
      await enqueue(task, replacePending: replacePending);
    }
  }

  @override
  Future<List<SyncTask>> all() async {
    return _readAll(_box.values);
  }

  @override
  Future<List<SyncTask>> due({int limit = 20, DateTime? now}) async {
    final DateTime reference = now ?? DateTime.now();
    final List<SyncTask> tasks = await all();
    final List<SyncTask> ready = tasks
        .where((SyncTask task) => task.isDue(reference))
        .toList()
      ..sort((SyncTask a, SyncTask b) {
        final int byPriority = a.orderKey.compareTo(b.orderKey);
        if (byPriority != 0) return byPriority;
        return a.createdAt.compareTo(b.createdAt);
      });
    return ready.take(limit).toList();
  }

  @override
  Future<SyncTask?> nextDue({DateTime? now}) async {
    final List<SyncTask> ready = await due(limit: 1, now: now);
    return ready.isEmpty ? null : ready.first;
  }

  @override
  Future<SyncTask?> findById(String id) async {
    final dynamic value = _box.get(id);
    if (value == null) return null;
    return SyncTask.fromJson(JsonUtils.asMap(value));
  }

  @override
  Future<SyncTask?> findPending({
    required SyncEntityType entityType,
    required String entityId,
    SyncOperation? operation,
  }) async {
    final List<SyncTask> tasks = await all();
    for (final SyncTask task in tasks) {
      if (task.entityType != entityType) continue;
      if (task.entityId != entityId) continue;
      if (operation != null && task.operation != operation) continue;
      if (!task.status.isOpen) continue;
      return task;
    }
    return null;
  }

  @override
  Future<int> countByStatus(SyncStatus status) async {
    final List<SyncTask> tasks = await all();
    return tasks.where((SyncTask task) => task.status == status).length;
  }

  @override
  Future<Map<SyncStatus, int>> counts() async {
    final List<SyncTask> tasks = await all();
    final Map<SyncStatus, int> result = <SyncStatus, int>{
      for (final SyncStatus status in SyncStatus.values) status: 0,
    };
    for (final SyncTask task in tasks) {
      result[task.status] = (result[task.status] ?? 0) + 1;
    }
    return result;
  }

  @override
  Future<void> markInProgress(String id, {DateTime? now}) async {
    await _mutate(id, (SyncTask task) => task.onStarted(now ?? DateTime.now()));
  }

  @override
  Future<void> markCompleted(
    String id, {
    String? remoteId,
    DateTime? now,
  }) async {
    await _mutate(
      id,
      (SyncTask task) => task.onSucceeded(
        now ?? DateTime.now(),
        remoteId: remoteId,
      ),
    );
  }

  @override
  Future<void> markFailed(
    String id, {
    required String error,
    Duration? retryAfter,
    bool permanent = false,
    DateTime? now,
  }) async {
    await _mutate(
      id,
      (SyncTask task) => task.onFailed(
        error,
        now ?? DateTime.now(),
        retryAfter: retryAfter,
        permanent: permanent,
      ),
    );
  }

  @override
  Future<void> deferTask(
    String id, {
    Duration delay = const Duration(minutes: 15),
    String? reason,
    DateTime? now,
  }) async {
    await _mutate(id, (SyncTask task) {
      final SyncTask deferred =
          task.onDeferred(now ?? DateTime.now(), delay: delay);
      if (reason == null) return deferred;
      return deferred.copyWith(errorMessage: reason);
    });
  }

  @override
  Future<void> updateProgress(
    String id,
    double progress, {
    int? bytesUploaded,
  }) async {
    await _mutate(
      id,
      (SyncTask task) => task.withProgress(progress, bytesUploaded: bytesUploaded),
    );
  }

  @override
  Future<void> remove(String id) => _box.delete(id);

  @override
  Future<void> pruneCompleted({
    Duration olderThan = const Duration(days: 2),
  }) async {
    final DateTime cutoff = DateTime.now().subtract(olderThan);
    final List<SyncTask> tasks = await all();
    for (final SyncTask task in tasks) {
      if (task.status == SyncStatus.completed && task.updatedAt.isBefore(cutoff)) {
        await _box.delete(task.id);
      }
    }
  }

  @override
  Future<void> resetStuck({DateTime? now}) async {
    final DateTime reference = now ?? DateTime.now();
    final List<SyncTask> tasks = await all();
    for (final SyncTask task in tasks) {
      if (task.status == SyncStatus.inProgress) {
        final SyncTask fixed = task.copyWith(
          status: SyncStatus.pending,
          nextRetryAt: reference,
          updatedAt: reference,
        );
        await _put(fixed);
      }
    }
  }

  @override
  Future<int> retryFailed({bool resetAttempts = false}) async {
    final List<SyncTask> tasks = await all();
    int retried = 0;
    for (final SyncTask task in tasks) {
      if (task.status != SyncStatus.failed) continue;
      if (!resetAttempts && !task.canRetry) continue;
      await requeue(task.id, resetAttempts: resetAttempts);
      retried++;
    }
    return retried;
  }

  @override
  Future<void> requeue(String id, {bool resetAttempts = false}) async {
    final SyncTask? task = await findById(id);
    if (task == null) return;

    final DateTime now = DateTime.now();
    await _put(
      SyncTask(
        id: task.id,
        entityType: task.entityType,
        entityId: task.entityId,
        operation: task.operation,
        remoteId: task.remoteId,
        payload: task.payload,
        status: SyncStatus.pending,
        attemptCount: resetAttempts ? 0 : task.attemptCount,
        maxAttempts: task.maxAttempts,
        priority: task.priority,
        totalBytes: task.totalBytes,
        bytesUploaded: task.bytesUploaded,
        progress: task.progress,
        lastAttemptAt: task.lastAttemptAt,
        nextRetryAt: null,
        errorMessage: null,
        createdAt: task.createdAt,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> clear() => _box.clear();

  @override
  Stream<List<SyncTask>> watchAll() async* {
    yield await all();
    await for (final _ in _box.watch()) {
      yield await all();
    }
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<void> _put(SyncTask task) => _box.put(task.id, task.toJson());

  Future<void> _mutate(
    String id,
    SyncTask Function(SyncTask task) transform,
  ) async {
    final SyncTask? current = await findById(id);
    if (current == null) return;
    await _put(transform(current));
  }

  List<SyncTask> _readAll(Iterable<dynamic> values) {
    return values
        .map<Map<String, dynamic>>((dynamic value) => JsonUtils.asMap(value))
        .where((Map<String, dynamic> value) => value.isNotEmpty)
        .map<SyncTask>((Map<String, dynamic> value) => SyncTask.fromJson(value))
        .where((SyncTask task) => task.id.isNotEmpty)
        .toList();
  }
}
