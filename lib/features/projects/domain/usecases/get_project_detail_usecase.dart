import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/repositories/project_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class GetProjectDetailUsecase
    implements UsecaseWithParam<Project, String> {
  const GetProjectDetailUsecase({required this.repository});

  final ProjectRepository repository;

  @override
  Future<Either<AppException, Project>> call(String projectId) {
    return repository.getProject(projectId);
  }
}

class WatchProjectsUsecase {
  const WatchProjectsUsecase({required this.repository});

  final ProjectRepository repository;

  /// Local stream: the projects list renders straight from Hive and updates
  /// itself whenever sync writes something.
  Stream<List<Project>> call() => repository.watchProjects();
}
