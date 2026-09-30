import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/repositories/book_repository.dart';
import 'package:lekhan_ai/features/projects/data/datasources/local/project_local_datasource.dart';
import 'package:lekhan_ai/features/projects/data/models/project_model.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class GetBooksUsecase
    implements UsecaseWithParam<List<Book>, GetBooksParams> {
  const GetBooksUsecase({required this.repository});

  final BookRepository repository;

  @override
  Future<Either<AppException, List<Book>>> call(
    GetBooksParams params,
  ) {
    return repository.getBooks(
      projectId: params.projectId,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetBooksParams {
  const GetBooksParams({
    this.projectId,
    this.forceRefresh = false,
  });

  final String? projectId;
  final bool forceRefresh;
}

class WatchBooksUsecase {
  const WatchBooksUsecase({required this.repository});

  final BookRepository repository;

  Stream<List<Book>> call({String? projectId}) =>
      repository.watchBooks(projectId: projectId);
}
