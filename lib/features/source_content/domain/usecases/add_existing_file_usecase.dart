import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/repositories/chapter_source_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Registers a file that is **already** inside the app's store.
///
/// Used by the voice recorder: the recorder plugin writes straight into the
/// chapter's `recordings/` folder, so there is nothing to copy - the record
/// still has to be created and the upload queued, exactly like a picked file.
class AddExistingFileUsecase
    implements UsecaseWithParam<ChapterSource, AddExistingFileParams> {
  const AddExistingFileUsecase({required this.repository});

  final ChapterSourceRepository repository;

  @override
  Future<Either<AppException, ChapterSource>> call(
    AddExistingFileParams params,
  ) {
    return repository.addExistingFile(
      localPath: params.localPath,
      chapter: params.chapter,
      sourceType: params.sourceType,
      displayName: params.displayName,
      duration: params.duration,
      createdBy: params.createdBy,
    );
  }
}

class AddExistingFileParams {
  const AddExistingFileParams({
    required this.localPath,
    required this.chapter,
    required this.sourceType,
    this.displayName,
    this.duration,
    this.createdBy,
  });

  final String localPath;
  final Chapter chapter;
  final SourceType sourceType;
  final String? displayName;
  final Duration? duration;
  final String? createdBy;
}
