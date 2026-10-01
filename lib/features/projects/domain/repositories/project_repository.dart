import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// The repository is the single source of truth for projects:
/// the UI never decides whether data comes from Hive or the API.
abstract class ProjectRepository {
  /// Local-first read. When [forceRefresh] is true (or nothing is cached yet)
  /// it tries the API, writes the result to the local store and only then
  /// answers - so an offline read still succeeds from the cache.
  Future<Either<AppException, List<Project>>> getProjects({
    bool forceRefresh,
  });

  Future<Either<AppException, Project>> getProject(String id);

  /// Live local stream, used by the projects list screen.
  Stream<List<Project>> watchProjects();

  /// Pulls the server copy and merges it into the local store.
  Future<Either<AppException, List<Project>>> refreshProjects();

  /// Applies a local edit immediately and queues it for the server.
  Future<Either<AppException, Project>> saveLocal(Project project);

  /// Removes a project locally and queues its server-side tombstone when needed.
  Future<Either<AppException, bool>> deleteLocal(String id);

  /// Records the remote id returned by the backend for a local record.
  Future<Either<AppException, Project>> markSynced(
    String id, {
    String? remoteId,
  });
}
