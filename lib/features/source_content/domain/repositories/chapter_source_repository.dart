import 'dart:io';

import 'package:lekhan_ai/core/enums/processing_status.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/enums/upload_status.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

abstract class ChapterSourceRepository {
  /// Local-first read.
  ///
  /// The local store always answers; the server is consulted only when
  /// [forceRefresh] is true *and* the chapter already has a remote id (there is
  /// nothing to fetch for a chapter that has never been online).
  Future<Either<AppException, List<ChapterSource>>> getSources({
    required String chapterId,
    String? chapterRemoteId,
    bool forceRefresh,
  });

  Future<Either<AppException, ChapterSource>> getSource(String id);

  Stream<List<ChapterSource>> watchSources({required String chapterId});

  /// The offline-first write:
  ///
  /// 1. the file is copied into the app's chapter folder,
  /// 2. a local record is created with `uploadStatus: pending`,
  /// 3. an upload task is queued,
  /// 4. the UI may immediately say "stored safely on device".
  ///
  /// Nothing on this path touches the network, so it cannot fail because the
  /// user just walked out of Wi-Fi range.
  Future<Either<AppException, ChapterSource>> addSource({
    required File file,
    required Chapter chapter,
    SourceType? sourceType,
    String? displayName,
    Duration? duration,
    String? createdBy,
  });

  /// Registers a file that already lives inside the chapter folder (voice
  /// recordings written by the recorder plugin).
  Future<Either<AppException, ChapterSource>> addExistingFile({
    required String localPath,
    required Chapter chapter,
    required SourceType sourceType,
    String? displayName,
    Duration? duration,
    String? createdBy,
  });

  Future<Either<AppException, bool>> deleteSource(String id);

  /// Puts a failed/paused source back in the queue and asks for a sync.
  Future<Either<AppException, ChapterSource>> retryUpload(String id);

  Future<Either<AppException, ChapterSource>> updateUploadStatus(
    String id, {
    UploadStatus? uploadStatus,
    double? uploadProgress,
    String? errorMessage,
    bool clearError,
    String? remoteId,
    String? remoteFileId,
    String? driveFileId,
  });

  Future<Either<AppException, ChapterSource>> updateProcessingStatus(
    String id,
    ProcessingStatus status,
  );

  Future<Either<AppException, int>> pendingCount(String chapterId);
}
