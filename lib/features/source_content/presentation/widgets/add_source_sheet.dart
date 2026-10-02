import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/permissions/permission_service.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/source_content/data/services/recording_service.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/add_source_usecase.dart';
import 'package:lekhan_ai/l10n/l10n.dart';

/// A voice-first way to add the memories and ideas used to write a chapter.
///
/// Voice recording is deliberately the large, primary action. Files remain
/// available as a secondary route. Both are saved on this device first, so the
/// flow works without an internet connection.
class AddSourceSheet {
  const AddSourceSheet._();

  static Future<void> show(BuildContext context, Chapter chapter) {
    return _open(context, _AddSourceSheetBody(chapter: chapter));
  }

  /// Kept as a named entry point for chapter rows. The sheet writes through
  /// use cases directly, so it no longer needs a temporary bloc that could be
  /// closed before a selected file finishes saving.
  static Future<void> showWithChapter(
    BuildContext context,
    Chapter chapter,
  ) {
    return _open(context, _AddSourceSheetBody(chapter: chapter));
  }

  static Future<void> _open(BuildContext context, Widget child) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => child,
    );
  }
}

class _AddSourceSheetBody extends StatefulWidget {
  const _AddSourceSheetBody({required this.chapter});

  final Chapter chapter;

  @override
  State<_AddSourceSheetBody> createState() => _AddSourceSheetBodyState();
}

class _AddSourceSheetBodyState extends State<_AddSourceSheetBody> {
  bool _recording = false;
  bool _busy = false;
  Duration _elapsed = Duration.zero;
  StreamSubscription<Duration>? _elapsedSubscription;
  String? _error;

  @override
  void dispose() {
    _elapsedSubscription?.cancel();
    // The sheet cannot normally disappear while recording. This final guard
    // still releases the microphone if the route is removed by the system.
    if (_recording) {
      unawaited(sl<RecordingService>().cancel());
    }
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final FilePickerResult? picked = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: false,
      );
      final String? path = picked?.files.single.path;

      if (path == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }

      final result = await sl<AddSourceUsecase>()(
        AddSourceParams(file: File(path), chapter: widget.chapter),
      );

      if (!mounted) return;
      result.fold(
        (error) => setState(() {
          _busy = false;
          _error = error.message;
        }),
        (_) => Navigator.of(context).pop(),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = context.l10n.fileOpenError;
      });
    }
  }

  String _localizedRecordingError(String error) {
    final String normalized = error.toLowerCase();
    if (normalized.contains('microphone') ||
        normalized.contains('permission')) {
      return context.l10n.microphonePermissionNeeded;
    }
    if (normalized.contains('could not be started')) {
      return context.l10n.recordingStartFailed;
    }
    if (normalized.contains('nothing is being recorded')) {
      return context.l10n.nothingRecording;
    }
    if (normalized.contains('empty')) {
      return context.l10n.emptyRecording;
    }
    return context.l10n.couldNotSaveRecording;
  }

  Future<void> _startRecording() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _elapsed = Duration.zero;
      _error = null;
    });

    await HapticFeedback.mediumImpact();
    final RecordingService recorder = sl<RecordingService>();
    final String? failure = await recorder.start(widget.chapter);

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _busy = false;
        _error = _localizedRecordingError(failure);
      });
      return;
    }

    _elapsedSubscription = recorder.elapsed.listen((Duration value) {
      if (mounted) setState(() => _elapsed = value);
    });

    setState(() {
      _busy = false;
      _recording = true;
    });
  }

  Future<void> _stopRecording() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    await HapticFeedback.heavyImpact();
    final RecordingOutcome outcome = await sl<RecordingService>().stop();

    await _elapsedSubscription?.cancel();
    _elapsedSubscription = null;

    if (!mounted) return;

    if (!outcome.succeeded) {
      setState(() {
        _busy = false;
        _recording = false;
        _elapsed = Duration.zero;
        _error = outcome.error == null
            ? context.l10n.couldNotSaveRecording
            : _localizedRecordingError(outcome.error!);
      });
      return;
    }

    // RecordingService has already stored the source and queued its upload.
    // The bloc's local watcher will display it without writing a duplicate.
    setState(() {
      _busy = false;
      _recording = false;
    });
    Navigator.of(context).pop();
  }

  Future<void> _cancelRecording() async {
    await sl<RecordingService>().cancel();
    await _elapsedSubscription?.cancel();
    _elapsedSubscription = null;

    if (!mounted) return;
    setState(() {
      _recording = false;
      _busy = false;
      _elapsed = Duration.zero;
      _error = null;
    });
  }

  Future<bool> _canLeave() async {
    if (_busy) return false;
    if (!_recording) return true;

    final bool discard =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.discardRecordingQuestion),
        content: Text(dialogContext.l10n.unsavedRecordingWarning),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(dialogContext.l10n.keepRecording),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(dialogContext.l10n.discard),
              ),
            ],
          ),
        ) ??
        false;

    if (discard) await _cancelRecording();
    return discard;
  }

  Future<void> _requestDiscard() async {
    // `_canLeave` shows the confirmation and performs the discard, but this
    // button intentionally keeps the sheet open so another take can begin.
    await _canLeave();
  }

  Future<void> _close() async {
    if (await _canLeave() && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: _canLeave,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + keyboard),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _SheetHeader(
                    recording: _recording,
                    closeEnabled: !_busy,
                    onClose: _close,
                  ),
                  const SizedBox(height: 20),
                  if (_recording)
                    _RecordingControls(
                      elapsed: _elapsed,
                      busy: _busy,
                      onStop: _stopRecording,
                      onCancel: _requestDiscard,
                    )
                  else
                    _VoiceFirstOptions(
                      busy: _busy,
                      onRecord: _startRecording,
                      onFile: _pickFile,
                    ),
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: 16),
                    _ErrorMessage(
                      message: _error!,
                      onOpenSettings:
                          _error!.toLowerCase().contains('microphone') ||
                                  _error!.contains('माइक्रोफोन')
                              ? () => sl<PermissionService>().openSettings()
                              : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const _PrivacyNote(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.recording,
    required this.closeEnabled,
    required this.onClose,
  });

  final bool recording;
  final bool closeEnabled;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: recording
                ? AppColors.errorContainer
                : AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            recording ? Icons.graphic_eq : Icons.mic_rounded,
            color: recording ? AppColors.error : AppColors.primary,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                recording
                    ? context.l10n.recordingYourVoice
                    : context.l10n.tellYourStory,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                recording
                    ? context.l10n.speakNaturally
                    : context.l10n.voiceIsEasiest,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: closeEnabled ? onClose : null,
          tooltip: context.l10n.close,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _VoiceFirstOptions extends StatelessWidget {
  const _VoiceFirstOptions({
    required this.busy,
    required this.onRecord,
    required this.onFile,
  });

  final bool busy;
  final VoidCallback onRecord;
  final VoidCallback onFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          button: true,
          label: context.l10n.startRecordingSemantics,
          hint: context.l10n.startRecordingHint,
          child: Material(
            color: AppColors.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: AppColors.primary, width: 2),
            ),
            child: InkWell(
              onTap: busy ? null : onRecord,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.l10n.recommended,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: 92,
                      height: 92,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: busy
                          ? const Padding(
                              padding: EdgeInsets.all(28),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 4,
                              ),
                            )
                          : const Icon(
                              Icons.mic_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      busy
                          ? context.l10n.openingMicrophone
                          : context.l10n.startVoiceRecording,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.tapThenSpeak,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          context.l10n.otherWaysToAdd,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: busy ? null : onFile,
          icon: const Icon(Icons.attach_file_rounded, size: 24),
          label: Text(context.l10n.chooseFile),
        ),
      ],
    );
  }
}

class _RecordingControls extends StatelessWidget {
  const _RecordingControls({
    required this.elapsed,
    required this.busy,
    required this.onStop,
    required this.onCancel,
  });

  final Duration elapsed;
  final bool busy;
  final VoidCallback onStop;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final String minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final String seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          label: context.l10n.recordingElapsed(minutes, seconds),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 82,
                  height: 82,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.l10n.recordingNow,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(
                    fontSize: 42,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.speakAtOwnPace,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: busy ? null : onStop,
          icon: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(Icons.stop_rounded, size: 28),
          label: Text(
            busy ? context.l10n.savingRecording : context.l10n.stopAndSave,
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 62),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: busy ? null : onCancel,
          icon: const Icon(Icons.delete_outline_rounded, size: 24),
          label: Text(context.l10n.discardAndRestart),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.outline, width: 1.5),
          ),
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, this.onOpenSettings});

  final String message;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.error_outline, color: AppColors.error, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onErrorContainer,
                    ),
                  ),
                  if (onOpenSettings != null) ...<Widget>[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: onOpenSettings,
                      icon: const Icon(Icons.settings_outlined, size: 21),
                      label: Text(context.l10n.openPhoneSettings),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(
          Icons.lock_outline_rounded,
          size: 21,
          color: AppColors.primary,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            context.l10n.offlineRecordingSafe,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
