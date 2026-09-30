import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/presentation/bloc/projects_bloc/projects_bloc.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_card.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/projects_empty_state.dart';
import 'package:lekhan_ai/features/sync/presentation/widgets/sync_status_chip.dart';

/// The projects list - the root of the writing structure
/// (project → book → chapter → sources).
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectsBloc>(
      create: (BuildContext context) =>
          sl<ProjectsBloc>()..add(const ProjectsEvent.started()),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatelessWidget {
  const _ProjectsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Projects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: SyncStatusChip(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('projectForm'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New project'),
      ),
      body: BlocConsumer<ProjectsBloc, ProjectsState>(
        listener: (BuildContext context, ProjectsState state) {
          state.maybeWhen(
            loaded: (List<Project> projects, bool isRefreshing, String? message,
                bool isEmptyBecauseOfError) {
              if (message != null && !isEmptyBecauseOfError) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: AppColors.textPrimary,
                    ),
                  );
              }
            },
            orElse: () {},
          );
        },
        builder: (BuildContext context, ProjectsState state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (String message) => _ErrorView(message: message),
            loaded: (List<Project> projects, bool isRefreshing, String? message,
                bool isEmptyBecauseOfError) {
              if (projects.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => context
                      .read<ProjectsBloc>()
                      .add(const ProjectsEvent.refreshed()),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ProjectsEmptyState(offline: isEmptyBecauseOfError),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => context
                    .read<ProjectsBloc>()
                    .add(const ProjectsEvent.refreshed()),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final Project project = projects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () => context.pushNamed(
                        'projectDetail',
                        pathParameters: <String, String>{'id': project.id},
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  context.read<ProjectsBloc>().add(const ProjectsEvent.started()),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
