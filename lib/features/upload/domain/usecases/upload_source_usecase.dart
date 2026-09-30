import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/upload/domain/entities/upload_run_result.dart';
import 'package:lekhan_ai/features/upload/domain/repositories/upload_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Runs (or resumes) the transfer of one source file.
///
/// Normal use never calls this directly: the sync engine runs it through
/// `SourceUploadHandler`. It is exposed for two explicit user actions:
///  * "Upload now" on a card when the user does not want to wait for the
///    scheduler,
///  * the retry half of the cancel/retry pair.
class UploadSourceUsecase
    implements UsecaseWithParam<UploadRunResult, UploadSourceParams> {
  const UploadSourceUsecase({required this.repository});

  final UploadRepository repository;

  @override
  Future<Either<AppException, UploadRunResult>> call(
    UploadSourceParams params,
  ) {
    return repository.uploadNow(
      source: params.source,
      chapterRemoteId: params.chapterRemoteId,
      onProgress: params.onProgress,
    );
  }
}

class UploadSourceParams {
  const UploadSourceParams({
    required this.source,
    required this.chapterRemoteId,
    this.onProgress,
  });

  final ChapterSource source;

  /// The chapter must exist on the server before a source can be attached to
  /// it, so this is resolved (local id -> remote id) before the call.
  final String chapterRemoteId;

  final UploadProgressCallback? onProgress;
}
