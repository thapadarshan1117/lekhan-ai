import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/get_project_detail_usecase.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/save_project_usecase.dart';

part 'projects_event.dart';
part 'projects_state.dart';
part 'projects_bloc.freezed.dart';

/// Drives the projects list.
///
/// Listens to the local store via a stream, so projects appear instantly when
/// created and the UI updates automatically as sync changes them. The "refresh"
/// action can still touch the network.
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  ProjectsBloc({
    required this.getProjects,
    required this.watchProjects,
    required this.saveProject,
  }) : super(const ProjectsState.initial()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
  }

  final GetProjectsUsecase getProjects;
  final WatchProjectsUsecase watchProjects;
  final SaveProjectUsecase saveProject;

  StreamSubscription<List<Project>>? _subscription;

  Future<void> _onStarted(
    _Started event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(const ProjectsState.loading());

    await _subscription?.cancel();
    
    // Emit initial projects before subscribing to changes
    try {
      final List<Project> initialItems = await watchProjects().first;
      _publish(emit, initialItems);
    } catch (error) {
      if (!emit.isDone) {
        emit(ProjectsState.loaded(
          projects: const <Project>[],
          message: 'Projects could not be loaded.',
          isEmptyBecauseOfError: true,
        ));
      }
      return;
    }

    // Now subscribe to future changes
    _subscription = watchProjects().listen(
      (List<Project> items) {
        if (!emit.isDone) {
          _publish(emit, items);
        }
      },
      onError: (Object error) {
        if (!emit.isDone) {
          emit(ProjectsState.loaded(
            projects: const <Project>[],
            message: 'Projects could not be loaded.',
            isEmptyBecauseOfError: true,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshed(
    _Refreshed event,
    Emitter<ProjectsState> emit,
  ) async {
    final ProjectsState current = state;

    if (current is _Loaded) {
      emit(current.copyWith(isRefreshing: true, message: null));
    } else {
      emit(const ProjectsState.loading());
    }

    final result = await getProjects(const GetProjectsParams(forceRefresh: true));

    final List<Project>? projects = result.valueOrNull;

    if (projects == null) {
      final String message =
          result.errorOrNull?.message ?? 'Could not refresh right now.';

      final ProjectsState fallback = state;
      if (fallback is _Loaded) {
        // Keep whatever is on screen and just say the refresh did not work.
        emit(fallback.copyWith(isRefreshing: false, message: message));
      } else {
        emit(ProjectsState.loaded(
          projects: const <Project>[],
          message: message,
          isEmptyBecauseOfError: true,
        ));
      }
      return;
    }

    emit(ProjectsState.loaded(projects: projects));
  }

  /// Emits a new list while preserving the busy flag and any pending message.
  void _publish(Emitter<ProjectsState> emit, List<Project> items) {
    if (emit.isDone) return;
    
    final bool isRefreshing = state.maybeWhen(
      loaded: (List<Project> _, bool isRefreshing, String? __, bool ___) => isRefreshing,
      orElse: () => false,
    );

    emit(ProjectsState.loaded(projects: items, isRefreshing: isRefreshing));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}
