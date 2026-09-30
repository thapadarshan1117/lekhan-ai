part of 'sources_bloc.dart';

@freezed
class SourcesState with _$SourcesState {
  const factory SourcesState.initial() = _Initial;

  const factory SourcesState.loading() = _Loading;

  const factory SourcesState.loaded({
    required List<ChapterSource> sources,

    /// True while an add/delete/retry is in flight, so the UI can disable the
    /// buttons instead of letting the user queue the same file twice.
    @Default(false) bool isBusy,

    /// A line for the snackbar: either a failure or a confirmation.
    String? message,
  }) = _Loaded;

  const factory SourcesState.error(String message) = _Error;
}
