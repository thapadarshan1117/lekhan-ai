part of 'books_bloc.dart';

@freezed
class BooksEvent with _$BooksEvent {
  const factory BooksEvent.started() = _Started;

  const factory BooksEvent.refreshed() = _Refreshed;
}
