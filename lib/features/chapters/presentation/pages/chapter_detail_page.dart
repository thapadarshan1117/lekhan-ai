import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
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
        title: const Text('Word count'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Words written so far',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
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
              : const Text(
                  'This chapter could not be found on this device.',
                  style: TextStyle(color: AppColors.textSecondary),
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
        title: const Text(
          'Chapter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddSourceSheet.show(context, chapter),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add source'),
      ),
      body: BlocConsumer<SourcesBloc, SourcesState>(
        listener: (BuildContext context, SourcesState state) {
          state.maybeWhen(
            loaded: (List<ChapterSource> sources, bool isBusy, String? message) {
              if (message != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
              }
            },
            orElse: () {},
          );
        },
        builder: (BuildContext context, SourcesState state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ChapterHeader(chapter: chapter, onEditProgress: onEditProgress),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'Source material',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: state.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (String message) => Center(
                    child: Text(
                      message,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  loaded: (List<ChapterSource> sources, bool isBusy,
                      String? message) {
                    if (sources.isEmpty) return const _NoSourcesYet();

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
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
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<bool> _confirmDelete(
    BuildContext context,
    ChapterSource source,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Remove this source?'),
        content: Text(
          '“${source.name}” will be deleted from this device.'
          '${source.isUploaded ? ' The copy on the server stays.' : ''}',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
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
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${chapter.number}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  chapter.title.isEmpty ? 'Chapter ${chapter.number}' : chapter.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
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
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                chapter.targetWords > 0
                    ? '${chapter.currentWords} of ${chapter.targetWords} words'
                    : '${chapter.currentWords} words',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEditProgress,
                icon: const Icon(Icons.edit_outlined, size: 15),
                label: const Text(
                  'Update',
                  style: TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.folder_open_outlined,
              size: 44,
              color: AppColors.textDisabled,
            ),
            SizedBox(height: 14),
            Text(
              'No source material yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Record the author talking, or add documents, photos and videos. '
              'Everything is saved here first, even without a connection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
