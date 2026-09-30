import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/repositories/chapter_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Saves the word count (and optionally the status) of a chapter.
///
/// This is the write that happens most often while writing, so it is deliberately
/// cheap: the number goes to the local store immediately and a small `progress`
/// task is queued, rather than pushing a whole chapter update.
class UpdateChapterProgressUsecase
    implements UsecaseWithParam<Chapter, UpdateChapterProgressParams> {
  const UpdateChapterProgressUsecase({required this.repository});

  final ChapterRepository repository;

  @override
  Future<Either<AppException, Chapter>> call(
    UpdateChapterProgressParams params,
  ) {
    return repository.updateProgress(
      chapterId: params.chapterId,
      currentWords: params.currentWords,
      status: params.status,
    );
  }
}

class UpdateChapterProgressParams {
  const UpdateChapterProgressParams({
    required this.chapterId,
    required this.currentWords,
    this.status,
  });

  final String chapterId;
  final int currentWords;
  final ChapterStatus? status;
}
