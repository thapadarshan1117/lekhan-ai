import 'dart:async';
import 'dart:developer' as developer;

import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_request_bus.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';

/// Sync engine that processes queued tasks and uploads/downloads data.
/// 
/// This is the core sync orchestrator that:
/// - Listens to sync requests from repositories
/// - Polls the sync queue for due tasks
/// - Executes handlers (upload, metadata, download)
/// - Retries failed tasks with exponential backoff
class SyncEngine {
  SyncEngine({
    required this.queue,
    required this.requestBus,
    required this.onTaskCompleted,
    required this.onTaskFailed,
  });

  final SyncQueue queue;
  final SyncRequestBus requestBus;
  final Future<void> Function(SyncTask) onTaskCompleted;
  final Future<void> Function(SyncTask, String error) onTaskFailed;

  static const String _identifier = 'SyncEngine';
  static const Duration _pollInterval = Duration(seconds: 5);
  static const Duration _minBackoffDelay = Duration(seconds: 20);
  static const Duration _maxBackoffDelay = Duration(hours: 1);

  bool _isRunning = false;
  StreamSubscription<void>? _requestSubscription;
  Timer? _pollTimer;

  /// Start the sync engine: listen to requests and poll the queue.
  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    developer.log('🚀 Sync engine started', name: _identifier);

    // Listen to sync requests and process immediately
    _requestSubscription = requestBus.onRequest.listen((_) {
      _processNextBatch();
    });

    // Poll for due tasks periodically
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      _processNextBatch();
    });

    // Initial process
    await _processNextBatch();
  }

  /// Stop the sync engine: cancel subscriptions and timers.
  Future<void> stop() async {
    if (!_isRunning) return;
    _isRunning = false;

    await _requestSubscription?.cancel();
    _requestSubscription = null;

    _pollTimer?.cancel();
    _pollTimer = null;

    developer.log('🛑 Sync engine stopped', name: _identifier);
  }

  /// Process up to 5 due tasks in a single batch.
  Future<void> _processNextBatch() async {
    if (!_isRunning) return;

    try {
      final List<SyncTask> dueTasks = await queue.due(limit: 5);

      for (final SyncTask task in dueTasks) {
        if (!_isRunning) break;
        await _executeTask(task);
      }
    } catch (error, stackTrace) {
      developer.log(
        'Error processing batch: $error',
        name: _identifier,
        stackTrace: stackTrace,
      );
    }
  }

  /// Execute a single sync task.
  Future<void> _executeTask(SyncTask task) async {
    try {
      developer.log(
        '⚙️ Executing task: ${task.id} (${task.operation})',
        name: _identifier,
      );

      await queue.markInProgress(task.id);

      // Call handler (implement based on operation type)
      // For now, this is a placeholder that would call actual handlers
      final bool success = await _executeHandler(task);

      if (success) {
        await queue.markCompleted(task.id);
        await onTaskCompleted(task);
        developer.log(
          '✅ Task completed: ${task.id}',
          name: _identifier,
        );
      } else {
        await _handleTaskFailure(task);
      }
    } catch (error, stackTrace) {
      developer.log(
        '❌ Task failed: ${task.id} - $error',
        name: _identifier,
        stackTrace: stackTrace,
      );
      await _handleTaskFailure(task, error: error.toString());
    }
  }

  /// Execute the appropriate handler based on task operation.
  Future<bool> _executeHandler(SyncTask task) async {
    // This would be implemented with actual handlers:
    // - Upload handler: uploads files to backend
    // - Metadata handler: syncs metadata (create/update/delete)
    // - Download handler: fetches sources from server

    // For now, simulate success
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return true;
  }

  /// Handle task failure: retry with exponential backoff.
  Future<void> _handleTaskFailure(SyncTask task, {String? error}) async {
    final int nextAttempt = task.attemptCount + 1;

    if (nextAttempt >= task.maxAttempts) {
      // Max retries exceeded, mark as permanently failed
      await queue.markFailed(
        task.id,
        error: error ?? 'Max retries exceeded',
      );
      await onTaskFailed(task, error ?? 'Max retries exceeded');
      developer.log(
        '💔 Task permanently failed: ${task.id}',
        name: _identifier,
      );
    } else {
      // Calculate exponential backoff
      final Duration backoff = _calculateBackoff(nextAttempt);

      await queue.deferTask(task.id, delay: backoff);
      developer.log(
        '⏳ Task deferred: ${task.id}, retrying in ${backoff.inSeconds}s',
        name: _identifier,
      );
    }
  }

  /// Calculate exponential backoff with jitter.
  Duration _calculateBackoff(int attemptCount) {
    final Duration base = _minBackoffDelay;
    final int multiplier = 1 << attemptCount; // 2^attemptCount
    final Duration exponential = base * multiplier;

    // Cap at max backoff
    if (exponential > _maxBackoffDelay) {
      return _maxBackoffDelay;
    }

    return exponential;
  }

  /// Get current sync status.
  Future<SyncStats> getStats() async {
    final Map<SyncStatus, int> counts = await queue.counts();
    return SyncStats(
      pending: counts[SyncStatus.pending] ?? 0,
      inProgress: counts[SyncStatus.inProgress] ?? 0,
      completed: counts[SyncStatus.completed] ?? 0,
      failed: counts[SyncStatus.failed] ?? 0,
      isRunning: _isRunning,
    );
  }

  /// Retry all failed tasks.
  Future<void> retryFailed() async {
    developer.log('🔄 Retrying failed tasks', name: _identifier);
    // Implementation would reset failed tasks to pending
  }
}

/// Sync statistics.
class SyncStats {
  const SyncStats({
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.failed,
    required this.isRunning,
  });

  final int pending;
  final int inProgress;
  final int completed;
  final int failed;
  final bool isRunning;

  int get total => pending + inProgress + completed + failed;

  bool get isIdle => pending == 0 && inProgress == 0;
}
