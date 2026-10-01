import 'package:lekhan_ai/features/upload/domain/entities/upload_session.dart';

/// How a single resumable upload run ended.
///
/// Lives in the domain layer so use cases can return it without depending on
/// the uploader implementation.
class UploadRunResult {
  const UploadRunResult({
    required this.session,
    required this.completed,
    this.remoteSourceId,
    this.remoteFileId,
    this.driveFileId,
    this.processingStatus,
    this.expiredSession = false,
  });

  final UploadSession session;
  final bool completed;
  final String? remoteSourceId;
  final String? remoteFileId;
  final String? driveFileId;
  final String? processingStatus;

  /// True when the server rejected the session URL and a new one is required.
  final bool expiredSession;
}

/// Progress callback signature: (fraction 0..1, absolute bytes sent).
typedef UploadProgressCallback = void Function(double progress, int bytesSent);
