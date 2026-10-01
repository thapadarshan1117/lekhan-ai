import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/repositories/chapter_repository.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/repositories/chapter_source_repository.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/delete_source_usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// Deletes a chapter and its source files from this device, then queues remote
/// tombstones in child-before-parent order.
class DeleteChapterUsecase {
  const DeleteChapterUsecase({
    required this.chapters,
    required this.sources,
    required this.deleteSource,
  });

  final ChapterRepository chapters;
  final ChapterSourceRepository sources;
  final DeleteSourceUsecase deleteSource;

  Future<Either<AppException, bool>> call(String chapterId) async {
    final Either<AppException, Chapter> found =
        await chapters.getChapter(chapterId);
    final Chapter? chapter = found.valueOrNull;
    if (chapter == null) {
      if (found.errorOrNull != null) {
        return Left<AppException, bool>(found.errorOrNull!);
      }
      return chapters.deleteLocal(chapterId);
    }

    final Either<AppException, List<ChapterSource>> sourceResult =
        await sources.getSources(
      chapterId: chapter.id,
      chapterRemoteId: chapter.remoteId,
      forceRefresh: false,
    );
    final List<ChapterSource>? chapterSources = sourceResult.valueOrNull;
    if (chapterSources == null) {
      return Left<AppException, bool>(
        sourceResult.errorOrNull ??
            AppException(
              message: 'Chapter sources could not be loaded for deletion.',
              statusCode: 500,
              identifier: 'DeleteChapterUsecase.loadSources',
            ),
      );
    }

    for (final ChapterSource source in chapterSources) {
      final Either<AppException, bool> deleted = await deleteSource(
        DeleteSourceParams(sourceId: source.id, chapterId: chapter.id),
      );
      if (deleted.valueOrNull != true) {
        return Left<AppException, bool>(
          deleted.errorOrNull ??
              AppException(
                message: 'A source file could not be removed.',
                statusCode: 500,
                identifier: 'DeleteChapterUsecase.deleteSource',
              ),
        );
      }
    }

    return chapters.deleteLocal(chapter.id);
  }
}
