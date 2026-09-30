import 'package:uuid/uuid.dart';

/// All local identifiers are created here so the format stays consistent.
///
/// Local ids are *not* server ids: they exist before the record has ever been
/// online and are what the sync queue and the local file tree key off. When the
/// backend answers with a `remoteId` both are stored side by side.
class IdGenerator {
  IdGenerator._();

  static final Uuid _uuid = Uuid();

  /// Bare v4 uuid, used for sync tasks and upload sessions.
  static String newUuid() => _uuid.v4();

  /// Prefixed uuid, short enough to read inside a log line or a file name.
  static String newId(String prefix) {
    final String compact = _uuid.v4().replaceAll('-', '');
    return '${prefix}_${compact.substring(0, 16)}';
  }

  static String projectId() => newId('prj');
  static String bookId() => newId('bok');
  static String chapterId() => newId('chp');
  static String sourceId() => newId('src');
  static String uploadId() => newId('upl');
  static String taskId() => newId('tsk');
  static String recordingId() => newId('rec');
}
