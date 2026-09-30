import 'package:lekhan_ai/features/upload/domain/entities/upload_session.dart';
import 'package:lekhan_ai/features/upload/domain/repositories/upload_repository.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// Progress for the source list / upload centre.
///
/// The stream is what makes "waiting to upload" honest: it is fed by the local
/// session store, so it keeps working with the radio off.
class WatchUploadSessionsUsecase {
  const WatchUploadSessionsUsecase({required this.repository});

  final UploadRepository repository;

  Stream<List<UploadSession>> call({String? sourceId}) =>
      repository.watchSessions(sourceId: sourceId);
}

/// One-shot read of the sessions that can still make progress.
class GetOpenUploadsUsecase {
  const GetOpenUploadsUsecase({required this.repository});

  final UploadRepository repository;

  Future<Either<AppException, List<UploadSession>>> call() =>
      repository.openSessions();

  Future<Either<AppException, UploadSession?>> forSource(String sourceId) =>
      repository.sessionFor(sourceId);
}

/// "Cancel" on the progress card. The file itself is untouched - the user can
/// retry it later from the source list.
class CancelUploadUsecase {
  const CancelUploadUsecase({required this.repository});

  final UploadRepository repository;

  Future<Either<AppException, bool>> call(String sourceId) =>
      repository.cancel(sourceId);
}
