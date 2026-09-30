import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/upload/domain/entities/upload_run_result.dart';
import 'package:lekhan_ai/features/upload/domain/entities/upload_session.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// The upload session is the piece of state that makes a 500 MB transfer
/// resumable, so the UI reads it through a repository rather than touching the
/// local store or the HTTP layer.
///
/// Nothing here is required for correctness of the offline write path: a source
/// is already safe on disk and queued for sync before any session exists.
abstract class UploadRepository {
  /// Live sessions (newest first), optionally narrowed to one source.
  Stream<List<UploadSession>> watchSessions({String? sourceId});

  /// Sessions that can still make progress (pending/active/completing).
  Future<Either<AppException, List<UploadSession>>> openSessions();

  Future<Either<AppException, UploadSession?>> sessionFor(String sourceId);

  /// Runs (or resumes) the transfer of one source file.
  ///
  /// Called by the sync handler during a normal pass, and by "Upload now" when
  /// the user does not want to wait for the scheduler.
  Future<Either<AppException, UploadRunResult>> uploadNow({
    required ChapterSource source,
    required String chapterRemoteId,
    UploadProgressCallback? onProgress,
  });

  /// User-initiated cancel: forgets the session locally and tells the server.
  /// The queued sync task is left alone - the caller decides whether the
  /// source itself is deleted or simply retried later.
  Future<Either<AppException, bool>> cancel(String sourceId);
}
