import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/save_project_usecase.dart';

part 'projects_event.dart';
part 'projects_state.dart';
part 'projects_bloc.freezed.dart';

/// Drives the projects list.
///
/// Every read goes through the repository, which answers from the local store
/// first. So this bloc works with the radio off, and "refresh" is the only
/// action that may touch the network.
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  ProjectsBloc({
    required this.getProjects,
    required this.saveProject,
  }) : super(const ProjectsState.initial()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
  }

  final GetProjectsUsecase getProjects;
  final SaveProjectUsecase saveProject;

  Future<void> _onStarted(
    _Started event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(const ProjectsState.loading());

    // Local first: this returns instantly when the cache has something, and the
    // force refresh below only happens if there is nothing to show.
    final result = await getProjects(const GetProjectsParams());

    final List<Project>? projects = result.valueOrNull;

    if (projects == null) {
      final String message =
          result.errorOrNull?.message ?? 'Projects could not be loaded.';

      // An empty cache is an empty state, not an error: the user may simply be
      // starting out, or offline with nothing downloaded yet.
      emit(ProjectsState.loaded(
        projects: const <Project>[],
        message: message,
        isEmptyBecauseOfError: true,
      ));
      return;
    }

    emit(ProjectsState.loaded(projects: projects));
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
}
