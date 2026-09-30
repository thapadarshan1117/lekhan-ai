import 'package:lekhan_ai/core/database/app_database.dart';
import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/database/document_store.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class ProjectLocalDataSource {
  Future<Either<AppException, List<ProjectModel>>> getProjects();

  Future<Either<AppException, ProjectModel?>> getProject(String id);

  Future<Either<AppException, ProjectModel?>> getProjectByRemoteId(
    String remoteId,
  );

  /// Insert or replace one record. Returns the stored copy.
  Future<Either<AppException, ProjectModel>> save(ProjectModel project);

  Future<Either<AppException, List<ProjectModel>>> saveAll(
    List<ProjectModel> projects,
  );

  Future<Either<AppException, bool>> delete(String id);

  Future<Either<AppException, bool>> clear();

  Stream<List<ProjectModel>> watchProjects();
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  ProjectLocalDataSourceImpl({required this.database})
      : _store = DocumentStore<ProjectModel>(
          database: database,
          boxName: DatabaseTables.projects,
          fromJson: ProjectModel.fromJson,
          toJson: (ProjectModel project) => project.toJson(),
          idOf: (ProjectModel project) => project.id,
        );

  final AppDatabase database;
  final DocumentStore<ProjectModel> _store;

  static const String _identifier = 'ProjectLocalDataSourceImpl';

  @override
  Future<Either<AppException, List<ProjectModel>>> getProjects() async {
    try {
      final List<ProjectModel> projects = await _store.readAll();
      projects.sort((ProjectModel a, ProjectModel b) =>
          b.updatedAt.compareTo(a.updatedAt));
      return Right(projects);
    } catch (error) {
      return Left(
        FailureMapper.local(
          error,
          identifier: '$_identifier.getProjects',
          message: 'Could not read the saved projects.',
          statusCode: LocalErrorCodes.databaseFailure,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, ProjectModel?>> getProject(String id) async {
    try {
      return Right(await _store.readById(id));
    } catch (error) {
      return Left(
        FailureMapper.local(
          error,
          identifier: '$_identifier.getProject',
          message: 'Could not read the project.',
          statusCode: LocalErrorCodes.databaseFailure,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, ProjectModel?>> getProjectByRemoteId(
    String remoteId,
  ) async {
    try {
      return Right(await _store.readByAnyId(remoteId, remoteId: remoteId));
    } catch (error) {
      return Left(
        FailureMapper.local(
          error,
          identifier: '$_identifier.getProjectByRemoteId',
          message: 'Could not read the project.',
          statusCode: LocalErrorCodes.databaseFailure,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, ProjectModel>> save(ProjectModel project) async {
    try {
      await _store.write(project);
      return Right(project);
    } catch (error) {
      return Left(
        FailureMapper.local(
          error,
          identifier: '$_identifier.save',
          message: 'Could not save the project on this device.',
          statusCode: LocalErrorCodes.databaseFailure,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<ProjectModel>>> saveAll(
    List<ProjectModel> projects,
  ) async {
    try {
      await _store.writeAll(projects);
      return Right(projects);
    } catch (error) {
      return Left(
        FailureMapper.local(
          error,
          identifier: '$_identifier.saveAll',
          message: 'Could not save the projects on this device.',
          statusCode: LocalErrorCodes.databaseFailure,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> delete(String id) async {
    try {
      await _store.delete(id);
      return const Right(true);
    } catch (error) {
      return Left(
        FailureMapper.local(
          error,
          identifier: '$_identifier.delete',
          message: 'Could not remove the project.',
          statusCode: LocalErrorCodes.databaseFailure,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> clear() async {
    try {
      await _store.clear();
      return const Right(true);
    } catch (error) {
      return Left(
        FailureMapper.local(
          error,
          identifier: '$_identifier.clear',
          message: 'Could not clear the saved projects.',
          statusCode: LocalErrorCodes.databaseFailure,
        ),
      );
    }
  }

  @override
  Stream<List<ProjectModel>> watchProjects() => _store.watch();
}
