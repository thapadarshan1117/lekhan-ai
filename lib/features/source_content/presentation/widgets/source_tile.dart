import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/enums/upload_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _TypeIcon(type: source.sourceType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      source.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(source),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Remove',
                ),
            ],
          ),
          const SizedBox(height: 10),
          _UploadStateRow(source: source, onRetry: onRetry),
        ],
      ),
    );
  }

  static String _subtitle(ChapterSource source) {
    final String size = source.readableSize;

    switch (source.sourceType) {
      case SourceType.audio:
      case SourceType.recording:
        return 'Audio · $size${source.duration == null ? '' : ' · ${source.readableDuration}'}';
      case SourceType.video:
        return 'Video · $size';
      case SourceType.image:
        return 'Image · $size';
      case SourceType.document:
        return 'Document · $size';
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
        return const _StatusLine(
          icon: Icons.cloud_done_outlined,
          color: Color(0xFF1B7F4B),
          label: 'Uploaded',
        );

      case UploadStatus.pending:
        return const _StatusLine(
          icon: Icons.cloud_upload_outlined,
          color: AppColors.secondary,
          label: 'Waiting to upload',
        );

      case UploadStatus.preparing:
        return const _StatusLine(
          icon: Icons.hourglass_empty,
          color: AppColors.secondary,
          label: 'Preparing upload',
        );

      case UploadStatus.paused:
        return const _StatusLine(
          icon: Icons.pause_circle_outline,
          color: AppColors.secondary,
          label: 'Paused - waiting for a better connection',
        );

      case UploadStatus.uploading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Uploading ${(source.uploadProgress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
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
            const Icon(Icons.error_outline, size: 15, color: AppColors.error),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                source.errorMessage?.isNotEmpty == true
                    ? source.errorMessage!
                    : 'Upload failed',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Text('Retry', style: TextStyle(fontSize: 12)),
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
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
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
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(_iconFor(type), size: 19, color: AppColors.primary),
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
