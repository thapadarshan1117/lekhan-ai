import 'package:lekhan_ai/core/constants/api_constants.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/core/utils/remote_json_utils.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/response.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class ProjectRemoteDataSource {
  Future<Either<AppException, List<ProjectModel>>> fetchProjects({
    int page = 1,
    int pageSize = 50,
  });

  Future<Either<AppException, ProjectModel>> fetchProject(String remoteId);
}

/// Authenticated, read-only project API. Writes use the durable `/sync/push`
/// outbox so the same operation works online and offline.
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
      final Either<AppException, Response> result = await networkService.get(
        ApiConstants.projects,
        queryParameters: <String, dynamic>{'page': page, 'page_size': pageSize},
      );
      return result.fold(
        (AppException error) => Left<AppException, List<ProjectModel>>(error),
        (Response response) => Right<AppException, List<ProjectModel>>(
          RemoteJsonUtils.records(response.data)
              .map<ProjectModel>(_projectFromRemote)
              .where((ProjectModel item) => item.remoteId?.isNotEmpty == true)
              .toList(growable: false),
        ),
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
      final Either<AppException, Response> result = await networkService.get(
        ApiConstants.projectDetail(remoteId),
      );
      return result.fold(
        (AppException error) => Left<AppException, ProjectModel>(error),
        (Response response) {
          final Map<String, dynamic> data =
              RemoteJsonUtils.withRemoteIdentity(
            RemoteJsonUtils.detailRecord(response.data, entityKey: 'project'),
            id: remoteId,
          );
          return Right<AppException, ProjectModel>(
            _projectFromRemote(data),
          );
        },
      );
    } catch (error) {
      return Left<AppException, ProjectModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchProject'),
      );
    }
  }

  ProjectModel _projectFromRemote(Map<String, dynamic> raw) {
    final Map<String, dynamic> data =
        RemoteJsonUtils.withRemoteIdentity(raw);
    data['name'] = JsonUtils.asString(
      raw['name'],
      fallback: JsonUtils.asString(raw['title']),
    );
    data['description'] = JsonUtils.asString(raw['description']);
    data['cover_image_url'] = JsonUtils.asStringOrNull(
      raw['cover_image_url'] ?? raw['cover_image'] ?? raw['image'],
    );
    return ProjectModel.fromJson(data);
  }
}
