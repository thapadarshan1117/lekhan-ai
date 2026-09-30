part of 'chapters_bloc.dart';

@freezed
class ChaptersState with _$ChaptersState {
  const factory ChaptersState.initial() = _Initial;

  const factory ChaptersState.loading() = _Loading;

  const factory ChaptersState.loaded({
    required List<Chapter> chapters,
    @Default(false) bool isRefreshing,
    String? message,
    @Default(false) bool isEmptyBecauseOfError,
  }) = _Loaded;

  const factory ChaptersState.error(String message) = _Error;
}
