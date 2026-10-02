import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/utils/id_generator.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/save_project_usecase.dart';
import 'package:lekhan_ai/l10n/l10n.dart';

/// Create or edit a project.
///
/// Saving never waits for the network: the record goes into the local store and
/// onto the sync queue, so the form can close immediately. That is why there is
/// no "saving…" spinner that can fail - there is nothing to wait for.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key, this.initial});

  final Project? initial;

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late ProjectStatus _status;
  bool _saving = false;

  static const List<String> _types = <String>[
    'biography',
    'memoir',
    'self-help',
    'fiction',
    'business',
    'academic',
  ];

  late String _type;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final Project? initial = widget.initial;
    _nameController.text = initial?.name ?? '';
    _descriptionController.text = initial?.description ?? '';
    _status = initial?.status ?? ProjectStatus.draft;
    _type = initial?.type ?? 'biography';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_saving) return;

    setState(() => _saving = true);

    final DateTime now = DateTime.now();
    final Project? initial = widget.initial;

    final Project project = initial == null
        ? Project(
            id: IdGenerator.projectId(),
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _type,
            status: _status,
            createdAt: now,
            updatedAt: now,
          )
        : initial.copyWith(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            type: _type,
            status: _status,
            updatedAt: now,
          );

    final result = await sl<SaveProjectUsecase>()(project);

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
      (_) {
        // `true` tells the list to re-read the local store.
        Navigator.of(context).pop(true);
      },
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
          _isEditing ? context.l10n.editBookPage : context.l10n.startNewBook,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Text(
              context.l10n.bookFormIntro,
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.bookTitle,
                hintText: context.l10n.bookTitleHint,
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.bookTitleRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.bookAbout,
                hintText: context.l10n.bookAboutHint,
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                labelText: context.l10n.bookKind,
                border: OutlineInputBorder(),
              ),
              items: _types
                  .map(
                    (String type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(_bookTypeLabel(context, type)),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProjectStatus>(
              value: _status,
              decoration: InputDecoration(
                labelText: context.l10n.writingProgress,
                border: OutlineInputBorder(),
              ),
              items: ProjectStatus.values
                  .map(
                    (ProjectStatus status) => DropdownMenuItem<ProjectStatus>(
                      value: status,
                      child: Text(_statusLabel(context, status)),
                    ),
                  )
                  .toList(),
              onChanged: (ProjectStatus? value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.menu_book_rounded, size: 24),
              label: Text(
                _isEditing
                    ? context.l10n.saveChanges
                    : context.l10n.createMyBook,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.bookBackupHelp,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _bookTypeLabel(BuildContext context, String value) {
    switch (value) {
      case 'biography':
        return context.l10n.bookTypeBiography;
      case 'memoir':
        return context.l10n.bookTypeMemoir;
      case 'self-help':
        return context.l10n.bookTypeSelfHelp;
      case 'fiction':
        return context.l10n.bookTypeFiction;
      case 'business':
        return context.l10n.bookTypeBusiness;
      case 'academic':
        return context.l10n.bookTypeAcademic;
      default:
        return value;
    }
  }

  static String _statusLabel(BuildContext context, ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return context.l10n.projectStatusDraft;
      case ProjectStatus.assigned:
        return context.l10n.projectStatusAssigned;
      case ProjectStatus.inProgress:
        return context.l10n.projectStatusInProgress;
      case ProjectStatus.onHold:
        return context.l10n.projectStatusOnHold;
      case ProjectStatus.completed:
        return context.l10n.projectStatusCompleted;
      case ProjectStatus.archived:
        return context.l10n.projectStatusArchived;
    }
  }
}
