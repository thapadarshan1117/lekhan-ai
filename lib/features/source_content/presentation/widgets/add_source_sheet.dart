import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/source_content/data/services/recording_service.dart';
import 'package:lekhan_ai/features/source_content/presentation/bloc/sources_bloc/sources_bloc.dart';

/// "Add source material": pick a file, or record the author's voice.
///
/// Both routes end in the same place - a file inside the chapter folder and a
/// queued upload - so neither one needs a connection.
class AddSourceSheet {
  const AddSourceSheet._();

  static Future<void> show(BuildContext context, Chapter chapter) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddSourceSheetBody(chapter: chapter),
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

      if (!mounted) return;
      context.read<SourcesBloc>().add(
            SourcesEvent.fileAdded(file: File(path)),
          );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'That file could not be opened.';
      });
    }
  }

  Future<void> _startRecording() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final RecordingService recorder = sl<RecordingService>();
    final String? failure = await recorder.start(widget.chapter);

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _busy = false;
        _error = failure;
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
    setState(() => _busy = true);

    final RecordingService recorder = sl<RecordingService>();
    final RecordingOutcome outcome = await recorder.stop();

    await _elapsedSubscription?.cancel();
    _elapsedSubscription = null;

    if (!mounted) return;

    final String? path = outcome.source?.localPath;

    if (path == null) {
      setState(() {
        _busy = false;
        _recording = false;
        _error = outcome.error ?? 'The recording could not be saved.';
      });
      return;
    }

    // The file is already inside the chapter folder; the bloc registers it and
    // queues the upload.
    context.read<SourcesBloc>().add(
          SourcesEvent.recordingAdded(localPath: path),
        );
    Navigator.of(context).pop();
  }

  Future<void> _cancelRecording() async {
    await sl<RecordingService>().cancel();
    await _elapsedSubscription?.cancel();
    _elapsedSubscription = null;

    if (!mounted) return;
    setState(() {
      _recording = false;
      _elapsed = Duration.zero;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _recording ? 'Recording' : 'Add source material',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _recording
                  ? 'Speak normally. The file is saved on this device when you stop.'
                  : 'Anything you add is stored on this device first and uploads '
                      'automatically later.',
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            if (_recording)
              _RecordingControls(
                elapsed: _elapsed,
                busy: _busy,
                onStop: _stopRecording,
                onCancel: _cancelRecording,
              )
            else ...<Widget>[
              _OptionTile(
                icon: Icons.mic_none_outlined,
                title: 'Record voice',
                subtitle: 'Interview, dictation or a note to self',
                onTap: _busy ? null : _startRecording,
              ),
              const SizedBox(height: 10),
              _OptionTile(
                icon: Icons.upload_file_outlined,
                title: 'Choose a file',
                subtitle: 'Audio, video, PDF, photo or a scan',
                onTap: _busy ? null : _pickFile,
              ),
            ],
            if (_error != null) ...<Widget>[
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: <Widget>[
              const Icon(Icons.mic, color: AppColors.error, size: 30),
              const SizedBox(height: 10),
              Text(
                '$minutes:$seconds',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Recording…',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  foregroundColor: AppColors.textSecondary,
                ),
                child: const Text('Discard'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: busy ? null : onStop,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Stop & save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
