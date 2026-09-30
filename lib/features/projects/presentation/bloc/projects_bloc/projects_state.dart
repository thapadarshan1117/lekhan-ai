part of 'projects_bloc.dart';

@freezed
class ProjectsState with _$ProjectsState {
  const factory ProjectsState.initial() = _Initial;

  const factory ProjectsState.loading() = _Loading;

  const factory ProjectsState.loaded({
    required List<Project> projects,
    @Default(false) bool isRefreshing,

    /// A non-fatal note (e.g. the refresh failed but the cache is fine).
    String? message,

    /// True when the list is empty *because* the load failed, which changes the
    /// copy from "no projects yet" to "nothing available offline".
    @Default(false) bool isEmptyBecauseOfError,
  }) = _Loaded;

  const factory ProjectsState.error(String message) = _Error;
}
