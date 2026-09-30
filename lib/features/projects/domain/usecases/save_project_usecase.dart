import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/repositories/project_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Local-first write: the change is persisted (and queued) before any HTTP
/// call is attempted, so it survives losing the connection a millisecond later.
class SaveProjectUsecase implements UsecaseWithParam<Project, Project> {
  const SaveProjectUsecase({required this.repository});

  final ProjectRepository repository;

  @override
  Future<Either<AppException, Project>> call(Project project) {
    return repository.saveLocal(project);
  }
}
