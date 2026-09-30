import 'package:lekhan_ai/core/database/app_database.dart';
import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/database/document_store.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/features/chapters/data/models/chapter_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class ChapterLocalDataSource {
  Future<Either<AppException, List<ChapterModel>>> getChapters();

  Future<Either<AppException, List<ChapterModel>>> getChaptersByBook(
    String bookId,
  );

  Future<Either<AppException, ChapterModel?>> getChapter(String id);

  Future<Either<AppException, ChapterModel?>> getChapterByRemoteId(
    String remoteId,
  );

  Future<Either<AppException, ChapterModel>> save(ChapterModel chapter);

  Future<Either<AppException, List<ChapterModel>>> saveAll(
    List<ChapterModel> chapters,
  );

  Future<Either<AppException, bool>> delete(String id);

  Future<Either<AppException, bool>> clear();

  /// Local stream, optionally scoped to one parent.
  Stream<List<ChapterModel>> watchChapters({String? bookId});
}

class ChapterLocalDataSourceImpl implements ChapterLocalDataSource {
  ChapterLocalDataSourceImpl({required this.database})
      : _store = DocumentStore<ChapterModel>(
          database: database,
          boxName: DatabaseTables.chapters,
          fromJson: ChapterModel.fromJson,
          toJson: (ChapterModel item) => item.toJson(),
          idOf: (ChapterModel item) => item.id,
        );

  final AppDatabase database;
  final DocumentStore<ChapterModel> _store;

  static const String _identifier = 'ChapterLocalDataSourceImpl';

  @override
  Future<Either<AppException, List<ChapterModel>>> getChapters() async {
    try {
      final List<ChapterModel> items = await _store.readAll();
      items.sort((ChapterModel a, ChapterModel b) => a.number.compareTo(b.number));
      return Right(items);
    } catch (error) {
      return Left(_failure(error, 'getChapters', 'Could not read the saved chapters.'));
    }
  }

  @override
  Future<Either<AppException, List<ChapterModel>>> getChaptersByBook(
    String bookId,
  ) async {
    try {
      final List<ChapterModel> items = await _store.where(
        (ChapterModel item) => item.bookId == bookId,
      );
      items.sort((ChapterModel a, ChapterModel b) => a.number.compareTo(b.number));
      return Right(items);
    } catch (error) {
      return Left(_failure(error, 'getChaptersByBook', 'Could not read the saved chapters.'));
    }
  }

  @override
  Future<Either<AppException, ChapterModel?>> getChapter(String id) async {
    try {
      return Right(await _store.readById(id));
    } catch (error) {
      return Left(_failure(error, 'getChapter', 'Could not read the chapter.'));
    }
  }

  @override
  Future<Either<AppException, ChapterModel?>> getChapterByRemoteId(
    String remoteId,
  ) async {
    try {
      return Right(await _store.readByAnyId(remoteId, remoteId: remoteId));
    } catch (error) {
      return Left(_failure(error, 'getChapterByRemoteId', 'Could not read the chapter.'));
    }
  }

  @override
  Future<Either<AppException, ChapterModel>> save(ChapterModel chapter) async {
    try {
      await _store.write(chapter);
      return Right(chapter);
    } catch (error) {
      return Left(_failure(error, 'save', 'Could not save the chapter on this device.'));
    }
  }

  @override
  Future<Either<AppException, List<ChapterModel>>> saveAll(
    List<ChapterModel> chapters,
  ) async {
    try {
      await _store.writeAll(chapters);
      return Right(chapters);
    } catch (error) {
      return Left(_failure(error, 'saveAll', 'Could not save the chapters on this device.'));
    }
  }

  @override
  Future<Either<AppException, bool>> delete(String id) async {
    try {
      await _store.delete(id);
      return const Right(true);
    } catch (error) {
      return Left(_failure(error, 'delete', 'Could not remove the chapter.'));
    }
  }

  @override
  Future<Either<AppException, bool>> clear() async {
    try {
      await _store.clear();
      return const Right(true);
    } catch (error) {
      return Left(_failure(error, 'clear', 'Could not clear the saved chapters.'));
    }
  }

  @override
  Stream<List<ChapterModel>> watchChapters({String? bookId}) {
    final Stream<List<ChapterModel>> source = _store.watch();
    if (bookId == null) {
      return source.map((List<ChapterModel> items) {
        final List<ChapterModel> sorted = List<ChapterModel>.of(items)
          ..sort((ChapterModel a, ChapterModel b) => a.number.compareTo(b.number));
        return sorted;
      });
    }
    return source.map((List<ChapterModel> items) {
      final List<ChapterModel> filtered = items
          .where((ChapterModel item) => item.bookId == bookId)
          .toList()
        ..sort((ChapterModel a, ChapterModel b) => a.number.compareTo(b.number));
      return filtered;
    });
  }

  AppException _failure(Object error, String method, String message) {
    return FailureMapper.local(
      error,
      identifier: '$_identifier.$method',
      message: message,
      statusCode: LocalErrorCodes.databaseFailure,
    );
  }
}
