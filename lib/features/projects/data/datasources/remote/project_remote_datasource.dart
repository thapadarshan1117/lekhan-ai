import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class ProjectRemoteDataSource {
  Future<Either<AppException, List<ProjectModel>>> fetchProjects({
    int page,
    int pageSize,
  });

  Future<Either<AppException, ProjectModel>> fetchProject(String remoteId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  const ProjectRemoteDataSourceImpl({required this.networkService});

  final NetworkService networkService;

  static const String _identifier = 'ProjectRemoteDataSourceImpl';

  @override
  Future<Either<AppException, List<ProjectModel>>> fetchProjects({
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final Either<AppException, Response> response = await networkService.get(
        ApiConstants.projects,
        queryParameters: <String, dynamic>{
          'p': page,
          'page_size': pageSize,
        },
      );

      return response.fold(
        (AppException exception) =>
            Left<AppException, List<ProjectModel>>(exception),
        (Response result) {
          final List<Map<String, dynamic>> records =
              JsonUtils.asMapList(result.data);
          return Right<AppException, List<ProjectModel>>(
            records
                .map<ProjectModel>(ProjectModel.fromJson)
                .where((ProjectModel project) => project.id.isNotEmpty)
                .toList(),
          );
        },
      );
    } catch (error) {
      return Left<AppException, List<ProjectModel>>(
        FailureMapper.from(error, identifier: '$_identifier.fetchProjects'),
      );
    }
  }

  @override
  Future<Either<AppException, ProjectModel>> fetchProject(
    String remoteId,
  ) async {
    try {
      final Either<AppException, Response> response =
          await networkService.get(ApiConstants.projectDetail(remoteId));

      return response.fold(
        (AppException exception) =>
            Left<AppException, ProjectModel>(exception),
        (Response result) {
          final Map<String, dynamic> data = JsonUtils.unwrap(result.data);
          if (data.isEmpty) {
            return Left<AppException, ProjectModel>(
              AppException(
                message: 'The project could not be found.',
                statusCode: 404,
                identifier: '$_identifier.fetchProject.empty',
              ),
            );
          }
          return Right<AppException, ProjectModel>(
            ProjectModel.fromJson(data),
          );
        },
      );
    } catch (error) {
      return Left<AppException, ProjectModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchProject'),
      );
    }
  }
}
