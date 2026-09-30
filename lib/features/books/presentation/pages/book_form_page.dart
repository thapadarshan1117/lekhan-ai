import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/utils/id_generator.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/usecases/save_book_usecase.dart';

/// Create or edit a book inside a project.
class BookFormPage extends StatefulWidget {
  const BookFormPage({super.key, required this.projectId, this.initial});

  final String projectId;
  final Book? initial;

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _targetWordsController = TextEditingController();

  BookStatus _status = BookStatus.planning;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final Book? initial = widget.initial;
    if (initial == null) return;

    _titleController.text = initial.title;
    _authorController.text = initial.author;
    _genreController.text = initial.genre;
    _summaryController.text = initial.summary;
    _targetWordsController.text =
        initial.targetWords > 0 ? '${initial.targetWords}' : '';
    _status = initial.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _summaryController.dispose();
    _targetWordsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_saving) return;

    setState(() => _saving = true);

    final DateTime now = DateTime.now();
    final Book? initial = widget.initial;
    final int targetWords = int.tryParse(_targetWordsController.text.trim()) ?? 0;

    final Book book = initial == null
        ? Book(
            id: IdGenerator.bookId(),
            projectId: widget.projectId,
            title: _titleController.text.trim(),
            author: _authorController.text.trim(),
            genre: _genreController.text.trim(),
            summary: _summaryController.text.trim(),
            targetWords: targetWords,
            status: _status,
            createdAt: now,
            updatedAt: now,
          )
        : initial.copyWith(
            title: _titleController.text.trim(),
            author: _authorController.text.trim(),
            genre: _genreController.text.trim(),
            summary: _summaryController.text.trim(),
            targetWords: targetWords,
            status: _status,
            updatedAt: now,
          );

    final result = await sl<SaveBookUsecase>()(book);

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
          _isEditing ? 'Edit book' : 'New book',
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
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Book title',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) =>
                  value == null || value.trim().isEmpty
                      ? 'Give the book a title.'
                      : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _genreController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Genre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Summary',
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
                hintText: 'e.g. 45000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BookStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: BookStatus.values
                  .map(
                    (BookStatus status) => DropdownMenuItem<BookStatus>(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (BookStatus? value) {
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
                  _isEditing ? 'Save changes' : 'Create book',
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
