import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/core/enums/processing_status.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/enums/upload_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/l10n/l10n.dart';

/// One piece of source material, with the upload state made visible.
///
/// The tile answers the two questions that actually matter to the writer:
/// "did it save?" and "has it reached the server yet?".
class SourceTile extends StatelessWidget {
  const SourceTile({
    super.key,
    required this.source,
    this.onDelete,
    this.onRetry,
  });

  final ChapterSource source;
  final VoidCallback? onDelete;
  final VoidCallback? onRetry;

  void _openViewer(BuildContext context) {
    // Allow opening if the file exists locally, even if still uploading to server.
    // The file is stored on device, so there's no reason to block viewing it.
    // Only block if it's truly unavailable (failed upload with file deleted, etc).
    if (source.hasFailed && source.errorMessage?.contains('no longer on this device') == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(source.errorMessage ?? context.l10n.fileUnavailable),
        ),
      );
      return;
    }

    switch (source.sourceType) {
      case SourceType.image:
        context.pushNamed('imageViewer', extra: source);
        break;
      case SourceType.audio:
      case SourceType.recording:
        context.pushNamed('audioPlayer', extra: source);
        break;
      case SourceType.video:
        context.pushNamed('videoPlayer', extra: source);
        break;
      case SourceType.document:
        // Try PDF first, fall back to document viewer
        if (source.extension.toLowerCase() == 'pdf') {
          context.pushNamed('pdfViewer', extra: source);
        } else {
          context.pushNamed('documentViewer', extra: source);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVoice = source.sourceType == SourceType.audio ||
        source.sourceType == SourceType.recording;
    final String displayName = isVoice
        ? '${context.l10n.voiceRecording} · '
            '${MaterialLocalizations.of(context).formatShortDate(source.createdAt)}'
        : source.name;
    final String typeLabel =
        isVoice ? context.l10n.voiceRecording : context.l10n.savedFile;

    return Semantics(
      button: true,
      label: context.l10n.sourceSemantics(typeLabel, displayName),
      hint: isVoice
          ? context.l10n.doubleTapListen
          : context.l10n.doubleTapOpen,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.lekhan_aiBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openViewer(context),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _TypeIcon(type: source.sourceType),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            displayName,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _subtitle(context, source),
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (isVoice) ...<Widget>[
                            const SizedBox(height: 6),
                            Text(
                              context.l10n.tapToListen,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded),
                        tooltip: context.l10n.removeThisItem,
                        style: IconButton.styleFrom(
                          foregroundColor: AppColors.error,
                          backgroundColor: AppColors.errorContainer,
                          minimumSize: const Size(50, 50),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _UploadStateRow(source: source, onRetry: onRetry),
                if (source.uploadStatus == UploadStatus.uploaded &&
                    source.processingStatus != ProcessingStatus.notStarted) ...<Widget>[
                  const SizedBox(height: 8),
                  _ProcessingStateRow(status: source.processingStatus),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _subtitle(BuildContext context, ChapterSource source) {
    final String size = source.readableSize;

    switch (source.sourceType) {
      case SourceType.audio:
      case SourceType.recording:
        return context.l10n.voiceDetails(
          size,
          source.duration == null ? '' : ' · ${source.readableDuration}',
        );
      case SourceType.video:
        return context.l10n.videoDetails(size);
      case SourceType.image:
        return context.l10n.imageDetails(size);
      case SourceType.document:
        return context.l10n.documentDetails(size);
    }
  }
}

/// Processing is an independent backend state: uploaded bytes do not mean the
/// document/audio has finished transcription or ingestion.
class _ProcessingStateRow extends StatelessWidget {
  const _ProcessingStateRow({required this.status});

  final ProcessingStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = status == ProcessingStatus.completed
        ? const Color(0xFF1B7F4B)
        : status == ProcessingStatus.failed
            ? AppColors.error
            : AppColors.secondary;
    final IconData icon = status == ProcessingStatus.completed
        ? Icons.check_circle_outline
        : status == ProcessingStatus.failed
            ? Icons.error_outline
            : Icons.sync;
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          context.l10n.processingStatus(_processingLabel(context, status)),
          style: TextStyle(fontSize: 14, color: color),
        ),
      ],
    );
  }

  static String _processingLabel(
    BuildContext context,
    ProcessingStatus status,
  ) {
    switch (status) {
      case ProcessingStatus.notStarted:
        return context.l10n.processingNotStarted;
      case ProcessingStatus.queued:
        return context.l10n.processingQueued;
      case ProcessingStatus.transcribing:
        return context.l10n.processingTranscribing;
      case ProcessingStatus.diarizing:
        return context.l10n.processingDiarizing;
      case ProcessingStatus.ingesting:
        return context.l10n.processingIngesting;
      case ProcessingStatus.completed:
        return context.l10n.processingReady;
      case ProcessingStatus.failed:
        return context.l10n.processingFailed;
    }
  }
}

/// The upload badge / progress bar / retry button.
class _UploadStateRow extends StatelessWidget {
  const _UploadStateRow({required this.source, this.onRetry});

  final ChapterSource source;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    switch (source.uploadStatus) {
      case UploadStatus.uploaded:
        return _StatusLine(
          icon: Icons.cloud_done_outlined,
          color: const Color(0xFF1B7F4B),
          label: context.l10n.backedUp,
        );

      case UploadStatus.pending:
        return _StatusLine(
          icon: Icons.cloud_upload_outlined,
          color: AppColors.secondary,
          label: context.l10n.savedOnDevice,
        );

      case UploadStatus.preparing:
        return _StatusLine(
          icon: Icons.hourglass_empty,
          color: AppColors.secondary,
          label: context.l10n.gettingReadyBackup,
        );

      case UploadStatus.paused:
        return _StatusLine(
          icon: Icons.pause_circle_outline,
          color: AppColors.secondary,
          label: context.l10n.pausedForConnection,
        );

      case UploadStatus.uploading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.backingUpPercent(
                    (source.uploadProgress * 100).round(),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: source.uploadProgress.clamp(0, 1).toDouble(),
                minHeight: 5,
                backgroundColor: AppColors.surfaceVariant,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        );

      case UploadStatus.failed:
        return Row(
          children: <Widget>[
            const Icon(Icons.error_outline, size: 18, color: AppColors.error),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                source.errorMessage?.isNotEmpty == true
                    ? source.errorMessage!
                    : context.l10n.backupFailed,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: AppColors.error),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: Text(
                  context.l10n.retry,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
          ],
        );
    }
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});

  final SourceType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(_iconFor(type), size: 27, color: AppColors.primary),
    );
  }

  static IconData _iconFor(SourceType type) {
    switch (type) {
      case SourceType.audio:
        return Icons.audiotrack_outlined;
      case SourceType.recording:
        return Icons.mic_none_outlined;
      case SourceType.video:
        return Icons.videocam_outlined;
      case SourceType.image:
        return Icons.image_outlined;
      case SourceType.document:
        return Icons.description_outlined;
    }
  }
}
