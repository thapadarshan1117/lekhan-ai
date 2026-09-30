import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/repositories/chapter_repository.dart';
import 'package:lekhan_ai/features/books/data/datasources/local/book_local_datasource.dart';
import 'package:lekhan_ai/features/books/data/models/book_model.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Local-first write: stored and queued before any HTTP call happens.
class SaveChapterUsecase implements UsecaseWithParam<Chapter, Chapter> {
  const SaveChapterUsecase({required this.repository});

  final ChapterRepository repository;

  @override
  Future<Either<AppException, Chapter>> call(Chapter chapter) {
    return repository.saveLocal(chapter);
  }
}
