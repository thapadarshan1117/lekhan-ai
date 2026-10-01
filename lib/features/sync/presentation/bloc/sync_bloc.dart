import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/core/sync/sync_engine.dart';
import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_task.dart';

part 'sync_event.dart';
part 'sync_state.dart';
part 'sync_bloc.freezed.dart';

/// BLoC that tracks sync engine status and exposes it to the UI.
class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required this.syncEngine,
    required this.syncQueue,
  }) : super(const SyncState.initial()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
    on<_RetryFailed>(_onRetryFailed);
  }

  final SyncEngine syncEngine;
  final SyncQueue syncQueue;

  StreamSubscription<void>? _statsSubscription;
  Timer? _statsTimer;

  Future<void> _onStarted(_Started event, Emitter<SyncState> emit) async {
    emit(const SyncState.loading());

    // Start polling sync stats every 2 seconds
    _statsTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      _emitStats(emit);
    });

    // Emit initial stats
    await _emitStats(emit);
  }

  Future<void> _onRefreshed(_Refreshed event, Emitter<SyncState> emit) async {
    await _emitStats(emit);
  }

  Future<void> _onRetryFailed(_RetryFailed event, Emitter<SyncState> emit) async {
    await syncEngine.retryFailed();
    await _emitStats(emit);
  }

  Future<void> _emitStats(Emitter<SyncState> emit) async {
    try {
      final SyncStats stats = await syncEngine.getStats();
      emit(SyncState.loaded(stats: stats));
    } catch (error) {
      emit(SyncState.error('Failed to fetch sync status'));
    }
  }

  @override
  Future<void> close() async {
    _statsTimer?.cancel();
    await _statsSubscription?.cancel();
    return super.close();
  }
}
