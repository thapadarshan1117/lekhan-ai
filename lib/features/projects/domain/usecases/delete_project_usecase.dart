import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/repositories/book_repository.dart';
import 'package:lekhan_ai/features/books/domain/usecases/delete_book_usecase.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/repositories/project_repository.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// Deletes all books, chapters, and source files before their parent project.
class DeleteProjectUsecase {
  const DeleteProjectUsecase({
    required this.projects,
    required this.books,
    required this.deleteBook,
  });

  final ProjectRepository projects;
  final BookRepository books;
  final DeleteBookUsecase deleteBook;

  Future<Either<AppException, bool>> call(String projectId) async {
    final Either<AppException, Project> found =
        await projects.getProject(projectId);
    final Project? project = found.valueOrNull;
    if (project == null) {
      if (found.errorOrNull != null) {
        return Left<AppException, bool>(found.errorOrNull!);
      }
      return projects.deleteLocal(projectId);
    }

    final Either<AppException, List<Book>> bookResult =
        await books.getCachedBooks(projectId: project.id);
    final List<Book>? projectBooks = bookResult.valueOrNull;
    if (projectBooks == null) {
      return Left<AppException, bool>(
        bookResult.errorOrNull ??
            AppException(
              message: 'Project books could not be loaded for deletion.',
              statusCode: 500,
              identifier: 'DeleteProjectUsecase.loadBooks',
            ),
      );
    }

    for (final Book book in projectBooks) {
      final Either<AppException, bool> deleted = await deleteBook(book.id);
      if (deleted.valueOrNull != true) {
        return Left<AppException, bool>(
          deleted.errorOrNull ??
              AppException(
                message: 'A book could not be removed.',
                statusCode: 500,
                identifier: 'DeleteProjectUsecase.deleteBook',
              ),
        );
      }
    }

    return projects.deleteLocal(project.id);
  }
}
