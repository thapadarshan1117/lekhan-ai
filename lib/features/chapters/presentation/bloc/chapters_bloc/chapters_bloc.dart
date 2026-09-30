import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/get_chapters_usecase.dart';

part 'chapters_event.dart';
part 'chapters_state.dart';
part 'chapters_bloc.freezed.dart';

/// Chapters of one book, ordered by their number.
class ChaptersBloc extends Bloc<ChaptersEvent, ChaptersState> {
  ChaptersBloc({required this.bookId, required this.getChapters})
      : super(const ChaptersState.initial()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
  }

  final String bookId;
  final GetChaptersUsecase getChapters;

  Future<void> _onStarted(_Started event, Emitter<ChaptersState> emit) async {
    emit(const ChaptersState.loading());

    final result = await getChapters(GetChaptersParams(bookId: bookId));
    final List<Chapter>? chapters = result.valueOrNull;

    if (chapters == null) {
      emit(ChaptersState.loaded(
        chapters: const <Chapter>[],
        message:
            result.errorOrNull?.message ?? 'Chapters could not be loaded.',
        isEmptyBecauseOfError: true,
      ));
      return;
    }

    emit(ChaptersState.loaded(chapters: chapters));
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
}
