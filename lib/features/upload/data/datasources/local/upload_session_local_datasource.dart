import 'package:lekhan_ai/core/database/app_database.dart';
import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/database/document_store.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/features/upload/data/models/upload_session_model.dart';
import 'package:lekhan_ai/features/upload/domain/entities/upload_session.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Persists upload sessions so a resume survives an app restart, not just a
/// dropped connection.
abstract class UploadSessionLocalDataSource {
  Future<Either<AppException, UploadSessionModel?>> getSession(String id);

  Future<Either<AppException, UploadSessionModel?>> getBySource(String sourceId);

  Future<Either<AppException, List<UploadSessionModel>>> getOpenSessions();

  Future<Either<AppException, UploadSessionModel>> save(UploadSessionModel session);

  Future<Either<AppException, bool>> delete(String id);

  Future<Either<AppException, bool>> clear();

  /// Live sessions, newest first. Drives the progress card without polling.
  Stream<List<UploadSessionModel>> watchAll();
}

class UploadSessionLocalDataSourceImpl implements UploadSessionLocalDataSource {
  UploadSessionLocalDataSourceImpl({required this.database})
      : _store = DocumentStore<UploadSessionModel>(
          database: database,
          boxName: DatabaseTables.uploadSessions,
          fromJson: UploadSessionModel.fromJson,
          toJson: (UploadSessionModel item) => item.toJson(),
          idOf: (UploadSessionModel item) => item.id,
        );

  final AppDatabase database;
  final DocumentStore<UploadSessionModel> _store;

  static const String _identifier = 'UploadSessionLocalDataSourceImpl';

  @override
  Future<Either<AppException, UploadSessionModel?>> getSession(
    String id,
  ) async {
    try {
      return Right(await _store.readById(id));
    } catch (error) {
      return Left(_failure(error, 'getSession'));
    }
  }

  @override
  Future<Either<AppException, UploadSessionModel?>> getBySource(
    String sourceId,
  ) async {
    try {
      final List<UploadSessionModel> matches = await _store.where(
        (UploadSessionModel session) => session.sourceId == sourceId,
      );
      if (matches.isEmpty) return const Right(null);

      // Newest session wins.
      matches.sort(
        (UploadSessionModel a, UploadSessionModel b) =>
            b.createdAt.compareTo(a.createdAt),
      );
      return Right(matches.first);
    } catch (error) {
      return Left(_failure(error, 'getBySource'));
    }
  }

  @override
  Future<Either<AppException, List<UploadSessionModel>>> getOpenSessions() async {
    try {
      final List<UploadSessionModel> open = await _store.where(
        (UploadSessionModel session) => session.status.isOpen,
      );
      return Right(open);
    } catch (error) {
      return Left(_failure(error, 'getOpenSessions'));
    }
  }

  @override
  Future<Either<AppException, UploadSessionModel>> save(
    UploadSessionModel session,
  ) async {
    try {
      await _store.write(session);
      return Right(session);
    } catch (error) {
      return Left(_failure(error, 'save'));
    }
  }

  @override
  Future<Either<AppException, bool>> delete(String id) async {
    try {
      await _store.delete(id);
      return const Right(true);
    } catch (error) {
      return Left(_failure(error, 'delete'));
    }
  }

  @override
  Stream<List<UploadSessionModel>> watchAll() => _store.watch();

  @override
  Future<Either<AppException, bool>> clear() async {
    try {
      await _store.clear();
      return const Right(true);
    } catch (error) {
      return Left(_failure(error, 'clear'));
    }
  }

  AppException _failure(Object error, String method) {
    return FailureMapper.local(
      error,
      identifier: '$_identifier.$method',
      message: 'Could not read the upload state on this device.',
      statusCode: LocalErrorCodes.databaseFailure,
    );
  }
}
