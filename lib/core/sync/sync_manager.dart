import 'dart:async';
import 'dart:developer';

import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/network/network_info.dart';
import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_state.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';
import 'package:lekhan_ai/core/sync/sync_worker.dart';
import 'package:lekhan_ai/core/sync/sync_pull_runner.dart';

/// Orchestrates everything that leaves the device.
///
/// Responsibilities, in order:
///  1. know when to run (startup, network restored, background wake-up, manual),
///  2. decide what may run now (network class, user preferences, backoff),
///  3. hand tasks to the [SyncWorker] one at a time,
///  4. keep the queue and the observable [SyncState] honest about the result.
///
/// It never talks HTTP itself, and it never touches a feature. That is what
/// makes it reusable for metadata, uploads and future entity types alike.
class SyncManager {
  SyncManager({
    required this.queue,
    required this.worker,
    required this.networkInfo,
    required this.preferences,
    required this.checkpointStore,
    this.pullRunner,
    this.isAuthorized,
    int maxTasksPerRun = 50,
    int maxConsecutiveFailures = 3,
  })  : _maxTasksPerRun = maxTasksPerRun,
        _maxConsecutiveFailures = maxConsecutiveFailures;

  final SyncQueue queue;
  final SyncWorker worker;
  final NetworkInfo networkInfo;
  final SyncPreferences preferences;
  final SyncCheckpointStore checkpointStore;
  final SyncPullRunner? pullRunner;
  final Future<bool> Function()? isAuthorized;

  final int _maxTasksPerRun;
  final int _maxConsecutiveFailures;

  final StreamController<SyncState> _stateController =
      StreamController<SyncState>.broadcast();

  StreamSubscription<NetworkQuality>? _networkSubscription;
  Timer? _progressTicker;

  SyncState _state = const SyncState.initial();
  bool _isRunning = false;
  int _consecutiveFailures = 0;
  String? _activeTaskId;
  SyncTrigger? _queuedTrigger;
  Completer<void>? _activeRunCompletion;
  bool _paused = false;

  // ---------------------------------------------------------------------------
  // Observable state
  // ---------------------------------------------------------------------------

  Stream<SyncState> watchStatus() => statusStream;

  Stream<SyncState> get statusStream => _stateController.stream;

  SyncState get currentState => _state;

  bool get isRunning => _isRunning;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Wires the triggers. Call once, after `AppDatabase` and the local store are
  /// ready. Does not start a sync by itself - [sync] does that.
  Future<void> start() async {
    await _refresh();

    _networkSubscription ??= networkInfo.onQualityChanged.listen(
      (NetworkQuality quality) {
        if (quality.isOnline) {
          unawaited(sync(trigger: SyncTrigger.networkRestored));
        } else {
          unawaited(_handleOffline(quality));
        }
      },
    );
  }

  /// One full pass over the queue. Safe to call from anywhere; concurrent calls
  /// collapse into the running pass.
  Future<void> sync({SyncTrigger trigger = SyncTrigger.manual}) async {
    if (_paused) return;
    if (!await _authorizationAvailable()) {
      await _refresh(trigger: trigger);
      return;
    }
    if (_isRunning) {
      // Writes/network events that arrive during a pass must not be lost: run
      // one more pass after the active one has checkpointed.
      _queuedTrigger = trigger;
      log('SyncManager: queued ${trigger.value} behind the active pass');
      return;
    }

    _isRunning = true;
    final Completer<void> completion = Completer<void>();
    _activeRunCompletion = completion;
    _consecutiveFailures = 0;

    await _emit(
      _state.copyWith(
        status: SyncConnectionStatus.syncing,
        isSyncing: true,
        trigger: trigger,
        clearActiveTask: true,
        clearMessage: true,
        updatedAt: DateTime.now(),
      ),
    );

    try {
      await queue.resetStuck();
      await _drain();

      // Local writes are push-only; startup, manual refresh, network restore,
      // and background opportunities also fetch server-owned changes.
      if (trigger != SyncTrigger.push &&
          pullRunner != null &&
          await _authorizationAvailable()) {
        final NetworkQuality quality = await networkInfo.currentQuality();
        if (quality.isOnline) {
          final String? pullError = await pullRunner!.pull();
          if (pullError != null) {
            await checkpointStore.setLastError(pullError);
          } else if (await queue.countByStatus(SyncStatus.failed) == 0) {
            await checkpointStore.setLastError(null);
          }
        }
      }
    } catch (error) {
      log('SyncManager: run failed ($error)');
      await checkpointStore.setLastError(error.toString());
    } finally {
      _progressTicker?.cancel();
      _progressTicker = null;
      _activeTaskId = null;
      try {
        await _refresh(trigger: trigger);
      } finally {
        _isRunning = false;
        if (identical(_activeRunCompletion, completion)) {
          _activeRunCompletion = null;
        }
        if (!completion.isCompleted) completion.complete();

        final SyncTrigger? queued = _queuedTrigger;
        _queuedTrigger = null;
        if (queued != null && !_paused) unawaited(sync(trigger: queued));
      }
    }
  }

  /// Stops scheduling new queue work and waits for the active task to reach a
  /// safe checkpoint. Logout uses this before clearing account-owned local data.
  Future<void> pause() async {
    _paused = true;
    _queuedTrigger = null;
    final Completer<void>? active = _activeRunCompletion;
    if (active != null) await active.future;
  }

  /// Re-enables work after a failed logout or after a new account is prepared.
  void resume() {
    _paused = false;
  }

  /// Runs just the tasks belonging to one record - used right after a user
  /// action, so a single chapter can be pushed without waiting for a full pass.
  Future<void> syncEntity({
    required String entityId,
    SyncEntityType? entityType,
  }) async {
    if (_paused || !await _authorizationAvailable()) return;
    final NetworkQuality quality = await networkInfo.currentQuality();
    if (!quality.isOnline) {
      await _refresh();
      return;
    }

    final List<SyncTask> candidates = await queue.due(limit: _maxTasksPerRun);
    final List<SyncTask> mine = candidates
        .where((SyncTask task) =>
            task.entityId == entityId &&
            (entityType == null || task.entityType == entityType))
        .toList();

    for (final SyncTask task in mine) {
      await _runTask(task);
    }

    await _refresh();
  }

  /// "Retry failed" in the sync centre.
  Future<void> retryFailed({bool resetAttempts = false}) async {
    await queue.retryFailed(resetAttempts: resetAttempts);
    await _refresh();
    await sync(trigger: SyncTrigger.manual);
  }

  /// Retry a single queue item.
  Future<void> retryTask(String taskId, {bool resetAttempts = true}) async {
    await queue.requeue(taskId, resetAttempts: resetAttempts);
    await _refresh();
    await sync(trigger: SyncTrigger.manual);
  }

  /// Drops a queued item (the local record stays; only the transfer is dropped).
  Future<void> cancelTask(String taskId) async {
    await queue.remove(taskId);
    await _refresh();
  }

  Future<void> dispose() async {
    _progressTicker?.cancel();
    _progressTicker = null;
    await _networkSubscription?.cancel();
    _networkSubscription = null;
    await _stateController.close();
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<void> _drain() async {
    final NetworkQuality quality = await networkInfo.currentQuality();
    if (!quality.isOnline) {
      await _handleOffline(quality);
      return;
    }

    final bool wifiOnly = await preferences.wifiOnly;
    _startProgressTicker();

    int processed = 0;
    while (processed < _maxTasksPerRun && !_paused) {
      if (!await _authorizationAvailable()) break;
      final SyncTask? task = await queue.nextDue();
      if (task == null) break;

      if (!_isAllowedNow(task, quality, wifiOnly)) {
        await queue.deferTask(
          task.id,
          delay: const Duration(minutes: 15),
          reason: wifiOnly
              ? 'Waiting for a Wi-Fi connection'
              : 'Waiting for a better connection',
        );
        break;
      }

      if (!worker.canHandle(task)) {
        // A task nobody can execute will never succeed: fail it permanently so
        // it shows up in the sync centre instead of blocking the queue.
        await queue.markFailed(
          task.id,
          error:
              'No sync handler for ${task.entityType.value}/${task.operation.value}.',
          permanent: true,
        );
        processed++;
        continue;
      }

      final bool ok = await _runTask(task);
      processed++;

      if (!ok) {
        _consecutiveFailures++;
        if (_consecutiveFailures >= _maxConsecutiveFailures) {
          log('SyncManager: backing off after $_consecutiveFailures failures');
          break;
        }
      }
    }
  }

  /// Executes one task and records the result. Returns whether it succeeded.
  Future<bool> _runTask(SyncTask task) async {
    _activeTaskId = task.id;
    await queue.markInProgress(task.id);
    await _emit(
      _state.copyWith(
        status: SyncConnectionStatus.syncing,
        isSyncing: true,
        activeTask: task,
        activeProgress: task.progress,
        clearMessage: true,
        updatedAt: DateTime.now(),
      ),
    );

    final SyncOutcome outcome = await worker.execute(task);

    if (outcome.succeeded) {
      await queue.markCompleted(task.id, remoteId: outcome.remoteId);
      await checkpointStore.markSynced();
      if (await queue.countByStatus(SyncStatus.failed) == 0) {
        await checkpointStore.setLastError(null);
      }
      _activeTaskId = null;
      return true;
    }

    await queue.markFailed(
      task.id,
      error: outcome.errorMessage ?? 'Sync failed',
      retryAfter: task.backoff,
    );
    await checkpointStore.setLastError(outcome.errorMessage);
    _activeTaskId = null;
    return false;
  }

  bool _isAllowedNow(
    SyncTask task,
    NetworkQuality quality,
    bool wifiOnly,
  ) {
    if (!quality.isOnline) return false;
    if (wifiOnly && task.isLargeTransfer && !quality.isUnmetered) return false;
    return true;
  }

  Future<void> _handleOffline(NetworkQuality quality) async {
    if (_isRunning) return;
    await _emit(
      _state.copyWith(
        status: SyncConnectionStatus.offline,
        isSyncing: false,
        message: 'Working offline. Your files stay on this device.',
        clearActiveTask: true,
        updatedAt: DateTime.now(),
      ),
    );
  }

  void _startProgressTicker() {
    _progressTicker?.cancel();
    _progressTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_tickProgress());
    });
  }

  /// Re-reads the running task so the indicator shows live percentages without
  /// the worker having to know about presentation state.
  Future<void> _tickProgress() async {
    final String? id = _activeTaskId;
    if (id == null) return;

    final SyncTask? task = await queue.findById(id);
    if (task == null) return;

    await _emit(
      _state.copyWith(
        status: SyncConnectionStatus.syncing,
        isSyncing: true,
        activeTask: task,
        activeProgress: task.progress,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<bool> _authorizationAvailable() async {
    final Future<bool> Function()? check = isAuthorized;
    if (check == null) return true;
    try {
      return await check();
    } catch (error) {
      log('SyncManager: authorization check failed ($error)');
      return false;
    }
  }

  Future<void> _refresh({SyncTrigger? trigger}) async {
    final Map<SyncStatus, int> counts = await queue.counts();
    final NetworkQuality quality = await networkInfo.currentQuality();
    final DateTime? lastSyncedAt = await checkpointStore.lastSyncedAt();
    final String? lastError = await checkpointStore.lastError();

    final int pending = (counts[SyncStatus.pending] ?? 0) +
        (counts[SyncStatus.inProgress] ?? 0);
    final int failed = counts[SyncStatus.failed] ?? 0;
    final int completed = counts[SyncStatus.completed] ?? 0;

    SyncConnectionStatus status;
    String? message;

    if (failed > 0 || (lastError != null && quality.isOnline)) {
      status = SyncConnectionStatus.attentionRequired;
      message = lastError;
    } else if (!quality.isOnline) {
      status = SyncConnectionStatus.offline;
      message = pending == 0
          ? null
          : 'Stored safely on device - will upload automatically';
    } else if (pending > 0) {
      status = SyncConnectionStatus.waiting;
      message = lastError;
    } else {
      status = SyncConnectionStatus.synced;
    }

    await _emit(
      _state.copyWith(
        status: status,
        isSyncing: false,
        trigger: trigger,
        pendingCount: pending,
        failedCount: failed,
        completedCount: completed,
        lastSyncedAt: lastSyncedAt,
        message: message,
        clearActiveTask: true,
        clearMessage: message == null,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _emit(SyncState state) async {
    _state = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }
}
