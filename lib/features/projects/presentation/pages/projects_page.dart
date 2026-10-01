import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/utils/either_utils.dart';
import 'package:lekhan_ai/features/books/domain/entities/book.dart';
import 'package:lekhan_ai/features/books/domain/usecases/get_books_usecase.dart';
import 'package:lekhan_ai/features/projects/domain/entities/project.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:lekhan_ai/features/projects/presentation/bloc/projects_bloc/projects_bloc.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_card.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/project_category.dart';
import 'package:lekhan_ai/features/projects/presentation/widgets/projects_empty_state.dart';
import 'package:lekhan_ai/features/sync/presentation/widgets/sync_status_chip.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

/// The projects list - the root of the writing structure
/// (project → chapters → sources: a project is the book the writer works in).
///
/// Laid out as a shelf: every manuscript is a card carrying its cover, shelf
/// category, author, and word progress, with the category chips and the search
/// box narrowing the shelf down. The author and word figures live on the
/// project's own book, so the page reads that row alongside the projects.
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectsBloc>(
      create: (BuildContext context) =>
          sl<ProjectsBloc>()..add(const ProjectsEvent.started()),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatefulWidget {
  const _ProjectsView();

  @override
  State<_ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<_ProjectsView> {
  static const String _allShelves = 'All';

  String _shelf = _allShelves;
  String _query = '';

  /// One read of every book on the device, keyed by project. The card needs the
  /// author, genre and word counts that live on the book rather than the project.
  late Future<Either<AppException, List<Book>>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = sl<GetBooksUsecase>()(const GetBooksParams());
  }

  void _reloadBooks() {
    setState(() {
      _booksFuture = sl<GetBooksUsecase>()(const GetBooksParams());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<ProjectsBloc, ProjectsState>(
          listener: (BuildContext context, ProjectsState state) {
            state.maybeWhen(
              loaded:
                  (
                    List<Project> projects,
                    bool isRefreshing,
                    String? message,
                    bool isEmptyBecauseOfError,
                  ) {
                    if (message != null && !isEmptyBecauseOfError) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: AppColors.textPrimary,
                          ),
                        );
                    }
                  },
              orElse: () {},
            );
          },
          builder: (BuildContext context, ProjectsState state) {
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (String message) => _ErrorView(message: message),
              loaded:
                  (
                    List<Project> projects,
                    bool isRefreshing,
                    String? message,
                    bool isEmptyBecauseOfError,
                  ) {
                    return FutureBuilder<Either<AppException, List<Book>>>(
                      future: _booksFuture,
                      builder:
                          (
                            BuildContext context,
                            AsyncSnapshot<Either<AppException, List<Book>>>
                            snapshot,
                          ) {
                            final Map<String, Book> books =
                                <String, Book>{
                                  for (final Book book
                                      in snapshot.data?.valueOrNull ??
                                      const <Book>[])
                                    book.projectId: book,
                                };

                            final List<Project> visible = _visible(
                              projects,
                              books,
                            );

                            return RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: () async {
                                context.read<ProjectsBloc>().add(
                                  const ProjectsEvent.refreshed(),
                                );
                                _reloadBooks();
                              },
                              child: CustomScrollView(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                slivers: <Widget>[
                                  SliverToBoxAdapter(
                                    child: _PageHeader(
                                      onNewProject: _newProject,
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: _ShelfFilterBar(
                                      shelves: _shelves(projects, books),
                                      selected: _shelf,
                                      query: _query,
                                      onShelf: (String value) => setState(
                                        () => _shelf = value,
                                      ),
                                      onQuery: (String value) => setState(
                                        () => _query = value,
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 16),
                                  ),
                                  if (projects.isEmpty)
                                    SliverToBoxAdapter(
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(
                                              context,
                                            ).size.height *
                                            0.6,
                                        child: ProjectsEmptyState(
                                          offline: isEmptyBecauseOfError,
                                        ),
                                      ),
                                    )
                                  else if (visible.isEmpty)
                                    const SliverToBoxAdapter(
                                      child: _NoMatches(),
                                    )
                                  else
                                    SliverPadding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        96,
                                      ),
                                      sliver: SliverGrid(
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: 460,
                                              mainAxisSpacing: 16,
                                              crossAxisSpacing: 16,
                                              mainAxisExtent: 288,
                                            ),
                                        itemCount: visible.length,
                                        itemBuilder:
                                            (
                                              BuildContext context,
                                              int index,
                                            ) {
                                              final Project project =
                                                  visible[index];
                                              final Book? book =
                                                  books[project.id];
                                              return ProjectCard(
                                                project: project,
                                                book: book,
                                                onTap: () =>
                                                    context.pushNamed(
                                                      'projectDetail',
                                                      pathParameters:
                                                          <String, String>{
                                                            'id': project.id,
                                                          },
                                                      extra: project,
                                                    ),
                                                onEdit: () => _editProject(
                                                  project,
                                                ),
                                                onDelete: () =>
                                                    _deleteProject(project),
                                                onAiStudio: () => _soon(
                                                  'AI Studio',
                                                ),
                                                onProof: () =>
                                                    _soon('Proof desk'),
                                              );
                                            },
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                    );
                  },
            );
          },
        ),
      ),
    );
  }

  /// Shelf label for a project: the book's genre when it has one, otherwise the
  /// project's own type.
  String _shelfOf(Project project, Book? book) {
    final String? genre = book?.genre.trim();
    return ProjectCategory.label(
      (genre != null && genre.isNotEmpty) ? genre : project.type,
    );
  }

  List<String> _shelves(List<Project> projects, Map<String, Book> books) {
    final Set<String> labels = <String>{
      for (final Project project in projects)
        _shelfOf(project, books[project.id]),
    };
    final List<String> sorted = labels.toList()..sort();
    return <String>[_allShelves, ...sorted];
  }

  List<Project> _visible(List<Project> projects, Map<String, Book> books) {
    final String needle = _query.trim().toLowerCase();

    return projects.where((Project project) {
      final Book? book = books[project.id];

      if (_shelf != _allShelves && _shelfOf(project, book) != _shelf) {
        return false;
      }
      if (needle.isEmpty) return true;

      final String haystack = <String>[
        project.name,
        project.description,
        project.type,
        book?.title ?? '',
        book?.author ?? '',
        book?.genre ?? '',
        book?.summary ?? '',
      ].join(' ').toLowerCase();

      return haystack.contains(needle);
    }).toList();
  }

  Future<void> _newProject() async {
    final Object? saved = await context.pushNamed('projectForm');
    if (saved == true && mounted) {
      context.read<ProjectsBloc>().add(const ProjectsEvent.refreshed());
      _reloadBooks();
    }
  }

  Future<void> _editProject(Project project) async {
    final Object? saved = await context.pushNamed(
      'projectForm',
      extra: project,
    );
    if (saved == true && mounted) {
      context.read<ProjectsBloc>().add(const ProjectsEvent.refreshed());
      _reloadBooks();
    }
  }

  Future<void> _deleteProject(Project project) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Delete project?'),
            content: Text(
              '“${project.name}” and all of its chapters and source files '
              'will be removed from this device. The server deletion will sync '
              'when available.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(dialogContext).colorScheme.error,
                ),
                child: const Text('Delete project'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    final result = await sl<DeleteProjectUsecase>()(project.id);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete project: ${failure.message}')),
      ),
      (deleted) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deleted ? 'Project deleted.' : 'Project could not be deleted.',
          ),
        ),
      ),
    );
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$what is not wired up in this build yet.')),
      );
  }
}

/// Title, blurb and the shelf's primary action.
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onNewProject});

  final Future<void> Function() onNewProject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Text(
                'Book & Ghostwriting Projects',
                style: TextStyle(
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Track active biographies, corporate histories, and memoirs '
                'across oral transcription, ghostwriting, and print press.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );

          final Widget button = _PrimaryButton(
            icon: Icons.add,
            label: 'New Book Project',
            onTap: onNewProject,
          );

          if (constraints.maxWidth < 620) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                text,
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    const SyncStatusChip(),
                    const Spacer(),
                    button,
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: text),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const SyncStatusChip(),
                  const SizedBox(height: 12),
                  button,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Shelf chips plus the search box, in one panel.
class _ShelfFilterBar extends StatelessWidget {
  const _ShelfFilterBar({
    required this.shelves,
    required this.selected,
    required this.query,
    required this.onShelf,
    required this.onQuery,
  });

  final List<String> shelves;
  final String selected;
  final String query;
  final ValueChanged<String> onShelf;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    final Widget chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final String shelf in shelves)
          _ShelfChip(
            label: shelf,
            selected: shelf == selected,
            onTap: () => onShelf(shelf),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lekhan_aiBorder),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Widget search = SizedBox(
              height: 38,
              width: constraints.maxWidth < 640 ? double.infinity : 260,
              child: TextField(
                onChanged: onQuery,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search book title or author...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDisabled,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.lekhan_aiSurfaceMuted,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            );

            if (constraints.maxWidth < 640) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  chips,
                  const SizedBox(height: 10),
                  search,
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(child: chips),
                const SizedBox(width: 12),
                search,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ShelfChip extends StatelessWidget {
  const _ShelfChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.success
              : AppColors.lekhan_aiSurfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.success : AppColors.lekhan_aiBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 56, horizontal: 32),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.search_off_outlined,
            size: 36,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: 12),
          Text(
            'Nothing on this shelf',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try another category, or clear the search.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context
                  .read<ProjectsBloc>()
                  .add(const ProjectsEvent.started()),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
