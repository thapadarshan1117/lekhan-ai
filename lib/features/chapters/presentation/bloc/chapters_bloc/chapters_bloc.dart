import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/get_chapters_usecase.dart';

part 'chapters_event.dart';
part 'chapters_state.dart';
part 'chapters_bloc.freezed.dart';

/// Chapters of one book, ordered by their number.
///
/// Listens to the local store via a stream, so chapters appear instantly when
/// created and the UI updates automatically as changes occur.
class ChaptersBloc extends Bloc<ChaptersEvent, ChaptersState> {
  ChaptersBloc({
    required this.bookId,
    required this.getChapters,
    required this.watchChapters,
  }) : super(const ChaptersState.initial()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
  }

  final String bookId;
  final GetChaptersUsecase getChapters;
  final WatchChaptersUsecase watchChapters;

  StreamSubscription<List<Chapter>>? _subscription;

  Future<void> _onStarted(_Started event, Emitter<ChaptersState> emit) async {
    emit(const ChaptersState.loading());

    await _subscription?.cancel();

    // Emit initial chapters before subscribing to changes
    try {
      final List<Chapter> initialItems = await watchChapters(bookId: bookId).first;
      _publish(emit, initialItems);
    } catch (error) {
      if (!emit.isDone) {
        emit(ChaptersState.loaded(
          chapters: const <Chapter>[],
          message: 'Chapters could not be loaded.',
          isEmptyBecauseOfError: true,
        ));
      }
      return;
    }

    // Now subscribe to future changes
    _subscription = watchChapters(bookId: bookId).listen(
      (List<Chapter> items) {
        if (!emit.isDone) {
          _publish(emit, items);
        }
      },
      onError: (Object error) {
        if (!emit.isDone) {
          emit(ChaptersState.loaded(
            chapters: const <Chapter>[],
            message: 'Chapters could not be loaded.',
            isEmptyBecauseOfError: true,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshed(_Refreshed event, Emitter<ChaptersState> emit) async {
    final ChaptersState current = state;

    if (current is _Loaded) {
      emit(current.copyWith(isRefreshing: true, message: null));
    } else {
      emit(const ChaptersState.loading());
    }

    final result = await getChapters(
      GetChaptersParams(bookId: bookId, forceRefresh: true),
    );
    final List<Chapter>? chapters = result.valueOrNull;

    if (chapters == null) {
      final String message =
          result.errorOrNull?.message ?? 'Could not refresh right now.';

      final ChaptersState fallback = state;
      if (fallback is _Loaded) {
        emit(fallback.copyWith(isRefreshing: false, message: message));
      } else {
        emit(ChaptersState.loaded(
          chapters: const <Chapter>[],
          message: message,
          isEmptyBecauseOfError: true,
        ));
      }
      return;
    }

    emit(ChaptersState.loaded(chapters: chapters));
  }

  /// Emits a new list while preserving the busy flag and any pending message.
  void _publish(Emitter<ChaptersState> emit, List<Chapter> items) {
    if (emit.isDone) return;

    final bool isRefreshing = state.maybeWhen(
      loaded: (List<Chapter> _, bool isRefreshing, String? __, bool ___) => isRefreshing,
      orElse: () => false,
    );

    emit(ChaptersState.loaded(chapters: items, isRefreshing: isRefreshing));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
