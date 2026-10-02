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
import 'package:lekhan_ai/l10n/l10n.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/language/presentation/widgets/language_switcher.dart';
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
                                  const SliverToBoxAdapter(
                                    child: _VoiceFirstGuide(),
                                  ),
                                  SliverToBoxAdapter(
                                    child: _ShelfFilterBar(
                                      shelves: _shelves(projects, books),
                                      selected: _shelf,
                                      onShelf: (String value) => setState(
                                        () => _shelf = value,
                                      ),
                                      onQuery: (String value) => setState(
                                        () => _query = value,
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 18),
                                  ),
                                  if (projects.isEmpty)
                                    SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: ProjectsEmptyState(
                                        offline: isEmptyBecauseOfError,
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
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                            if (index.isOdd) {
                                              return const SizedBox(height: 16);
                                            }
                                            final Project project =
                                                visible[index ~/ 2];
                                            final Book? book = books[project.id];
                                            return Align(
                                              alignment: Alignment.topCenter,
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                  maxWidth: 760,
                                                ),
                                                child: ProjectCard(
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
                                                  onEdit: () =>
                                                      _editProject(project),
                                                  onDelete: () =>
                                                      _deleteProject(project),
                                                ),
                                              ),
                                            );
                                          },
                                          childCount: visible.length * 2 - 1,
                                        ),
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
            title: Text(dialogContext.l10n.deleteBookQuestion),
            content: Text(dialogContext.l10n.deleteBookBody(project.name)),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(dialogContext.l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(dialogContext).colorScheme.error,
                ),
                child: Text(dialogContext.l10n.deleteBook),
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
        SnackBar(
          content: Text(context.l10n.couldNotDeleteBook(failure.message)),
        ),
      ),
      (deleted) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deleted
                ? context.l10n.bookDeleted
                : context.l10n.bookCouldNotBeDeleted,
          ),
        ),
      ),
    );
  }

}

/// A welcoming home screen with one clear way to start a book.
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.onNewProject});

  final Future<void> Function() onNewProject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                context.l10n.yourBooks,
                style: TextStyle(
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                context.l10n.booksIntroduction,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );

          final Widget button = _PrimaryButton(
            icon: Icons.add_rounded,
            label: context.l10n.startNewBook,
            onTap: onNewProject,
          );
          const Widget controls = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              LanguageSwitcher(),
              SyncStatusChip(),
            ],
          );

          if (constraints.maxWidth < 680) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                text,
                const SizedBox(height: 18),
                button,
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: controls,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: text),
              const SizedBox(width: 24),
              SizedBox(
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    button,
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: controls,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Explains the simple voice-first path before users meet any technical terms.
class _VoiceFirstGuide extends StatelessWidget {
  const _VoiceFirstGuide();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          '${context.l10n.voiceComesFirst}. ${context.l10n.voiceGuideDetail}',
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 18, 16, 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF176B45), Color(0xFF0F5132)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const Widget icon = DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x33FFFFFF),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Icon(
                  Icons.mic_rounded,
                  size: 38,
                  color: Colors.white,
                ),
              ),
            );

            final bool isNepali =
                Localizations.localeOf(context).languageCode == 'ne';
            final Widget words = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.voiceComesFirst,
                  style: const TextStyle(
                    fontSize: 23,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.voiceGuideDetail,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.45,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: <Widget>[
                    _GuideStep(
                      number: isNepali ? '१' : '1',
                      label: context.l10n.openBook,
                    ),
                    _GuideStep(
                      number: isNepali ? '२' : '2',
                      label: context.l10n.chooseChapter,
                    ),
                    _GuideStep(
                      number: isNepali ? '३' : '3',
                      label: context.l10n.recordVoice,
                    ),
                  ],
                ),
              ],
            );

            if (constraints.maxWidth < 560) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  icon,
                  const SizedBox(height: 16),
                  words,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                icon,
                const SizedBox(width: 18),
                Expanded(child: words),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shelf chips plus the search box, in one panel.
class _ShelfFilterBar extends StatelessWidget {
  const _ShelfFilterBar({
    required this.shelves,
    required this.selected,
    required this.onShelf,
    required this.onQuery,
  });

  final List<String> shelves;
  final String selected;
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
            label: shelf == _ProjectsViewState._allShelves
                ? context.l10n.allCategories
                : ProjectCategory.localizeCanonicalLabel(context, shelf),
            selected: shelf == selected,
            onTap: () => onShelf(shelf),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.lekhan_aiBorder, width: 1.2),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Widget search = SizedBox(
              width: constraints.maxWidth < 640 ? double.infinity : 300,
              child: TextField(
                onChanged: onQuery,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: context.l10n.searchYourBooks,
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textDisabled,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 25,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: AppColors.lekhan_aiSurfaceMuted,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.lekhan_aiBorder,
                    ),
                  ),
                ),
              ),
            );

            if (constraints.maxWidth < 640) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  search,
                  const SizedBox(height: 14),
                  chips,
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
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
            fontSize: 15,
            fontWeight: FontWeight.w700,
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
      icon: Icon(icon, size: 25, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 58),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.search_off_outlined,
            size: 36,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: 12),
          Text(
                context.l10n.noBooksFound,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            context.l10n.changeBookSearch,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
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
              child: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
