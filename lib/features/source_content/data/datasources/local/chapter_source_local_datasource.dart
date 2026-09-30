import 'package:lekhan_ai/core/database/app_database.dart';
import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/database/document_store.dart';
import 'package:lekhan_ai/core/enums/upload_status.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/features/source_content/data/models/chapter_source_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class ChapterSourceLocalDataSource {
  Future<Either<AppException, List<ChapterSourceModel>>> getSources();

  Future<Either<AppException, List<ChapterSourceModel>>> getSourcesByChapter(
    String chapterId,
  );

  Future<Either<AppException, ChapterSourceModel?>> getSource(String id);

  Future<Either<AppException, ChapterSourceModel?>> getSourceByRemoteId(
    String remoteId,
  );

  Future<Either<AppException, ChapterSourceModel>> save(
    ChapterSourceModel source,
  );

  Future<Either<AppException, List<ChapterSourceModel>>> saveAll(
    List<ChapterSourceModel> sources,
  );

  Future<Either<AppException, bool>> delete(String id);

  Future<Either<AppException, bool>> clear();

  /// How many sources of a chapter still have bytes to send.
  Future<Either<AppException, int>> pendingCount(String chapterId);

  /// `pending + failed`, used by the chapter screen badge.
  Future<Either<AppException, int>> unfinishedCount(String chapterId);

  Stream<List<ChapterSourceModel>> watchSources({String? chapterId});
}

class ChapterSourceLocalDataSourceImpl implements ChapterSourceLocalDataSource {
  ChapterSourceLocalDataSourceImpl({required this.database})
      : _store = DocumentStore<ChapterSourceModel>(
          database: database,
          boxName: DatabaseTables.chapterSources,
          fromJson: ChapterSourceModel.fromJson,
          toJson: (ChapterSourceModel item) => item.toJson(),
          idOf: (ChapterSourceModel item) => item.id,
        );

  final AppDatabase database;
  final DocumentStore<ChapterSourceModel> _store;

  static const String _identifier = 'ChapterSourceLocalDataSourceImpl';

  @override
  Future<Either<AppException, List<ChapterSourceModel>>> getSources() async {
    try {
      return Right(_sorted(await _store.readAll()));
    } catch (error) {
      return Left(_failure(error, 'getSources'));
    }
  }

  @override
  Future<Either<AppException, List<ChapterSourceModel>>> getSourcesByChapter(
    String chapterId,
  ) async {
    try {
      final List<ChapterSourceModel> items = await _store.where(
        (ChapterSourceModel item) => item.chapterId == chapterId,
      );
      return Right(_sorted(items));
    } catch (error) {
      return Left(_failure(error, 'getSourcesByChapter'));
    }
  }

  @override
  Future<Either<AppException, ChapterSourceModel?>> getSource(String id) async {
    try {
      return Right(await _store.readById(id));
    } catch (error) {
      return Left(_failure(error, 'getSource'));
    }
  }

  @override
  Future<Either<AppException, ChapterSourceModel?>> getSourceByRemoteId(
    String remoteId,
  ) async {
    try {
      return Right(await _store.readByAnyId(remoteId, remoteId: remoteId));
    } catch (error) {
      return Left(_failure(error, 'getSourceByRemoteId'));
    }
  }

  @override
  Future<Either<AppException, ChapterSourceModel>> save(
    ChapterSourceModel source,
  ) async {
    try {
      await _store.write(source);
      return Right(source);
    } catch (error) {
      return Left(_failure(error, 'save'));
    }
  }

  @override
  Future<Either<AppException, List<ChapterSourceModel>>> saveAll(
    List<ChapterSourceModel> sources,
  ) async {
    try {
      await _store.writeAll(sources);
      return Right(sources);
    } catch (error) {
      return Left(_failure(error, 'saveAll'));
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
  Future<Either<AppException, bool>> clear() async {
    try {
      await _store.clear();
      return const Right(true);
    } catch (error) {
      return Left(_failure(error, 'clear'));
    }
  }

  @override
  Future<Either<AppException, int>> pendingCount(String chapterId) async {
    try {
      final List<ChapterSourceModel> items = await _store.where(
        (ChapterSourceModel item) =>
            item.chapterId == chapterId &&
            item.uploadStatus.isActionable &&
            !item.isDeleted,
      );
      return Right(items.length);
    } catch (error) {
      return Left(_failure(error, 'pendingCount'));
    }
  }

  @override
  Future<Either<AppException, int>> unfinishedCount(String chapterId) async {
    try {
      final List<ChapterSourceModel> items = await _store.where(
        (ChapterSourceModel item) =>
            item.chapterId == chapterId &&
            item.uploadStatus != UploadStatus.uploaded &&
            !item.isDeleted,
      );
      return Right(items.length);
    } catch (error) {
      return Left(_failure(error, 'unfinishedCount'));
    }
  }

  @override
  Stream<List<ChapterSourceModel>> watchSources({String? chapterId}) {
    return _store.watch().map((List<ChapterSourceModel> items) {
      if (chapterId == null) return _sorted(items);
      return _sorted(
        items
            .where((ChapterSourceModel item) => item.chapterId == chapterId)
            .toList(),
      );
    });
  }

  List<ChapterSourceModel> _sorted(List<ChapterSourceModel> items) {
    final List<ChapterSourceModel> sorted = List<ChapterSourceModel>.of(items);
    sorted.sort(
      (ChapterSourceModel a, ChapterSourceModel b) =>
          a.createdAt.compareTo(b.createdAt),
    );
    return sorted;
  }

  AppException _failure(Object error, String method) {
    return FailureMapper.local(
      error,
      identifier: '$_identifier.$method',
      message: 'Could not read the saved source content.',
      statusCode: LocalErrorCodes.databaseFailure,
    );
  }
}
