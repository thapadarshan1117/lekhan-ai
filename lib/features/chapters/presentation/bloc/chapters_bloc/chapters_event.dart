part of 'chapters_bloc.dart';

@freezed
class ChaptersEvent with _$ChaptersEvent {
  const factory ChaptersEvent.started() = _Started;

  const factory ChaptersEvent.refreshed() = _Refreshed;
}
