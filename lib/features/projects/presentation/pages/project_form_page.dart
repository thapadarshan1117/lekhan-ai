import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/enums/entity_status.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/utils/id_generator.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/save_project_usecase.dart';

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
          _isEditing ? 'Edit project' : 'New project',
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
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Project name',
                hintText: 'e.g. Memoir of Ramesh Thapa',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Give the project a name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What is this book about?',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: _types
                  .map(
                    (String type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(_capitalise(type)),
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
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ProjectStatus.values
                  .map(
                    (ProjectStatus status) => DropdownMenuItem<ProjectStatus>(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (ProjectStatus? value) {
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
                  _isEditing ? 'Save changes' : 'Create project',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Saved on this device first. It uploads automatically once a '
              'connection is available.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalise(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
