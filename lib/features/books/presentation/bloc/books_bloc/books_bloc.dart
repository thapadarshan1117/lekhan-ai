import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/usecases/get_books_usecase.dart';

part 'books_event.dart';
part 'books_state.dart';
part 'books_bloc.freezed.dart';

/// Books of one project.
class BooksBloc extends Bloc<BooksEvent, BooksState> {
  BooksBloc({required this.projectId, required this.getBooks})
      : super(const BooksState.initial()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
  }

  final String projectId;
  final GetBooksUsecase getBooks;

  Future<void> _onStarted(_Started event, Emitter<BooksState> emit) async {
    emit(const BooksState.loading());

    final result = await getBooks(GetBooksParams(projectId: projectId));
    final List<Book>? books = result.valueOrNull;

    if (books == null) {
      emit(BooksState.loaded(
        books: const <Book>[],
        message: result.errorOrNull?.message ?? 'Books could not be loaded.',
        isEmptyBecauseOfError: true,
      ));
      return;
    }

    emit(BooksState.loaded(books: books));
  }

  Future<void> _onRefreshed(_Refreshed event, Emitter<BooksState> emit) async {
    final BooksState current = state;

    if (current is _Loaded) {
      emit(current.copyWith(isRefreshing: true, message: null));
    } else {
      emit(const BooksState.loading());
    }

    final result =
        await getBooks(GetBooksParams(projectId: projectId, forceRefresh: true));
    final List<Book>? books = result.valueOrNull;

    if (books == null) {
      final String message =
          result.errorOrNull?.message ?? 'Could not refresh right now.';

      final BooksState fallback = state;
      if (fallback is _Loaded) {
        emit(fallback.copyWith(isRefreshing: false, message: message));
      } else {
        emit(BooksState.loaded(
          books: const <Book>[],
          message: message,
          isEmptyBecauseOfError: true,
        ));
      }
      return;
    }

    emit(BooksState.loaded(books: books));
  }
}
