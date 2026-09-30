import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/repositories/book_repository.dart';
import 'package:lekhan_ai/features/projects/data/datasources/local/project_local_datasource.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Local-first write: stored and queued before any HTTP call happens.
class SaveBookUsecase implements UsecaseWithParam<Book, Book> {
  const SaveBookUsecase({required this.repository});

  final BookRepository repository;

  @override
  Future<Either<AppException, Book>> call(Book book) {
    return repository.saveLocal(book);
  }
}
