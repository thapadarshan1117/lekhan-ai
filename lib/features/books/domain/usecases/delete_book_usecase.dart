import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/repositories/book_repository.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/repositories/chapter_repository.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/delete_chapter_usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// Deletes all chapters and their local source files before their parent book.
class DeleteBookUsecase {
  const DeleteBookUsecase({
    required this.books,
    required this.chapters,
    required this.deleteChapter,
  });

  final BookRepository books;
  final ChapterRepository chapters;
  final DeleteChapterUsecase deleteChapter;

  Future<Either<AppException, bool>> call(String bookId) async {
    final Either<AppException, Book> found = await books.getBook(bookId);
    final Book? book = found.valueOrNull;
    if (book == null) {
      if (found.errorOrNull != null) {
        return Left<AppException, bool>(found.errorOrNull!);
      }
      return books.deleteLocal(bookId);
    }

    final Either<AppException, List<Chapter>> chapterResult =
        await chapters.getCachedChapters(bookId: book.id);
    final List<Chapter>? bookChapters = chapterResult.valueOrNull;
    if (bookChapters == null) {
      return Left<AppException, bool>(
        chapterResult.errorOrNull ??
            AppException(
              message: 'Book chapters could not be loaded for deletion.',
              statusCode: 500,
              identifier: 'DeleteBookUsecase.loadChapters',
            ),
      );
    }

    for (final Chapter chapter in bookChapters) {
      final Either<AppException, bool> deleted = await deleteChapter(chapter.id);
      if (deleted.valueOrNull != true) {
        return Left<AppException, bool>(
          deleted.errorOrNull ??
              AppException(
                message: 'A chapter could not be removed.',
                statusCode: 500,
                identifier: 'DeleteBookUsecase.deleteChapter',
              ),
        );
      }
    }

    return books.deleteLocal(book.id);
  }
}
