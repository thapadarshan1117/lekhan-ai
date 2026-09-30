import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/repositories/chapter_repository.dart';
import 'package:lekhan_ai/features/books/data/datasources/local/book_local_datasource.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class GetChaptersUsecase
    implements UsecaseWithParam<List<Chapter>, GetChaptersParams> {
  const GetChaptersUsecase({required this.repository});

  final ChapterRepository repository;

  @override
  Future<Either<AppException, List<Chapter>>> call(
    GetChaptersParams params,
  ) {
    return repository.getChapters(
      bookId: params.bookId,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetChaptersParams {
  const GetChaptersParams({
    this.bookId,
    this.forceRefresh = false,
  });

  final String? bookId;
  final bool forceRefresh;
}

class WatchChaptersUsecase {
  const WatchChaptersUsecase({required this.repository});

  final ChapterRepository repository;

  Stream<List<Chapter>> call({String? bookId}) =>
      repository.watchChapters(bookId: bookId);
}
