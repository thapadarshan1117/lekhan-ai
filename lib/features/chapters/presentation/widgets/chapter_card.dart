import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/l10n/l10n.dart';

/// One chapter with voice recording presented as its clearest action.
///
/// The layout avoids dense toolbars and fixed-height rows so it remains usable
/// when the operating system text size is enlarged.
class ChapterCard extends StatelessWidget {
  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onTap,
    this.onEditDraft,
    this.onUpload,
    this.onDelete,
    this.sources = const <ChapterSource>[],
  });

  final Chapter chapter;
  final VoidCallback onTap;
  final VoidCallback? onEditDraft;

  /// Opens the voice-first collection sheet.
  final VoidCallback? onUpload;
  final VoidCallback? onDelete;
  final List<ChapterSource> sources;

  @override
  Widget build(BuildContext context) {
    final bool hasContent =
        chapter.currentWords > 0 || chapter.sourceCount > 0 || sources.isNotEmpty;
    final String title = chapter.title.isEmpty
        ? context.l10n.chapterTitle(chapter.number)
        : chapter.title;

    return Semantics(
      container: true,
      label: context.l10n.chapterSemantics(chapter.number, title),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: hasContent
                ? AppColors.primary.withValues(alpha: 0.42)
                : AppColors.lekhan_aiBorder,
            width: hasContent ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _NumberBadge(number: chapter.number, active: hasContent),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _StatusBadge(chapter: chapter),
                      ],
                    ),
                  ),
                ],
              ),
              if (chapter.summary.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  chapter.summary.trim(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _MetaLine(chapter: chapter, sources: sources),
              const SizedBox(height: 16),
              if (onUpload != null)
                ElevatedButton.icon(
                  key: const ValueKey<String>('record-voice-button'),
                  onPressed: onUpload,
                  icon: const Icon(Icons.mic_rounded, size: 27),
                  label: Text(context.l10n.recordVoice),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                  ),
                ),
              if (onUpload != null) const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.folder_open_outlined, size: 22),
                    label: Text(context.l10n.openChapter),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                  ),
                  if (onEditDraft != null)
                    TextButton.icon(
                      onPressed: onEditDraft,
                      icon: const Icon(Icons.edit_outlined, size: 22),
                      label: Text(context.l10n.edit),
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      tooltip: context.l10n.deleteChapter,
                      style: IconButton.styleFrom(
                        foregroundColor: AppColors.error,
                        backgroundColor: AppColors.errorContainer,
                        minimumSize: const Size(52, 52),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number, required this.active});

  final int number;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: active ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.chapter});

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final _StatusLook look = _lookFor(context, chapter);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: look.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: look.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: look.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              look.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: look.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static _StatusLook _lookFor(BuildContext context, Chapter chapter) {
    final String draft = chapter.draftVersion > 0
        ? ' • ${context.l10n.draftVersion(chapter.draftVersion)}'
        : '';

    switch (chapter.status) {
      case ChapterStatus.notStarted:
        return _StatusLook(
          chapter.sourceCount > 0
              ? '${context.l10n.voiceOrFilesAdded}$draft'
              : context.l10n.readyToBegin,
          chapter.sourceCount > 0 ? AppColors.info : AppColors.textSecondary,
        );
      case ChapterStatus.researching:
        return _StatusLook(
          '${context.l10n.collectingStories}$draft',
          AppColors.info,
        );
      case ChapterStatus.drafting:
        return _StatusLook(
          '${context.l10n.writingInProgress}$draft',
          AppColors.secondary,
        );
      case ChapterStatus.review:
        return _StatusLook(
          '${context.l10n.readyToReview}$draft',
          const Color(0xFF6B4E16),
        );
      case ChapterStatus.completed:
        return _StatusLook(
          '${context.l10n.completed}$draft',
          AppColors.success,
        );
    }
  }
}

class _StatusLook {
  const _StatusLook(this.label, this.color);

  final String label;
  final Color color;
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.chapter, required this.sources});

  final Chapter chapter;
  final List<ChapterSource> sources;

  @override
  Widget build(BuildContext context) {
    final int knownAudioCount = sources
        .where(
          (ChapterSource source) =>
              source.sourceType == SourceType.audio ||
              source.sourceType == SourceType.video ||
              source.sourceType == SourceType.recording,
        )
        .length;
    final int sourceCount = sources.isNotEmpty
        ? sources.length
        : chapter.sourceCount;

    return Wrap(
      spacing: 14,
      runSpacing: 10,
      children: <Widget>[
        if (sourceCount > 0)
          _MetaBit(
            icon: knownAudioCount > 0 ? Icons.mic_outlined : Icons.attach_file,
            text: knownAudioCount > 0
                ? context.l10n.voiceRecordingCount(knownAudioCount)
                : context.l10n.savedItemCount(sourceCount),
          )
        else
          _MetaBit(
            icon: Icons.mic_none_rounded,
            text: context.l10n.noVoiceRecording,
          ),
        if (chapter.currentWords > 0)
          _MetaBit(
            icon: Icons.description_outlined,
            text: context.l10n.wordsWritten(_grouped(chapter.currentWords)),
          ),
        if (chapter.pendingSourceCount > 0)
          _MetaBit(
            icon: Icons.cloud_upload_outlined,
            text: context.l10n.waitingBackupCount(
              chapter.pendingSourceCount,
            ),
            color: AppColors.warning,
          ),
        if (chapter.targetWords > 0)
          _MetaBit(
            icon: Icons.flag_outlined,
            text: context.l10n.goalWords(_grouped(chapter.targetWords)),
          ),
      ],
    );
  }

  static String _grouped(int value) {
    final String digits = value.abs().toString();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return value < 0 ? '-$out' : out.toString();
  }
}

class _MetaBit extends StatelessWidget {
  const _MetaBit({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color tint = color ?? AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 19, color: tint),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tint,
            ),
          ),
        ),
      ],
    );
  }
}
