import 'package:lekhan_ai/core/error/failure_mapper.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/upload/data/datasources/local/upload_session_local_datasource.dart';
import 'package:lekhan_ai/features/upload/data/models/upload_session_model.dart';
import 'package:lekhan_ai/features/upload/data/services/resumable_uploader.dart';
import 'package:lekhan_ai/features/upload/domain/entities/upload_run_result.dart';
import 'package:lekhan_ai/features/upload/domain/entities/upload_session.dart';
import 'package:lekhan_ai/features/upload/domain/repositories/upload_repository.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class UploadRepositoryImpl implements UploadRepository {
  UploadRepositoryImpl({required this.local, required this.uploader});

  final UploadSessionLocalDataSource local;
  final ResumableUploader uploader;

  static const String _identifier = 'UploadRepositoryImpl';

  @override
  Stream<List<UploadSession>> watchSessions({String? sourceId}) {
    return local.watchAll().map((List<UploadSessionModel> sessions) {
      final List<UploadSession> visible = sourceId == null
          ? List<UploadSession>.from(sessions)
          : sessions
              .where((UploadSessionModel session) => session.sourceId == sourceId)
              .toList();

      visible.sort(
        (UploadSession a, UploadSession b) => b.updatedAt.compareTo(a.updatedAt),
      );
      return List<UploadSession>.unmodifiable(visible);
    });
  }

  @override
  Future<Either<AppException, List<UploadSession>>> openSessions() async {
    final Either<AppException, List<UploadSessionModel>> result =
        await local.getOpenSessions();

    return result.map(
      (List<UploadSessionModel> sessions) =>
          sessions.cast<UploadSession>(),
    );
  }

  @override
  Future<Either<AppException, UploadSession?>> sessionFor(
    String sourceId,
  ) async {
    final Either<AppException, UploadSessionModel?> result =
        await local.getBySource(sourceId);

    return result.map((UploadSessionModel? session) => session);
  }

  @override
  Future<Either<AppException, UploadRunResult>> uploadNow({
    required ChapterSource source,
    required String chapterRemoteId,
    UploadProgressCallback? onProgress,
  }) {
    return uploader.run(
      source: source,
      chapterRemoteId: chapterRemoteId,
      onProgress: onProgress,
    );
  }

  @override
  Future<Either<AppException, bool>> cancel(String sourceId) async {
    try {
      await uploader.cancel(sourceId);
      return Right<AppException, bool>(true);
    } catch (error) {
      return Left<AppException, bool>(
        FailureMapper.from(
          error,
          identifier: '$_identifier.cancel',
          message: 'The upload could not be cancelled.',
        ),
      );
    }
  }
}
