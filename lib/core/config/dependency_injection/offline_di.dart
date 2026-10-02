import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/config/backend_mode.dart';
import 'package:lekhan_ai/core/mock/mock_lekhan_backend.dart';
import 'package:lekhan_ai/core/database/app_database.dart';
import 'package:lekhan_ai/core/network/network_info.dart';
import 'package:lekhan_ai/core/permissions/permission_service.dart';
import 'package:lekhan_ai/core/storage/local_file_storage.dart';
import 'package:lekhan_ai/core/storage/storage_manager.dart';
import 'package:lekhan_ai/core/sync/background_sync_scheduler.dart';
import 'package:lekhan_ai/core/sync/sync_manager.dart';
import 'package:lekhan_ai/core/sync/offline_session_guard.dart';
import 'package:lekhan_ai/core/sync/conflict_resolver.dart';
import 'package:lekhan_ai/core/sync/sync_queue.dart';
import 'package:lekhan_ai/core/sync/sync_request_bus.dart';
import 'package:lekhan_ai/core/sync/sync_state.dart';
import 'package:lekhan_ai/core/sync/sync_worker.dart';
import 'package:lekhan_ai/core/sync/sync_bootstrap.dart';
import 'package:lekhan_ai/features/books/data/datasources/local/book_local_datasource.dart';
import 'package:lekhan_ai/features/books/data/datasources/remote/book_remote_datasource.dart';
import 'package:lekhan_ai/features/books/data/datasources/remote/mock_book_remote_datasource.dart';
import 'package:lekhan_ai/features/books/data/repositories/book_repository_impl.dart';
import 'package:lekhan_ai/features/books/domain/repositories/book_repository.dart';
import 'package:lekhan_ai/features/books/domain/usecases/get_book_detail_usecase.dart';
import 'package:lekhan_ai/features/books/domain/usecases/get_books_usecase.dart';
import 'package:lekhan_ai/features/books/domain/usecases/delete_book_usecase.dart';
import 'package:lekhan_ai/features/books/domain/usecases/save_book_usecase.dart';
import 'package:lekhan_ai/features/books/presentation/bloc/books_bloc/books_bloc.dart';
import 'package:lekhan_ai/features/chapters/data/datasources/local/chapter_local_datasource.dart';
import 'package:lekhan_ai/features/chapters/data/datasources/remote/chapter_remote_datasource.dart';
import 'package:lekhan_ai/features/chapters/data/datasources/remote/mock_chapter_remote_datasource.dart';
import 'package:lekhan_ai/features/chapters/data/repositories/chapter_repository_impl.dart';
import 'package:lekhan_ai/features/chapters/domain/repositories/chapter_repository.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/get_chapter_detail_usecase.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/get_chapters_usecase.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/delete_chapter_usecase.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/save_chapter_usecase.dart';
import 'package:lekhan_ai/features/chapters/domain/usecases/update_chapter_progress_usecase.dart';
import 'package:lekhan_ai/features/chapters/presentation/bloc/chapters_bloc/chapters_bloc.dart';
import 'package:lekhan_ai/features/projects/data/datasources/local/project_local_datasource.dart';
import 'package:lekhan_ai/features/projects/data/datasources/remote/project_remote_datasource.dart';
import 'package:lekhan_ai/features/projects/data/datasources/remote/mock_project_remote_datasource.dart';
import 'package:lekhan_ai/features/projects/data/repositories/project_repository_impl.dart';
import 'package:lekhan_ai/features/projects/domain/repositories/project_repository.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/get_project_detail_usecase.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:lekhan_ai/features/projects/domain/usecases/save_project_usecase.dart';
import 'package:lekhan_ai/features/projects/presentation/bloc/projects_bloc/projects_bloc.dart';
import 'package:lekhan_ai/features/source_content/data/datasources/local/chapter_source_local_datasource.dart';
import 'package:lekhan_ai/features/source_content/data/datasources/remote/chapter_source_remote_datasource.dart';
import 'package:lekhan_ai/features/source_content/data/datasources/remote/mock_chapter_source_remote_datasource.dart';
import 'package:lekhan_ai/features/source_content/data/repositories/chapter_source_repository_impl.dart';
import 'package:lekhan_ai/features/source_content/domain/repositories/chapter_source_repository.dart';
import 'package:lekhan_ai/features/source_content/data/services/recording_service.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/add_existing_file_usecase.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/add_source_usecase.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/delete_source_usecase.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/get_chapter_sources_usecase.dart';
import 'package:lekhan_ai/features/sync/data/datasources/sync_remote_datasource.dart';
import 'package:lekhan_ai/features/sync/data/datasources/mock_sync_remote_datasource.dart';
import 'package:lekhan_ai/features/sync/data/handlers/metadata_push_handler.dart';
import 'package:lekhan_ai/features/sync/data/handlers/source_upload_handler.dart';
import 'package:lekhan_ai/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:lekhan_ai/features/sync/data/services/sync_entity_applier.dart';
import 'package:lekhan_ai/features/sync/data/services/sync_reference_resolver.dart';
import 'package:lekhan_ai/features/sync/data/services/sync_pull_applier.dart';
import 'package:lekhan_ai/features/sync/data/services/sync_pull_service.dart';
import 'package:lekhan_ai/features/sync/domain/repositories/sync_repository.dart';
import 'package:lekhan_ai/features/sync/domain/usecases/get_sync_status_usecase.dart';
import 'package:lekhan_ai/features/sync/domain/usecases/retry_sync_usecase.dart';
import 'package:lekhan_ai/features/sync/domain/usecases/sync_now_usecase.dart';
import 'package:lekhan_ai/features/sync/presentation/bloc/sync_status_cubit.dart';
import 'package:lekhan_ai/features/upload/data/datasources/local/upload_session_local_datasource.dart';
import 'package:lekhan_ai/features/upload/data/datasources/remote/upload_remote_datasource.dart';
import 'package:lekhan_ai/features/upload/data/datasources/remote/mock_upload_remote_datasource.dart';
import 'package:lekhan_ai/features/upload/data/repositories/upload_repository_impl.dart';
import 'package:lekhan_ai/features/upload/data/services/resumable_uploader.dart';
import 'package:lekhan_ai/features/upload/domain/repositories/upload_repository.dart';
import 'package:lekhan_ai/features/upload/domain/usecases/upload_source_usecase.dart';
import 'package:lekhan_ai/features/upload/domain/usecases/watch_upload_sessions_usecase.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/data/local/token_storage_service.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_repository.dart';

/// Registers everything belonging to the offline-first layer.
///
/// Kept in its own file so the existing `di_config.dart` needed exactly two
/// additive lines (an import and a call) and no existing registration was
/// touched. All HTTP still goes through the already registered
/// `dioNetworkService`; nothing about the network stack changed.
Future<void> registerOfflineFirstDependencies() async {
  // ---------------------------------------------------------------------------
  // Step 1 - database + file store (must be ready before anything reads data)
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  await sl<AppDatabase>().init();

  sl.registerLazySingleton<LocalFileStorage>(() => LocalFileStorage());
  await sl<LocalFileStorage>().init();

  sl.registerLazySingleton<StorageManager>(
    () => StorageManager(localFileStorage: sl<LocalFileStorage>()),
  );

  // ---------------------------------------------------------------------------
  // Step 2 - platform helpers
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfo(alwaysOnline: BackendMode.useMockBackend),
  );
  sl.registerLazySingleton<PermissionService>(() => const PermissionService());

  // ---------------------------------------------------------------------------
  // Step 3 - local datasources (one per box)
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<ProjectLocalDataSource>(
    () => ProjectLocalDataSourceImpl(database: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<BookLocalDataSource>(
    () => BookLocalDataSourceImpl(database: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<ChapterLocalDataSource>(
    () => ChapterLocalDataSourceImpl(database: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<ChapterSourceLocalDataSource>(
    () => ChapterSourceLocalDataSourceImpl(database: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<UploadSessionLocalDataSource>(
    () => UploadSessionLocalDataSourceImpl(database: sl<AppDatabase>()),
  );

  // ---------------------------------------------------------------------------
  // Step 4 - remote boundaries. The API implementations remain registered as
  // future integration seams, but this stage defaults to an in-memory backend
  // and never resolves or calls the authenticated HTTP client.
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<MockLekhanBackend>(() => MockLekhanBackend());
  final NetworkService? api = BackendMode.useMockBackend
      ? null
      : sl<NetworkService>(instanceName: 'dioNetworkService');

  sl.registerLazySingleton<ProjectRemoteDataSource>(
    () => BackendMode.useMockBackend
        ? MockProjectRemoteDataSource(backend: sl<MockLekhanBackend>())
        : ProjectRemoteDataSourceImpl(networkService: api!),
  );
  sl.registerLazySingleton<BookRemoteDataSource>(
    () => BackendMode.useMockBackend
        ? MockBookRemoteDataSource(backend: sl<MockLekhanBackend>())
        : BookRemoteDataSourceImpl(networkService: api!),
  );
  sl.registerLazySingleton<ChapterRemoteDataSource>(
    () => BackendMode.useMockBackend
        ? MockChapterRemoteDataSource(backend: sl<MockLekhanBackend>())
        : ChapterRemoteDataSourceImpl(networkService: api!),
  );
  sl.registerLazySingleton<ChapterSourceRemoteDataSource>(
    () => BackendMode.useMockBackend
        ? MockChapterSourceRemoteDataSource(backend: sl<MockLekhanBackend>())
        : ChapterSourceRemoteDataSourceImpl(networkService: api!),
  );
  sl.registerLazySingleton<SyncRemoteDataSource>(
    () => BackendMode.useMockBackend
        ? MockSyncRemoteDataSource(backend: sl<MockLekhanBackend>())
        : SyncRemoteDataSourceImpl(networkService: api!),
  );
  sl.registerLazySingleton<UploadRemoteDataSource>(
    () => BackendMode.useMockBackend
        ? MockUploadRemoteDataSource(backend: sl<MockLekhanBackend>())
        : UploadRemoteDataSourceImpl(
            networkService: api!,
            // Chunk transfers use a longer timeout when the API is enabled.
            dio: sl<Dio>(instanceName: 'jwtDioInstance'),
          ),
  );

  // ---------------------------------------------------------------------------
  // Step 5 - sync plumbing
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<SyncRequestBus>(() => SyncRequestBus());
  sl.registerLazySingleton<SyncQueue>(
    () => HiveSyncQueue(database: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<SyncPreferences>(
    () => SyncPreferences(storageService: sl<StorageService>()),
  );
  sl.registerLazySingleton<SyncCheckpointStore>(
    () => SyncCheckpointStore(storageService: sl<StorageService>()),
  );

  // ---------------------------------------------------------------------------
  // Step 6 - repositories
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(
      local: sl<ProjectLocalDataSource>(),
      remote: sl<ProjectRemoteDataSource>(),
      queue: sl<SyncQueue>(),
      requestBus: sl<SyncRequestBus>(),
    ),
  );

  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(
      local: sl<BookLocalDataSource>(),
      remote: sl<BookRemoteDataSource>(),
      queue: sl<SyncQueue>(),
      requestBus: sl<SyncRequestBus>(),
      projectLocal: sl<ProjectLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<ChapterRepository>(
    () => ChapterRepositoryImpl(
      local: sl<ChapterLocalDataSource>(),
      remote: sl<ChapterRemoteDataSource>(),
      queue: sl<SyncQueue>(),
      requestBus: sl<SyncRequestBus>(),
      bookLocal: sl<BookLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<ChapterSourceRepository>(
    () => ChapterSourceRepositoryImpl(
      local: sl<ChapterSourceLocalDataSource>(),
      remote: sl<ChapterSourceRemoteDataSource>(),
      queue: sl<SyncQueue>(),
      requestBus: sl<SyncRequestBus>(),
      storageManager: sl<StorageManager>(),
    ),
  );

  sl.registerLazySingleton<ResumableUploader>(
    () => ResumableUploader(
      remote: sl<UploadRemoteDataSource>(),
      sessions: sl<UploadSessionLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<RecordingService>(
    () => RecordingService(permissionService: sl<PermissionService>()),
  );

  sl.registerLazySingleton<UploadRepository>(
    () => UploadRepositoryImpl(
      local: sl<UploadSessionLocalDataSource>(),
      uploader: sl<ResumableUploader>(),
    ),
  );

  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(
      manager: sl<SyncManager>(),
      queue: sl<SyncQueue>(),
      checkpointStore: sl<SyncCheckpointStore>(),
      remote: sl<SyncRemoteDataSource>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Step 7 - sync engine (handlers -> worker -> manager -> bootstrap)
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<SyncReferenceResolver>(
    () => SyncReferenceResolver(
      projectLocal: sl<ProjectLocalDataSource>(),
      bookLocal: sl<BookLocalDataSource>(),
      chapterLocal: sl<ChapterLocalDataSource>(),
      sourceLocal: sl<ChapterSourceLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<SyncEntityApplier>(
    () => SyncEntityApplier(
      projectLocal: sl<ProjectLocalDataSource>(),
      bookLocal: sl<BookLocalDataSource>(),
      chapterLocal: sl<ChapterLocalDataSource>(),
      sourceLocal: sl<ChapterSourceLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<SyncPullApplier>(
    () => SyncPullApplier(
      projectLocal: sl<ProjectLocalDataSource>(),
      bookLocal: sl<BookLocalDataSource>(),
      chapterLocal: sl<ChapterLocalDataSource>(),
      sourceLocal: sl<ChapterSourceLocalDataSource>(),
      entityApplier: sl<SyncEntityApplier>(),
      conflicts: const ConflictResolver(),
    ),
  );

  sl.registerLazySingleton<SyncPullService>(
    () => SyncPullService(
      remote: sl<SyncRemoteDataSource>(),
      applier: sl<SyncPullApplier>(),
      checkpointStore: sl<SyncCheckpointStore>(),
    ),
  );

  sl.registerLazySingleton<OfflineSessionGuard>(
    () => OfflineSessionGuard(
      tokenStorage: sl<TokenStorageService>(),
      userRepository: sl<UserRepository>(),
      storageService: sl<StorageService>(),
      database: sl<AppDatabase>(),
      storageManager: sl<StorageManager>(),
      checkpointStore: sl<SyncCheckpointStore>(),
      backgroundScheduler: sl<BackgroundSyncScheduler>(),
    ),
  );

  sl.registerLazySingleton<MetadataPushService>(
    () => MetadataPushService(
      remote: sl<SyncRemoteDataSource>(),
      resolver: sl<SyncReferenceResolver>(),
      applier: sl<SyncEntityApplier>(),
    ),
  );

  sl.registerLazySingleton<SyncTaskHandler>(
    () => ProjectPushHandler(service: sl<MetadataPushService>()),
    instanceName: 'projectPushHandler',
  );
  sl.registerLazySingleton<SyncTaskHandler>(
    () => BookPushHandler(service: sl<MetadataPushService>()),
    instanceName: 'bookPushHandler',
  );
  sl.registerLazySingleton<SyncTaskHandler>(
    () => ChapterPushHandler(service: sl<MetadataPushService>()),
    instanceName: 'chapterPushHandler',
  );
  sl.registerLazySingleton<SyncTaskHandler>(
    () => ChapterSourceMetadataPushHandler(service: sl<MetadataPushService>()),
    instanceName: 'chapterSourcePushHandler',
  );
  sl.registerLazySingleton<SyncTaskHandler>(
    () => ProgressPushHandler(service: sl<MetadataPushService>()),
    instanceName: 'progressPushHandler',
  );
  sl.registerLazySingleton<SyncTaskHandler>(
    () => SourceUploadHandler(
      uploader: sl<ResumableUploader>(),
      sourceRepository: sl<ChapterSourceRepository>(),
      chapterLocal: sl<ChapterLocalDataSource>(),
      queue: sl<SyncQueue>(),
    ),
    instanceName: 'sourceUploadHandler',
  );

  sl.registerLazySingleton<SyncWorker>(
    () => SyncWorker(
      handlers: <SyncTaskHandler>[
        sl<SyncTaskHandler>(instanceName: 'projectPushHandler'),
        sl<SyncTaskHandler>(instanceName: 'bookPushHandler'),
        sl<SyncTaskHandler>(instanceName: 'chapterPushHandler'),
        sl<SyncTaskHandler>(instanceName: 'chapterSourcePushHandler'),
        sl<SyncTaskHandler>(instanceName: 'progressPushHandler'),
        sl<SyncTaskHandler>(instanceName: 'sourceUploadHandler'),
      ],
    ),
  );

  sl.registerLazySingleton<SyncManager>(
    () => SyncManager(
      queue: sl<SyncQueue>(),
      worker: sl<SyncWorker>(),
      networkInfo: sl<NetworkInfo>(),
      preferences: sl<SyncPreferences>(),
      checkpointStore: sl<SyncCheckpointStore>(),
      pullRunner: sl<SyncPullService>(),
      isAuthorized: () => sl<OfflineSessionGuard>().canSync(),
    ),
  );

  sl.registerLazySingleton<BackgroundSyncScheduler>(
    () => BackgroundSyncScheduler(),
  );

  sl.registerLazySingleton<SyncBootstrap>(
    () => SyncBootstrap(
      syncManager: sl<SyncManager>(),
      queue: sl<SyncQueue>(),
      preferences: sl<SyncPreferences>(),
      backgroundScheduler: sl<BackgroundSyncScheduler>(),
      storageManager: sl<StorageManager>(),
      requestBus: sl<SyncRequestBus>(),
      sessionGuard: sl<OfflineSessionGuard>(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Step 8 - use cases
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton(
    () => GetProjectsUsecase(repository: sl<ProjectRepository>()),
  );
  sl.registerLazySingleton(
    () => GetProjectDetailUsecase(repository: sl<ProjectRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchProjectsUsecase(repository: sl<ProjectRepository>()),
  );
  sl.registerLazySingleton(
    () => SaveProjectUsecase(repository: sl<ProjectRepository>()),
  );

  sl.registerLazySingleton(
    () => GetBooksUsecase(repository: sl<BookRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchBooksUsecase(repository: sl<BookRepository>()),
  );
  sl.registerLazySingleton(
    () => GetBookDetailUsecase(repository: sl<BookRepository>()),
  );
  sl.registerLazySingleton(
    () => SaveBookUsecase(repository: sl<BookRepository>()),
  );

  sl.registerLazySingleton(
    () => GetChaptersUsecase(repository: sl<ChapterRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchChaptersUsecase(repository: sl<ChapterRepository>()),
  );
  sl.registerLazySingleton(
    () => GetChapterDetailUsecase(repository: sl<ChapterRepository>()),
  );
  sl.registerLazySingleton(
    () => SaveChapterUsecase(repository: sl<ChapterRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateChapterProgressUsecase(repository: sl<ChapterRepository>()),
  );

  sl.registerLazySingleton(
    () => GetChapterSourcesUsecase(repository: sl<ChapterSourceRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchChapterSourcesUsecase(repository: sl<ChapterSourceRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchUploadStatusUsecase(repository: sl<ChapterSourceRepository>()),
  );
  sl.registerLazySingleton(
    () => RetryUploadUsecase(repository: sl<ChapterSourceRepository>()),
  );
  sl.registerLazySingleton(
    () => AddExistingFileUsecase(
      repository: sl<ChapterSourceRepository>(),
      chapterRepository: sl<ChapterRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => AddSourceUsecase(
      repository: sl<ChapterSourceRepository>(),
      chapterRepository: sl<ChapterRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => DeleteSourceUsecase(
      repository: sl<ChapterSourceRepository>(),
      chapterRepository: sl<ChapterRepository>(),
    ),
  );
  sl.registerLazySingleton(
    () => DeleteChapterUsecase(
      chapters: sl<ChapterRepository>(),
      sources: sl<ChapterSourceRepository>(),
      deleteSource: sl<DeleteSourceUsecase>(),
    ),
  );
  sl.registerLazySingleton(
    () => DeleteBookUsecase(
      books: sl<BookRepository>(),
      chapters: sl<ChapterRepository>(),
      deleteChapter: sl<DeleteChapterUsecase>(),
    ),
  );
  sl.registerLazySingleton(
    () => DeleteProjectUsecase(
      projects: sl<ProjectRepository>(),
      books: sl<BookRepository>(),
      deleteBook: sl<DeleteBookUsecase>(),
    ),
  );

  sl.registerLazySingleton(
    () => UploadSourceUsecase(repository: sl<UploadRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchUploadSessionsUsecase(repository: sl<UploadRepository>()),
  );
  sl.registerLazySingleton(
    () => GetOpenUploadsUsecase(repository: sl<UploadRepository>()),
  );
  sl.registerLazySingleton(
    () => CancelUploadUsecase(repository: sl<UploadRepository>()),
  );

  sl.registerLazySingleton(
    () => SyncNowUsecase(repository: sl<SyncRepository>()),
  );
  sl.registerLazySingleton(
    () => GetSyncStatusUsecase(repository: sl<SyncRepository>()),
  );
  sl.registerLazySingleton(
    () => RetrySyncUsecase(repository: sl<SyncRepository>()),
  );
  sl.registerLazySingleton(
    () => RetrySingleTaskUsecase(repository: sl<SyncRepository>()),
  );
  sl.registerLazySingleton(
    () => CancelSyncTaskUsecase(repository: sl<SyncRepository>()),
  );

  // ---------------------------------------------------------------------------
  // Step 9 - presentation (factories: a screen gets its own instance)
  // ---------------------------------------------------------------------------
  sl.registerFactory(
    () => ProjectsBloc(
      getProjects: sl<GetProjectsUsecase>(),
      watchProjects: sl<WatchProjectsUsecase>(),
      saveProject: sl<SaveProjectUsecase>(),
    ),
  );

  sl.registerFactory(
    () => BooksBloc(
      projectId: '', // Will be provided by the page
      getBooks: sl<GetBooksUsecase>(),
      watchBooks: sl<WatchBooksUsecase>(),
    ),
  );

  sl.registerFactory(
    () => ChaptersBloc(
      bookId: '', // Will be provided by the page
      getChapters: sl<GetChaptersUsecase>(),
      watchChapters: sl<WatchChaptersUsecase>(),
    ),
  );

  sl.registerFactory(
    () => SyncStatusCubit(
      getStatus: sl<GetSyncStatusUsecase>(),
      syncNowUsecase: sl<SyncNowUsecase>(),
      retryUsecase: sl<RetrySyncUsecase>(),
    ),
  );
}

/// Test/DI helper: the same container instance the app uses.
GetIt get locator => sl;
