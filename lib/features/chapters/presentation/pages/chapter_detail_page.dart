import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/enums/source_type.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/get_chapter_detail_usecase.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/update_chapter_progress_usecase.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/add_existing_file_usecase.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/add_source_usecase.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/delete_source_usecase.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/get_chapter_sources_usecase.dart';
import 'package:lekhan_ai/features/source_content/presentation/bloc/sources_bloc/sources_bloc.dart';
import 'package:lekhan_ai/features/source_content/presentation/widgets/add_source_sheet.dart';
import 'package:lekhan_ai/features/source_content/presentation/widgets/source_tile.dart';
import 'package:lekhan_ai/features/sync/presentation/widgets/sync_status_chip.dart';
import 'package:lekhan_ai/l10n/l10n.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart' hide State;

/// A chapter: its source material, its word count, and the way in.
class ChapterDetailPage extends StatefulWidget {
  const ChapterDetailPage({super.key, required this.chapterId, this.initial});

  final String chapterId;
  final Chapter? initial;

  @override
  State<ChapterDetailPage> createState() => _ChapterDetailPageState();
}

class _ChapterDetailPageState extends State<ChapterDetailPage> {
  Chapter? _chapter;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _chapter = widget.initial;
    if (_chapter == null) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final Either<AppException, Chapter> result =
        await sl<GetChapterDetailUsecase>()(widget.chapterId);

    if (!mounted) return;
    setState(() {
      _chapter = result.valueOrNull;
      _loading = false;
    });
  }

  Future<void> _editProgress() async {
    final Chapter? chapter = _chapter;
    if (chapter == null) return;

    final TextEditingController controller =
        TextEditingController(text: '${chapter.currentWords}');

    final bool? save = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.wordCount),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
            decoration: InputDecoration(
              labelText: dialogContext.l10n.wordsWrittenSoFar,
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.save),
          ),
        ],
      ),
    );

    if (save != true) return;

    final int words = int.tryParse(controller.text.trim()) ?? chapter.currentWords;
    final ChapterStatus status = _statusFor(chapter, words);

    final Either<AppException, Chapter> result =
        await sl<UpdateChapterProgressUsecase>()(
      UpdateChapterProgressParams(
        chapterId: chapter.id,
        currentWords: words,
        status: status,
      ),
    );

    if (!mounted) return;

    result.fold(
      (AppException error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(error.message),
              backgroundColor: AppColors.error,
            ),
          );
      },
      (Chapter updated) => setState(() => _chapter = updated),
    );
  }

  /// Keeps the status honest without asking the writer to manage it.
  ChapterStatus _statusFor(Chapter chapter, int words) {
    if (words > 0 && chapter.status == ChapterStatus.notStarted) {
      return ChapterStatus.drafting;
    }
    return chapter.status;
  }

  @override
  Widget build(BuildContext context) {
    final Chapter? chapter = _chapter;

    if (chapter == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator(color: AppColors.primary)
              : Text(
                  context.l10n.chapterNotFound,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
        ),
      );
    }

    return BlocProvider<SourcesBloc>(
      create: (BuildContext context) => SourcesBloc(
        chapter: chapter,
        watchSources: sl<WatchChapterSourcesUsecase>(),
        getSources: sl<GetChapterSourcesUsecase>(),
        addSource: sl<AddSourceUsecase>(),
        addExistingFile: sl<AddExistingFileUsecase>(),
        deleteSource: sl<DeleteSourceUsecase>(),
        retryUpload: sl<RetryUploadUsecase>(),
      )..add(const SourcesEvent.started()),
      child: _ChapterView(
        chapter: chapter,
        onEditProgress: _editProgress,
      ),
    );
  }
}

class _ChapterView extends StatelessWidget {
  const _ChapterView({required this.chapter, required this.onEditProgress});

  final Chapter chapter;
  final VoidCallback onEditProgress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          context.l10n.yourChapter,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: SyncStatusChip(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Semantics(
        button: true,
        label: context.l10n.recordVoiceChapterSemantics,
        child: FloatingActionButton.extended(
          onPressed: () => AddSourceSheet.show(context, chapter),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.mic_rounded, size: 28),
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(context.l10n.recordVoiceTitle),
          ),
        ),
      ),
      body: BlocConsumer<SourcesBloc, SourcesState>(
        listener: (BuildContext context, SourcesState state) {
          state.maybeWhen(
            loaded: (List<ChapterSource> sources, bool isBusy, String? message) {
              if (message != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(_localizedSourceMessage(context, message)),
                    ),
                  );
              }
            },
            orElse: () {},
          );
        },
        builder: (BuildContext context, SourcesState state) {
          return NestedScrollView(
            headerSliverBuilder: (_, __) => <Widget>[
              SliverToBoxAdapter(
                child: _ChapterHeader(
                  chapter: chapter,
                  onEditProgress: onEditProgress,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    context.l10n.yourRecordingsAndFiles,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
            body: state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (String message) => Center(
                child: Text(
                  _localizedSourceMessage(context, message),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              loaded: (
                List<ChapterSource> sources,
                bool isBusy,
                String? message,
              ) {
                if (sources.isEmpty) return const _NoSourcesYet();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 128),
                  itemCount: sources.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final ChapterSource source = sources[index];

                    return Dismissible(
                      key: ValueKey<String>(source.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (_) => _confirmDelete(context, source),
                      onDismissed: (_) => context
                          .read<SourcesBloc>()
                          .add(SourcesEvent.deleted(source.id)),
                      child: SourceTile(
                        source: source,
                        onDelete: () async {
                          if (await _confirmDelete(context, source) == true &&
                              context.mounted) {
                            context
                                .read<SourcesBloc>()
                                .add(SourcesEvent.deleted(source.id));
                          }
                        },
                        onRetry: source.hasFailed
                            ? () => context
                                .read<SourcesBloc>()
                                .add(SourcesEvent.uploadRetried(source.id))
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  static String _localizedSourceMessage(
    BuildContext context,
    String message,
  ) {
    switch (message) {
      case 'Sources could not be read from this device.':
        return context.l10n.sourcesReadError;
      case 'Saved on this device. It will be backed up automatically.':
        return context.l10n.savedAndBackedUpLater;
      case 'Recording saved on this device.':
        return context.l10n.recordingSavedOnDevice;
      case 'Source removed.':
        return context.l10n.sourceRemoved;
      case 'We will try the backup again.':
        return context.l10n.backupWillRetry;
      default:
        return message;
    }
  }

  static Future<bool> _confirmDelete(
    BuildContext context,
    ChapterSource source,
  ) async {
    final bool isVoice = source.sourceType == SourceType.audio ||
        source.sourceType == SourceType.recording;
    final String displayName = isVoice
        ? '${context.l10n.voiceRecording} · '
            '${MaterialLocalizations.of(context).formatShortDate(source.createdAt)}'
        : source.name;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.removeSourceQuestion),
        content: Text(
          dialogContext.l10n.removeSourceBody(displayName) +
              (source.isUploaded
                  ? dialogContext.l10n.onlineCopyAlsoRemoved
                  : ''),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.l10n.keep),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(dialogContext.l10n.remove),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }
}

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({required this.chapter, required this.onEditProgress});

  final Chapter chapter;
  final VoidCallback onEditProgress;

  @override
  Widget build(BuildContext context) {
    final double progress = chapter.targetWords <= 0
        ? 0
        : (chapter.currentWords / chapter.targetWords).clamp(0, 1).toDouble();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${chapter.number}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  chapter.title.isEmpty
                      ? context.l10n.chapterTitle(chapter.number)
                      : chapter.title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (chapter.summary.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              chapter.summary,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                chapter.targetWords > 0
                    ? context.l10n.chapterWordsProgress(
                        chapter.currentWords,
                        chapter.targetWords,
                      )
                    : context.l10n.wordsCount(
                        chapter.currentWords.toString(),
                      ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: onEditProgress,
                icon: const Icon(Icons.edit_outlined, size: 21),
                label: Text(context.l10n.updateProgress),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoSourcesYet extends StatelessWidget {
  const _NoSourcesYet();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 140),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 104,
                height: 104,
                child: Icon(
                  Icons.mic_rounded,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 22),
            Text(
              context.l10n.noRecordingsYet,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              context.l10n.noRecordingsHelp,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
