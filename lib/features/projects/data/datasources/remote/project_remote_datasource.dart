import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

// Mock data
const List<Map<String, dynamic>> _mockProjectsData = [
  {
    'id': 'project_001',
    'title': 'Literature Collection',
    'description': 'A collection of classic literature',
    'image': 'https://via.placeholder.com/300x300?text=Literature',
    'status': 'active',
    'created_at': '2024-01-01T00:00:00Z',
  },
  {
    'id': 'project_002',
    'title': 'Learning Series',
    'description': 'Educational content for learners',
    'image': 'https://via.placeholder.com/300x300?text=Learning',
    'status': 'active',
    'created_at': '2024-01-05T00:00:00Z',
  },
];

abstract class ProjectRemoteDataSource {
  Future<Either<AppException, List<ProjectModel>>> fetchProjects({
    int page,
    int pageSize,
  });

  Future<Either<AppException, ProjectModel>> fetchProject(String remoteId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  const ProjectRemoteDataSourceImpl({NetworkService? networkService});

  static const String _identifier = 'ProjectRemoteDataSourceImpl';

  @override
  Future<Either<AppException, List<ProjectModel>>> fetchProjects({
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      return Right<AppException, List<ProjectModel>>(
        _mockProjectsData
            .map<ProjectModel>(ProjectModel.fromJson)
            .where((ProjectModel project) => project.id.isNotEmpty)
            .toList(),
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
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      final projectData = _mockProjectsData.firstWhere(
        (project) => project['id'] == remoteId,
        orElse: () => {},
      );

      if (projectData.isEmpty) {
        return Left<AppException, ProjectModel>(
          AppException(
            message: 'The project could not be found.',
            statusCode: 404,
            identifier: '$_identifier.fetchProject.empty',
          ),
        );
      }

      return Right<AppException, ProjectModel>(
        ProjectModel.fromJson(projectData),
      );
    } catch (error) {
      return Left<AppException, ProjectModel>(
        FailureMapper.from(error, identifier: '$_identifier.fetchProject'),
      );
    }
  }
}
