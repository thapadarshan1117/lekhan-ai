import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/core/utils/id_generator.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/usecases/get_book_detail_usecase.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/save_chapter_usecase.dart';

/// Create or edit a chapter. [projectId] is carried along because every chapter
/// record stores the whole ancestor chain (the file path needs it later).
class ChapterFormPage extends StatefulWidget {
  const ChapterFormPage({
    super.key,
    required this.bookId,
    this.projectId,
    this.initial,
    this.suggestedNumber = 1,
  });

  final String bookId;

  /// Optional: resolved from the parent book when the chapter is created from a
  /// deep link instead of from the book screen.
  final String? projectId;
  final Chapter? initial;
  final int suggestedNumber;

  @override
  State<ChapterFormPage> createState() => _ChapterFormPageState();
}

class _ChapterFormPageState extends State<ChapterFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _targetWordsController = TextEditingController();

  late final TextEditingController _numberController;
  ChapterStatus _status = ChapterStatus.notStarted;
  bool _saving = false;
  String? _projectId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveProjectId();
  }

  /// A chapter stores the whole ancestor chain (the file path needs it), so if
  /// the screen was opened by id alone we ask the parent book for the project.
  Future<void> _resolveProjectId() async {
    final String? given = widget.projectId ?? widget.initial?.projectId;

    if (given != null && given.isNotEmpty) {
      _projectId = given;
      return;
    }

    if (_projectId != null) return;

    final result = await sl<GetBookDetailUsecase>()(widget.bookId);
    final Book? book = result.valueOrNull;

    if (!mounted || book == null) return;
    _projectId = book.projectId;
  }

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final Chapter? initial = widget.initial;
    _numberController = TextEditingController(
      text: '${initial?.number ?? widget.suggestedNumber}',
    );

    if (initial == null) return;

    _titleController.text = initial.title;
    _summaryController.text = initial.summary;
    _targetWordsController.text =
        initial.targetWords > 0 ? '${initial.targetWords}' : '';
    _status = initial.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _targetWordsController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_saving) return;

    setState(() => _saving = true);

    if (_projectId == null && widget.projectId == null) {
      await _resolveProjectId();
    }

    if (!mounted) return;

    final String? projectId = _projectId ?? widget.projectId;

    if (projectId == null || projectId.isEmpty) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('The parent book is still loading.')),
        );
      return;
    }

    final DateTime now = DateTime.now();
    final Chapter? initial = widget.initial;
    final int number = int.tryParse(_numberController.text.trim()) ?? 1;
    final int targetWords = int.tryParse(_targetWordsController.text.trim()) ?? 0;

    final Chapter chapter = initial == null
        ? Chapter(
            id: IdGenerator.chapterId(),
            bookId: widget.bookId,
            projectId: projectId,
            number: number,
            title: _titleController.text.trim(),
            summary: _summaryController.text.trim(),
            targetWords: targetWords,
            status: _status,
            createdAt: now,
            updatedAt: now,
          )
        : initial.copyWith(
            number: number,
            title: _titleController.text.trim(),
            summary: _summaryController.text.trim(),
            targetWords: targetWords,
            status: _status,
            updatedAt: now,
          );

    final result = await sl<SaveChapterUsecase>()(chapter);

    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(error.message),
              backgroundColor: AppColors.error,
            ),
          );
      },
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit chapter' : 'New chapter',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 96,
                  child: TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? value) {
                      final int? parsed = int.tryParse(value?.trim() ?? '');
                      if (parsed == null || parsed < 1) {
                        return '1 or more';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Chapter title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'What happens in this chapter?',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetWordsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target words',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ChapterStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ChapterStatus.values
                  .map(
                    (ChapterStatus status) => DropdownMenuItem<ChapterStatus>(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (ChapterStatus? value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Save changes' : 'Create chapter',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
