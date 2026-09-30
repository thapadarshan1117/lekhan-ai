import 'package:lekhan_ai/core/database/app_database.dart';
import 'package:lekhan_ai/core/database/database_tables.dart';
import 'package:lekhan_ai/core/database/document_store.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class BookLocalDataSource {
  Future<Either<AppException, List<BookModel>>> getBooks();

  Future<Either<AppException, List<BookModel>>> getBooksByProject(
    String projectId,
  );

  Future<Either<AppException, BookModel?>> getBook(String id);

  Future<Either<AppException, BookModel?>> getBookByRemoteId(
    String remoteId,
  );

  Future<Either<AppException, BookModel>> save(BookModel book);

  Future<Either<AppException, List<BookModel>>> saveAll(
    List<BookModel> books,
  );

  Future<Either<AppException, bool>> delete(String id);

  Future<Either<AppException, bool>> clear();

  /// Local stream, optionally scoped to one parent.
  Stream<List<BookModel>> watchBooks({String? projectId});
}

class BookLocalDataSourceImpl implements BookLocalDataSource {
  BookLocalDataSourceImpl({required this.database})
      : _store = DocumentStore<BookModel>(
          database: database,
          boxName: DatabaseTables.books,
          fromJson: BookModel.fromJson,
          toJson: (BookModel item) => item.toJson(),
          idOf: (BookModel item) => item.id,
        );

  final AppDatabase database;
  final DocumentStore<BookModel> _store;

  static const String _identifier = 'BookLocalDataSourceImpl';

  @override
  Future<Either<AppException, List<BookModel>>> getBooks() async {
    try {
      final List<BookModel> items = await _store.readAll();
      items.sort((BookModel a, BookModel b) => b.createdAt.compareTo(a.createdAt));
      return Right(items);
    } catch (error) {
      return Left(_failure(error, 'getBooks', 'Could not read the saved books.'));
    }
  }

  @override
  Future<Either<AppException, List<BookModel>>> getBooksByProject(
    String projectId,
  ) async {
    try {
      final List<BookModel> items = await _store.where(
        (BookModel item) => item.projectId == projectId,
      );
      items.sort((BookModel a, BookModel b) => b.createdAt.compareTo(a.createdAt));
      return Right(items);
    } catch (error) {
      return Left(_failure(error, 'getBooksByProject', 'Could not read the saved books.'));
    }
  }

  @override
  Future<Either<AppException, BookModel?>> getBook(String id) async {
    try {
      return Right(await _store.readById(id));
    } catch (error) {
      return Left(_failure(error, 'getBook', 'Could not read the book.'));
    }
  }

  @override
  Future<Either<AppException, BookModel?>> getBookByRemoteId(
    String remoteId,
  ) async {
    try {
      return Right(await _store.readByAnyId(remoteId, remoteId: remoteId));
    } catch (error) {
      return Left(_failure(error, 'getBookByRemoteId', 'Could not read the book.'));
    }
  }

  @override
  Future<Either<AppException, BookModel>> save(BookModel book) async {
    try {
      await _store.write(book);
      return Right(book);
    } catch (error) {
      return Left(_failure(error, 'save', 'Could not save the book on this device.'));
    }
  }

  @override
  Future<Either<AppException, List<BookModel>>> saveAll(
    List<BookModel> books,
  ) async {
    try {
      await _store.writeAll(books);
      return Right(books);
    } catch (error) {
      return Left(_failure(error, 'saveAll', 'Could not save the books on this device.'));
    }
  }

  @override
  Future<Either<AppException, bool>> delete(String id) async {
    try {
      await _store.delete(id);
      return const Right(true);
    } catch (error) {
      return Left(_failure(error, 'delete', 'Could not remove the book.'));
    }
  }

  @override
  Future<Either<AppException, bool>> clear() async {
    try {
      await _store.clear();
      return const Right(true);
    } catch (error) {
      return Left(_failure(error, 'clear', 'Could not clear the saved books.'));
    }
  }

  @override
  Stream<List<BookModel>> watchBooks({String? projectId}) {
    final Stream<List<BookModel>> source = _store.watch();
    if (projectId == null) {
      return source.map((List<BookModel> items) {
        final List<BookModel> sorted = List<BookModel>.of(items)
          ..sort((BookModel a, BookModel b) => b.createdAt.compareTo(a.createdAt));
        return sorted;
      });
    }
    return source.map((List<BookModel> items) {
      final List<BookModel> filtered = items
          .where((BookModel item) => item.projectId == projectId)
          .toList()
        ..sort((BookModel a, BookModel b) => b.createdAt.compareTo(a.createdAt));
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
