import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/l10n/l10n.dart';

/// Audio player for recordings and audio files.
class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key, required this.source});

  final ChapterSource source;

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      final File audioFile = File(widget.source.localPath);
      if (!audioFile.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.audioNotFound)),
          );
        }
        return;
      }

      await _audioPlayer.setFilePath(widget.source.localPath);

      _audioPlayer.playerStateStream.listen((PlayerState state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
        }
      });

      _audioPlayer.durationStream.listen((Duration? d) {
        if (mounted && d != null) {
          setState(() => _duration = d);
        }
      });

      _audioPlayer.positionStream.listen((Duration p) {
        if (mounted) {
          setState(() => _position = p);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.audioLoadError(e.toString()))),
        );
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void _skipBackward() {
    final Duration newPosition = _position - const Duration(seconds: 10);
    _audioPlayer.seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  void _skipForward() {
    final Duration newPosition = _position + const Duration(seconds: 10);
    if (newPosition > _duration) {
      _audioPlayer.seek(_duration);
    } else {
      _audioPlayer.seek(newPosition);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxMilliseconds =
        _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1;
    final double positionMilliseconds = _position.inMilliseconds
        .toDouble()
        .clamp(0, maxMilliseconds)
        .toDouble();
    final String recordingName = '${context.l10n.voiceRecording} · '
        '${MaterialLocalizations.of(context).formatShortDate(widget.source.createdAt)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.l10n.listenToRecording),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 48)
                    .clamp(0, double.infinity)
                    .toDouble(),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 132,
                    height: 132,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      size: 66,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    recordingName,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(widget.source.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 34),
                  Semantics(
                    label: context.l10n.recordingPosition,
                    value: context.l10n.positionOfDuration(
                      _formatDuration(_position),
                      _formatDuration(_duration),
                    ),
                    child: Slider(
                      value: positionMilliseconds,
                      max: maxMilliseconds,
                      onChanged: (double value) {
                        _audioPlayer.seek(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.primaryContainer,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          _formatDuration(_position),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        onPressed: _skipBackward,
                        tooltip: context.l10n.backTenSeconds,
                        icon: const Icon(Icons.replay_10_rounded),
                        iconSize: 38,
                        style: IconButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.primaryContainer,
                          minimumSize: const Size(66, 66),
                        ),
                      ),
                      const SizedBox(width: 18),
                      IconButton(
                        onPressed: _togglePlayPause,
                        tooltip: _isPlaying
                            ? context.l10n.pauseRecording
                            : context.l10n.playRecording,
                        icon: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        ),
                        iconSize: 48,
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(84, 84),
                        ),
                      ),
                      const SizedBox(width: 18),
                      IconButton(
                        onPressed: _skipForward,
                        tooltip: context.l10n.forwardTenSeconds,
                        icon: const Icon(Icons.forward_10_rounded),
                        iconSize: 38,
                        style: IconButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.primaryContainer,
                          minimumSize: const Size(66, 66),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isPlaying ? context.l10n.playing : context.l10n.paused,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final String minutes = '${duration.inMinutes}'.padLeft(2, '0');
    final String seconds = '${duration.inSeconds % 60}'.padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
