import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/repositories/project_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class GetProjectsUsecase
    implements UsecaseWithParam<List<Project>, GetProjectsParams> {
  const GetProjectsUsecase({required this.repository});

  final ProjectRepository repository;

  @override
  Future<Either<AppException, List<Project>>> call(GetProjectsParams params) {
    return repository.getProjects(forceRefresh: params.forceRefresh);
  }
}

class GetProjectsParams {
  const GetProjectsParams({this.forceRefresh = false});

  /// `true` for pull-to-refresh; `false` for the offline-first read.
  final bool forceRefresh;
}
