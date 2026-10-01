import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/mock/mock_lekhan_backend.dart';
import 'package:lekhan_ai/core/utils/json_utils.dart';
import 'package:lekhan_ai/core/utils/remote_json_utils.dart';
import 'package:lekhan_ai/features/projects/data/datasources/remote/project_remote_datasource.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// UI-only project remote backed by an in-memory mock server. The interface is
/// identical to the API datasource, so DI can switch implementations later.
class MockProjectRemoteDataSource implements ProjectRemoteDataSource {
  const MockProjectRemoteDataSource({required this.backend});

  final MockLekhanBackend backend;
  static const String _identifier = 'MockProjectRemoteDataSource';

  @override
  Future<Either<AppException, List<ProjectModel>>> fetchProjects({
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      await Future<void>.delayed(backend.latency);
      return Right<AppException, List<ProjectModel>>(
        backend
            .fetchRecords('project', page: page, pageSize: pageSize)
            .map<ProjectModel>(_toModel)
            .toList(growable: false),
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
      await Future<void>.delayed(backend.latency);
      final Map<String, dynamic>? record =
          backend.fetchRecord('project', remoteId);
      if (record == null) {
        return Left<AppException, ProjectModel>(
          AppException(
            message: 'Project not found in the mock workspace.',
            statusCode: 404,
            identifier: '$_identifier.fetchProject.notFound',
          ),
        );
      }
      return Right<AppException, ProjectModel>(_toModel(record));
    } catch (error) {
      return Left<AppException, ProjectModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchProject'),
      );
    }
  }

  ProjectModel _toModel(Map<String, dynamic> record) {
    final Map<String, dynamic> json = RemoteJsonUtils.withRemoteIdentity(record);
    json['name'] = JsonUtils.asString(
      record['name'],
      fallback: JsonUtils.asString(record['title']),
    );
    json['description'] = JsonUtils.asString(record['description']);
    return ProjectModel.fromJson(json);
  }
}
