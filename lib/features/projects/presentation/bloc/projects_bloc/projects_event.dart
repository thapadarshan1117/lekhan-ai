part of 'projects_bloc.dart';

@freezed
class ProjectsEvent with _$ProjectsEvent {
  /// First load when the screen appears.
  const factory ProjectsEvent.started() = _Started;

  /// Pull-to-refresh: the only path allowed to hit the network.
  const factory ProjectsEvent.refreshed() = _Refreshed;
}
