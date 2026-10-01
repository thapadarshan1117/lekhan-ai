import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/usecases/get_books_usecase.dart';

part 'books_event.dart';
part 'books_state.dart';
part 'books_bloc.freezed.dart';

/// Books of one project.
///
/// Listens to the local store via a stream, so books appear instantly when
/// created and the UI updates automatically as changes occur.
class BooksBloc extends Bloc<BooksEvent, BooksState> {
  BooksBloc({
    required this.projectId,
    required this.getBooks,
    required this.watchBooks,
  }) : super(const BooksState.initial()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
  }

  final String projectId;
  final GetBooksUsecase getBooks;
  final WatchBooksUsecase watchBooks;

  StreamSubscription<List<Book>>? _subscription;

  Future<void> _onStarted(_Started event, Emitter<BooksState> emit) async {
    emit(const BooksState.loading());

    await _subscription?.cancel();

    // Emit initial books before subscribing to changes
    try {
      final List<Book> initialItems = await watchBooks(projectId: projectId).first;
      _publish(emit, initialItems);
    } catch (error) {
      if (!emit.isDone) {
        emit(BooksState.loaded(
          books: const <Book>[],
          message: 'Books could not be loaded.',
          isEmptyBecauseOfError: true,
        ));
      }
      return;
    }

    // Now subscribe to future changes
    _subscription = watchBooks(projectId: projectId).listen(
      (List<Book> items) {
        if (!emit.isDone) {
          _publish(emit, items);
        }
      },
      onError: (Object error) {
        if (!emit.isDone) {
          emit(BooksState.loaded(
            books: const <Book>[],
            message: 'Books could not be loaded.',
            isEmptyBecauseOfError: true,
          ));
        }
      },
    );
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

  /// Emits a new list while preserving the busy flag and any pending message.
  void _publish(Emitter<BooksState> emit, List<Book> items) {
    if (emit.isDone) return;

    final bool isRefreshing = state.maybeWhen(
      loaded: (List<Book> _, bool isRefreshing, String? __, bool ___) => isRefreshing,
      orElse: () => false,
    );

    emit(BooksState.loaded(books: items, isRefreshing: isRefreshing));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
