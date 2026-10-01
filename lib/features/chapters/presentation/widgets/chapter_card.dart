import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';

/// One chapter in the list, with the three desks a chapter needs: read the
/// material, edit the draft, or hand it more source files.
///
/// Chapters that already carry words or sources are tinted, so the eye finds
/// the empty ones - the ones still waiting on an upload - first.
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

  /// Opens the chapter's repository (its sources).
  final VoidCallback onTap;
  final VoidCallback? onEditDraft;
  final VoidCallback? onUpload;

  /// Destructive, so it stays behind an icon rather than a labelled button.
  final VoidCallback? onDelete;

  /// Sources already on this device, when the caller has them: used for the
  /// audio count in the meta line. Omitted by the project list, which only
  /// knows the chapter.
  final List<ChapterSource> sources;

  @override
  Widget build(BuildContext context) {
    final bool hasContent =
        chapter.currentWords > 0 || chapter.sourceCount > 0;

    return Material(
      color: hasContent
          ? AppColors.primary.withValues(alpha: 0.03)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: hasContent
              ? AppColors.primary.withValues(alpha: 0.30)
              : AppColors.lekhan_aiBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _NumberBadge(number: chapter.number, active: hasContent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Text(
                            chapter.title.isEmpty
                                ? 'Chapter ${chapter.number}'
                                : chapter.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _StatusBadge(chapter: chapter),
                      ],
                    ),
                    const SizedBox(height: 5),
                    _MetaLine(chapter: chapter, sources: sources),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _RowActions(
                onUpload: onUpload,
                onRepository: onTap,
                onEditDraft: onEditDraft,
                onDelete: onDelete,
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
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
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
    final _StatusLook look = _lookFor(chapter);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: look.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: look.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            look.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: look.color,
            ),
          ),
        ],
      ),
    );
  }

  static _StatusLook _lookFor(Chapter chapter) {
    final String draft =
        chapter.draftVersion > 0 ? ' • Draft v1.${chapter.draftVersion}' : '';

    switch (chapter.status) {
      case ChapterStatus.notStarted:
        return _StatusLook(
          chapter.sourceCount > 0 ? 'Content available$draft' : 'No content yet',
          chapter.sourceCount > 0 ? AppColors.info : AppColors.textDisabled,
        );
      case ChapterStatus.researching:
        return _StatusLook('Collecting sources$draft', AppColors.info);
      case ChapterStatus.drafting:
        return _StatusLook('Drafting$draft', AppColors.secondary);
      case ChapterStatus.review:
        return _StatusLook('In review$draft', const Color(0xFF6D28D9));
      case ChapterStatus.completed:
        return _StatusLook('Completed$draft', AppColors.success);
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
    final int audioCount = sources
        .where(
          (ChapterSource source) =>
              source.sourceType == SourceType.audio ||
              source.sourceType == SourceType.video ||
              source.sourceType == SourceType.recording,
        )
        .length;

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: <Widget>[
        _MetaBit(
          icon: Icons.description_outlined,
          text: '${_grouped(chapter.currentWords)} words',
        ),
        if (sources.isNotEmpty) ...<Widget>[
          _MetaBit(
            icon: Icons.graphic_eq,
            text: audioCount > 0
                ? '$audioCount audio file${audioCount == 1 ? '' : 's'}'
                : '${chapter.sourceCount} source files',
          ),
        ] else if (chapter.sourceCount > 0) ...<Widget>[
          _MetaBit(
            icon: Icons.attach_file,
            text: '${chapter.sourceCount} source files',
          ),
        ],
        if (chapter.pendingSourceCount > 0)
          _MetaBit(
            icon: Icons.cloud_upload_outlined,
            text: '${chapter.pendingSourceCount} waiting to upload',
            color: AppColors.warning,
          ),
        if (chapter.targetWords > 0)
          _MetaBit(
            icon: Icons.flag_outlined,
            text: 'Target: ${_grouped(chapter.targetWords)} words',
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
        Icon(icon, size: 13, color: tint),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: tint),
        ),
      ],
    );
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.onUpload,
    required this.onRepository,
    required this.onEditDraft,
    this.onDelete,
  });

  final VoidCallback? onUpload;
  final VoidCallback onRepository;
  final VoidCallback? onEditDraft;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: <Widget>[
        if (onEditDraft != null)
          _RowButton(
            icon: Icons.edit_note_outlined,
            label: 'Edit Draft',
            onTap: onEditDraft,
          ),
        _RowButton(
          icon: Icons.folder_outlined,
          label: 'Repository',
          onTap: onRepository,
        ),
        if (onUpload != null)
          _RowButton(
            icon: Icons.cloud_upload_outlined,
            label: 'Upload File',
            filled: true,
            onTap: onUpload,
          ),
        if (onDelete != null)
          _DeleteButton(onTap: onDelete),
      ],
    );
  }
}

/// The reference rows have no delete affordance, but the chapter has to stay
/// removable - so it stays behind an icon that only shows when wired up.
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      width: 34,
      child: IconButton(
        onPressed: onTap,
        tooltip: 'Delete chapter',
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        icon: const Icon(
          Icons.delete_outline,
          size: 16,
          color: AppColors.error,
        ),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.lekhan_aiSurfaceMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: const BorderSide(color: AppColors.lekhan_aiBorder),
          ),
        ),
      ),
    );
  }
}

class _RowButton extends StatelessWidget {
  const _RowButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color foreground = filled ? Colors.white : AppColors.textSecondary;

    return SizedBox(
      height: 34,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14, color: foreground),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: filled
              ? AppColors.primary
              : AppColors.lekhan_aiSurfaceMuted,
          foregroundColor: foreground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: filled
                ? BorderSide.none
                : const BorderSide(color: AppColors.lekhan_aiBorder),
          ),
        ),
      ),
    );
  }
}
