import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/enums/sync_status.dart';
import 'package:lekhan_ai/core/sync/sync_state.dart';
import 'package:lekhan_ai/features/sync/domain/usecases/get_sync_status_usecase.dart';
import 'package:lekhan_ai/features/sync/domain/usecases/retry_sync_usecase.dart';
import 'package:lekhan_ai/features/sync/domain/usecases/sync_now_usecase.dart';

/// What the sync indicator needs, flattened into one small object so the widget
/// layer never reaches into the engine's internals.
class SyncStatusState {
  const SyncStatusState({
    this.status,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.isSyncing = false,
    this.progress,
    this.lastSyncedAt,
    this.message,
  });

  final SyncConnectionStatus? status;
  final int pendingCount;
  final int failedCount;
  final bool isSyncing;
  final double? progress;
  final DateTime? lastSyncedAt;
  final String? message;

  bool get hasFailures => failedCount > 0;

  bool get hasPending => pendingCount > 0;

  SyncStatusState copyWith({
    SyncConnectionStatus? status,
    int? pendingCount,
    int? failedCount,
    bool? isSyncing,
    double? progress,
    DateTime? lastSyncedAt,
    String? message,
    bool clearMessage = false,
  }) {
    return SyncStatusState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      isSyncing: isSyncing ?? this.isSyncing,
      progress: progress ?? this.progress,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

/// Mirrors the engine's state for the UI.
///
/// Deliberately read-only about the network: it shows what the queue is doing.
/// Nothing here is required for a write to succeed - a source is already on disk
/// and queued before this cubit is ever consulted.
class SyncStatusCubit extends Cubit<SyncStatusState> {
  SyncStatusCubit({
    required this.getStatus,
    required this.syncNowUsecase,
    required this.retryUsecase,
  }) : super(const SyncStatusState()) {
    _emitFrom(getStatus.current);
  }

  final GetSyncStatusUsecase getStatus;
  final SyncNowUsecase syncNowUsecase;
  final RetrySyncUsecase retryUsecase;

  StreamSubscription<SyncState>? _subscription;

  /// Subscribes to the engine. Safe to call more than once.
  void start() {
    _subscription ??= getStatus.watch().listen(_emitFrom);
    unawaited(_refreshCounts());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }

  /// User asked for a sync right now.
  Future<void> syncNow() async {
    emit(state.copyWith(isSyncing: true, clearMessage: true));
    final result = await syncNowUsecase(const SyncNowParams(force: true));

    emit(
      state.copyWith(
        isSyncing: false,
        message: result.fold((error) => error.message, (_) => null),
        clearMessage: result.isRight(),
      ),
    );

    await _refreshCounts();
  }

  /// "Retry failed" in the sync centre.
  Future<void> retryFailed({bool resetAttempts = true}) async {
    final result =
        await retryUsecase(RetrySyncParams(resetAttempts: resetAttempts));

    emit(
      state.copyWith(
        message: result.fold((error) => error.message, (_) => null),
        clearMessage: result.isRight(),
      ),
    );

    await _refreshCounts();
  }

  void _emitFrom(SyncState syncState) {
    if (isClosed) return;

    emit(
      SyncStatusState(
        status: syncState.status,
        pendingCount: syncState.pendingCount,
        failedCount: syncState.failedCount,
        isSyncing: syncState.isSyncing,
        progress: syncState.activeProgress,
        lastSyncedAt: syncState.lastSyncedAt,
        message: syncState.message,
      ),
    );
  }

  Future<void> _refreshCounts() async {
    if (isClosed) return;
    _emitFrom(getStatus.current);
  }
}
