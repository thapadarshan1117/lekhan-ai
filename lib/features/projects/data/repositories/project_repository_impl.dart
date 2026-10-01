import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/enums/sync_operation.dart';
import 'package:lekhan_ai/core/sync/conflict_resolver.dart';
import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_request_bus.dart';
import 'package:lekhan_ai/core/sync/sync_task_builder.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/projects/data/datasources/local/project_local_datasource.dart';
import 'package:lekhan_ai/features/projects/data/datasources/remote/project_remote_datasource.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/repositories/project_repository.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl({
    required this.local,
    required this.remote,
    required this.queue,
    required this.requestBus,
    ConflictResolver? conflictResolver,
  }) : _conflicts = conflictResolver ?? const ConflictResolver();

  final ProjectLocalDataSource local;
  final ProjectRemoteDataSource remote;
  final SyncQueue queue;
  final SyncRequestBus requestBus;
  final ConflictResolver _conflicts;

  static const String _identifier = 'ProjectRepositoryImpl';

  @override
  Future<Either<AppException, List<Project>>> getProjects({
    bool forceRefresh = false,
  }) async {
    final Either<AppException, List<ProjectModel>> cached =
        await local.getProjects();
    final List<ProjectModel> cachedProjects = cached.valuesOrEmpty;

    if (!forceRefresh && cachedProjects.isNotEmpty) {
      return Right<AppException, List<Project>>(_asEntities(cachedProjects));
    }

    final Either<AppException, List<ProjectModel>> fetched =
        await remote.fetchProjects();
    final List<ProjectModel>? remoteProjects = fetched.valueOrNull;

    if (remoteProjects == null) {
      if (cachedProjects.isNotEmpty) {
        // Offline, or the server is unhappy: the cache is still a valid answer.
        return Right<AppException, List<Project>>(_asEntities(cachedProjects));
      }
      return Left<AppException, List<Project>>(
        fetched.errorOrNull ??
            FailureMapper.local(
              StateError('Unknown project fetch failure'),
              identifier: '$_identifier.getProjects',
            ),
      );
    }

    final List<ProjectModel> merged = await _mergeIntoCache(remoteProjects);
    return Right<AppException, List<Project>>(_asEntities(merged));
  }

  @override
  Future<Either<AppException, Project>> getProject(String id) async {
    final Either<AppException, ProjectModel?> cached = await local.getProject(id);
    final ProjectModel? project = cached.valueOrNull;

    // Never been online, or has unsent edits: the local copy is the truth.
    if (project != null && (!project.isDirty || project.remoteId == null)) {
      return Right<AppException, Project>(project);
    }

    final Either<AppException, ProjectModel> fetched =
        await remote.fetchProject(project?.remoteId ?? id);
    final ProjectModel? remoteProject = fetched.valueOrNull;

    if (remoteProject == null) {
      if (project != null) return Right<AppException, Project>(project);
      return Left<AppException, Project>(
        fetched.errorOrNull ??
            FailureMapper.local(
              StateError('Unknown project failure'),
              identifier: '$_identifier.getProject',
            ),
      );
    }

    if (project != null) {
      final ConflictResult resolution = _conflicts.resolve(
        local: project.toJson(),
        remote: remoteProject.toJson(),
      );

      if (resolution.shouldPushLocal) {
        // Keep the user's edit; the queue will push it on the next pass.
        return Right<AppException, Project>(project);
      }

      if (resolution.shouldDeleteLocal) {
        await local.delete(project.id);
        return Right<AppException, Project>(remoteProject.markSynced());
      }
    }

    final ProjectModel stored = remoteProject
        .markSynced()
        .copyWith(id: project?.id ?? remoteProject.id);
    await local.save(stored);
    return Right<AppException, Project>(stored);
  }

  @override
  Stream<List<Project>> watchProjects() {
    return local.watchProjects().map(
          (List<ProjectModel> projects) => _asEntities(projects),
        );
  }

  @override
  Future<Either<AppException, List<Project>>> refreshProjects() {
    return getProjects(forceRefresh: true);
  }

  @override
  Future<Either<AppException, Project>> saveLocal(Project project) async {
    final ProjectModel model = ProjectModel.fromEntity(project).markDirty();

    final Either<AppException, ProjectModel> saved = await local.save(model);
    final ProjectModel? stored = saved.valueOrNull;

    if (stored == null) {
      return Left<AppException, Project>(
        saved.errorOrNull ??
            FailureMapper.local(
              StateError('Project could not be saved'),
              identifier: '$_identifier.saveLocal',
              statusCode: LocalErrorCodes.databaseFailure,
            ),
      );
    }

    await queue.enqueue(
      SyncTaskBuilder.metadata(
        entityType: SyncEntityType.project,
        entityId: stored.id,
        operation:
            stored.remoteId == null ? SyncOperation.create : SyncOperation.update,
        remoteId: stored.remoteId,
        payload: <String, dynamic>{
          'entity': SyncEntityType.project.value,
          'local_updated_at': stored.updatedAt.toIso8601String(),
          'data': stored.toRemoteJson(),
        },
      ),
    );

    requestBus.request();
    return Right<AppException, Project>(stored);
  }

  @override
  Future<Either<AppException, bool>> deleteLocal(String id) async {
    final Either<AppException, ProjectModel?> found = await local.getProject(id);
    final AppException? readError = found.errorOrNull;
    if (readError != null) return Left<AppException, bool>(readError);

    final ProjectModel? project = found.valueOrNull;
    if (project == null) return const Right<AppException, bool>(true);

    final Either<AppException, bool> deleted = await local.delete(id);
    if (deleted.valueOrNull != true) {
      return Left<AppException, bool>(
        deleted.errorOrNull ??
            FailureMapper.local(
              StateError('Project could not be removed'),
              identifier: '$_identifier.deleteLocal',
              statusCode: LocalErrorCodes.databaseFailure,
            ),
      );
    }

    await queue.enqueue(
      SyncTaskBuilder.metadata(
        entityType: SyncEntityType.project,
        entityId: id,
        operation: SyncOperation.delete,
        remoteId: project.remoteId,
      ),
    );
    for (final task in await queue.all()) {
      if (task.entityType == SyncEntityType.project &&
          task.entityId == id &&
          task.operation != SyncOperation.delete) {
        await queue.remove(task.id);
      }
    }
    requestBus.request();
    return const Right<AppException, bool>(true);
  }

  @override
  Future<Either<AppException, Project>> markSynced(
    String id, {
    String? remoteId,
  }) async {
    final Either<AppException, ProjectModel?> cached = await local.getProject(id);
    final ProjectModel? project = cached.valueOrNull;

    if (project == null) {
      return Left<AppException, Project>(
        FailureMapper.local(
          StateError('Project $id not found in the local store'),
          identifier: '$_identifier.markSynced',
          message: 'The project could not be found on this device.',
          statusCode: LocalErrorCodes.notFound,
        ),
      );
    }

    final ProjectModel synced = project.markSynced(remoteId: remoteId);
    final Either<AppException, ProjectModel> saved = await local.save(synced);

    return saved.fold(
      (AppException exception) => Left<AppException, Project>(exception),
      (ProjectModel value) => Right<AppException, Project>(value),
    );
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  List<Project> _asEntities(List<ProjectModel> projects) =>
      projects.map<Project>((ProjectModel project) => project).toList();

  /// Merges pulled records into the cache without ever dropping unsent local
  /// edits (see [ConflictResolver] for the exact rules).
  Future<List<ProjectModel>> _mergeIntoCache(
    List<ProjectModel> remoteProjects,
  ) async {
    final Either<AppException, List<ProjectModel>> cachedResult =
        await local.getProjects();
    final List<ProjectModel> cached = cachedResult.valuesOrEmpty;

    final Map<String, ProjectModel> byRemoteId = <String, ProjectModel>{
      for (final ProjectModel project in cached)
        if (project.remoteId != null && project.remoteId!.isNotEmpty)
          project.remoteId!: project,
    };

    final List<ProjectModel> toStore = <ProjectModel>[];

    for (final ProjectModel remoteProject in remoteProjects) {
      final ProjectModel? existing = byRemoteId[remoteProject.remoteId];

      if (existing == null) {
        toStore.add(remoteProject.markSynced());
        continue;
      }

      final ConflictResult resolution = _conflicts.resolve(
        local: existing.toJson(),
        remote: remoteProject.toJson(),
      );

      if (resolution.shouldApplyRemote) {
        toStore.add(remoteProject.markSynced().copyWith(id: existing.id));
      } else if (resolution.shouldDeleteLocal) {
        await local.delete(existing.id);
      }
      // keepLocal* -> the dirty local copy stays and the queue pushes it.
    }

    if (toStore.isNotEmpty) {
      await local.saveAll(toStore);
    }

    final Either<AppException, List<ProjectModel>> refreshed =
        await local.getProjects();
    return refreshed.valuesOrEmpty.isEmpty ? toStore : refreshed.valuesOrEmpty;
  }
}
