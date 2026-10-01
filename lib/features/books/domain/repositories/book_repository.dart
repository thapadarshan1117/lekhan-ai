import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Single source of truth for books: local store first, backend when
/// it is reachable, and an explicit conflict rule in between.
abstract class BookRepository {
  Future<Either<AppException, List<Book>>> getBooks({
    String? projectId,
    bool forceRefresh,
  });

  /// Reads only the local cache, without consulting any remote datasource.
  Future<Either<AppException, List<Book>>> getCachedBooks({
    String? projectId,
  });

  Future<Either<AppException, Book>> getBook(String id);

  Stream<List<Book>> watchBooks({String? projectId});

  Future<Either<AppException, List<Book>>> refreshBooks({
    String? projectId,
  });

  /// Persists a local edit and queues it for the server.
  Future<Either<AppException, Book>> saveLocal(Book book);

  /// Removes a book locally and queues its server-side tombstone when needed.
  Future<Either<AppException, bool>> deleteLocal(String id);

  Future<Either<AppException, Book>> markSynced(
    String id, {
    String? remoteId,
  });

  /// Pulls the server copy of one record into the local store.
  Future<Either<AppException, Book>> refreshBook(String id);
}
