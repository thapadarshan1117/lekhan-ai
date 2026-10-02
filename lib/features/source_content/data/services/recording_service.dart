import 'dart:async';
import 'dart:io';

import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/permissions/permission_service.dart';
import 'package:lekhan_ai/core/storage/local_file_storage.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/add_existing_file_usecase.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';

/// Voice recording, wired straight into the offline write path.
///
/// The microphone writes into the app's own `recordings` staging area. When the
/// user stops, the file is handed to the repository, which copies it into the
/// chapter folder, writes the local record and queues the upload - exactly like
/// a picked file. Recording therefore needs no connection at all.
class RecordingService {
  RecordingService({
    required this.permissionService,
  });

  final PermissionService permissionService;

  final AudioRecorder _recorder = AudioRecorder();

  File? _target;
  Chapter? _chapter;
  Timer? _ticker;
  final StreamController<Duration> _elapsed =
      StreamController<Duration>.broadcast();

  DateTime? _startedAt;

  /// Elapsed time, for the timer in the recording sheet.
  Stream<Duration> get elapsed => _elapsed.stream;

  bool get isRecording => _target != null;

  /// Asks for the microphone once; the OS decides from then on.
  Future<bool> ensurePermission() async {
    final PermissionOutcome outcome =
        await permissionService.ensure(AppPermission.microphone);
    return outcome.granted;
  }

  /// Starts recording into the chapter's staging folder.
  Future<String?> start(Chapter chapter) async {
    if (!await ensurePermission()) {
      return 'Microphone permission is needed to record.';
    }

    try {
      // The recorder writes straight into the chapter's `recordings/` folder,
      // so stopping needs no copy - only a local record.
      final String path = await sl<LocalFileStorage>().reserveRecordingPath(
        projectId: chapter.projectId,
        bookId: chapter.bookId,
        chapterId: chapter.id,
      );

      final File file = File(path);
      await file.parent.create(recursive: true);

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
        path: path,
      );

      _target = file;
      _chapter = chapter;
      _startedAt = DateTime.now();

      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        final DateTime? started = _startedAt;
        if (started == null || _elapsed.isClosed) return;
        _elapsed.add(DateTime.now().difference(started));
      });

      return null;
    } catch (error) {
      await _cleanup();
      return 'Recording could not be started on this device.';
    }
  }

  /// Stops and files the recording as a chapter source.
  ///
  /// Returns the stored source, or an error message for the UI to show.
  Future<RecordingOutcome> stop() async {
    final Chapter? chapter = _chapter;

    if (chapter == null) {
      return const RecordingOutcome(error: 'Nothing is being recorded.');
    }

    String? recordedPath;
    try {
      recordedPath = await _recorder.stop();
    } catch (_) {
      recordedPath = _target?.path;
    }

    await _stopTicker();

    final File? file = recordedPath == null ? null : File(recordedPath);
    final bool exists = file != null && await file.exists();
    final int size = exists ? await file.length() : 0;

    _target = null;
    _chapter = null;

    if (!exists || size == 0) {
      // An empty take is usually a tap by mistake: drop the file, keep quiet.
      if (file != null && await file.exists()) {
        await file.delete();
      }
      return const RecordingOutcome(error: 'That recording was empty.');
    }

    final result = await sl<AddExistingFileUsecase>()(
      AddExistingFileParams(
        localPath: file.path,
        chapter: chapter,
        sourceType: SourceType.recording,
        displayName:
            'Voice recording – ${DateFormat('MMM d, yyyy, h:mm a').format(DateTime.now())}',
      ),
    );

    final ChapterSource? source = result.valueOrNull;
    if (source == null) {
      return RecordingOutcome(
        error: result.errorOrNull?.message ?? 'The recording could not be saved.',
      );
    }

    return RecordingOutcome(source: source);
  }

  /// Discards the current take.
  Future<void> cancel() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.cancel();
      }
    } catch (_) {
      // Nothing to cancel.
    }

    await _stopTicker();

    final File? target = _target;
    _target = null;
    _chapter = null;

    if (target != null && await target.exists()) {
      await target.delete();
    }
  }

  Future<void> dispose() async {
    await _stopTicker();
    await _elapsed.close();
    try {
      await _recorder.dispose();
    } catch (_) {
      // Already disposed.
    }
  }

  Future<void> _stopTicker() async {
    _ticker?.cancel();
    _ticker = null;
    _startedAt = null;
  }

  Future<void> _cleanup() async {
    await _stopTicker();
    _target = null;
    _chapter = null;
  }
}

/// Result of stopping a recording: either the stored source or something to say.
class RecordingOutcome {
  const RecordingOutcome({this.source, this.error});

  final ChapterSource? source;
  final String? error;

  bool get succeeded => source != null;
}
