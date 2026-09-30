part of 'books_bloc.dart';

@freezed
class BooksState with _$BooksState {
  const factory BooksState.initial() = _Initial;

  const factory BooksState.loading() = _Loading;

  const factory BooksState.loaded({
    required List<Book> books,
    @Default(false) bool isRefreshing,
    String? message,
    @Default(false) bool isEmptyBecauseOfError,
  }) = _Loaded;

  const factory BooksState.error(String message) = _Error;
}
