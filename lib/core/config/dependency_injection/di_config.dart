import 'package:lekhan_ai/onboarding/data/datasource/onboard_datasource.dart';
import 'package:lekhan_ai/onboarding/data/repositories/onboarding_repo_impl.dart';
import 'package:lekhan_ai/onboarding/data/repositories/splash_repository_impl.dart';
import 'package:lekhan_ai/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:lekhan_ai/onboarding/domain/repositories/splash_repository.dart';
import 'package:lekhan_ai/onboarding/domain/usecases/check_splash_status_usecase.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lekhan_ai/features/auth/data/datasource/remote/auth_datasource.dart';
import 'package:lekhan_ai/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:lekhan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/login_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/otp_resend_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/register_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:lekhan_ai/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:lekhan_ai/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:lekhan_ai/features/account/data/datasource/remote/account_datasource.dart';
import 'package:lekhan_ai/features/account/data/repositories/account_repo_impl.dart';
import 'package:lekhan_ai/features/account/domain/repositories/account_repository.dart';
import 'package:lekhan_ai/features/account/domain/usecases/change_password_usecase.dart';
import 'package:lekhan_ai/features/account/presentation/bloc/account_bloc/account_bloc.dart';
import 'package:lekhan_ai/shared/data/local/fcm_token_service.dart';
import 'package:lekhan_ai/shared/data/local/hive_service.dart';
import 'package:lekhan_ai/shared/data/local/shared_pref_service.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';
import 'package:lekhan_ai/shared/data/local/token_storage_service.dart';
import 'package:lekhan_ai/shared/data/local/token_storage_service_impl.dart';
import 'package:lekhan_ai/shared/user/data/datasource/local/user_local_datasource.dart';
import 'package:lekhan_ai/shared/data/remote/auth_network_service.dart';
import 'package:lekhan_ai/shared/data/remote/dio_network_service.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/language/data/datasource/local/language_local_datasource.dart';
import 'package:lekhan_ai/shared/language/data/repositories/language_pref_repo_impl.dart';
import 'package:lekhan_ai/shared/language/domain/repositories/language_pref_repository.dart';
import 'package:lekhan_ai/shared/language/domain/usecases/get_selected_language_usecase.dart';
import 'package:lekhan_ai/shared/language/domain/usecases/set_selected_language_usecase.dart';
import 'package:lekhan_ai/shared/language/presentation/language_bloc/language_bloc.dart';
import 'package:lekhan_ai/shared/user/bloc/user_bloc.dart';
import 'package:lekhan_ai/shared/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:lekhan_ai/shared/user/data/reposiitories/user_remote_repository_impl.dart';
import 'package:lekhan_ai/shared/user/data/reposiitories/user_repositories_impl.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_remote_repository.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_repository.dart';
import 'package:lekhan_ai/shared/user/domain/usecase/get_remote_user_usecase.dart';


import 'package:lekhan_ai/core/theme/data/datasource/local/app_theme_local_datasource.dart';
import 'package:lekhan_ai/core/theme/data/datasource/remote/app_theme_remote_datasource.dart';
import 'package:lekhan_ai/core/theme/data/repository/app_theme_repository_impl.dart';
import 'package:lekhan_ai/core/theme/domain/repository/app_theme_repository.dart';

import 'package:lekhan_ai/shared/custom_fields/data/datasource/local/custom_fields_local_datasource.dart';
import 'package:lekhan_ai/shared/custom_fields/data/datasource/remote/custom_fields_remote_datasource.dart';
import 'package:lekhan_ai/shared/custom_fields/data/repository/custom_fields_repository_impl.dart';
import 'package:lekhan_ai/shared/custom_fields/domain/repository/custom_fields_repository.dart';




// Notification Feature
import 'package:lekhan_ai/features/notifications/data/datasources/notification_datasource.dart';
import 'package:lekhan_ai/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:lekhan_ai/features/notifications/domain/repositories/notification_repository.dart';
import 'package:lekhan_ai/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:lekhan_ai/features/notifications/domain/usecases/mark_as_read_usecase.dart';
import 'package:lekhan_ai/features/notifications/presentation/bloc/notification_bloc.dart';



import 'package:lekhan_ai/core/config/dependency_injection/offline_di.dart';

final GetIt sl = GetIt.instance;

Future<void> setUpServiceLocator() async {
  //-------------------------------------------------------------------------------
  // STEP 1: Register Basic Services (with no dependencies)
  //-------------------------------------------------------------------------------
  sl.registerLazySingleton(() => HiveService());
  sl.registerLazySingleton(() => FCMTokenService());
  sl.registerLazySingleton<TokenStorageService>(
    () => SecureTokenStorageService(),
  );

  sl.registerLazySingleton<StorageService>(() {
    final SharedPrefsService prefsService = SharedPrefsService();
    prefsService.init();
    return prefsService;
  });

  // Register Dio instances (no dependencies)
  sl.registerLazySingleton<Dio>(() => Dio(), instanceName: 'authDioInstance');
  sl.registerLazySingleton<Dio>(() => Dio(), instanceName: 'jwtDioInstance');

  // Register basic network service (auth - with simple Dio dependency)
  sl.registerLazySingleton<NetworkService>(
    () => AuthNetworkService(dio: sl<Dio>(instanceName: 'authDioInstance')),
    instanceName: 'authNetworkService',
  );

  //-------------------------------------------------------------------------------
  // STEP 2: Register User Services (before they're needed by other services)
  //-------------------------------------------------------------------------------
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDatasourceImpl(storageService: sl<StorageService>()),
  );
  sl.registerLazySingleton<UserRemoteDatasource>(
    () => UserRemoteDatasourceImpl(
      userRepository: sl<UserRepository>(),
      networkService: sl<NetworkService>(instanceName: 'dioNetworkService'),
    ),
  );

  sl.registerLazySingleton<UserRemoteRepository>(
    () => UserRemoteRepositoryImpl(sl<UserRemoteDatasource>()),
  );

  sl.registerLazySingleton(
    () => GetRemoteUserUsecase(sl<UserRemoteRepository>()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl<UserLocalDataSource>()),
  );

  sl.registerFactory<UserBloc>(
    () => UserBloc(sl<UserRepository>(), sl<GetRemoteUserUsecase>()),
  );
  sl
    ..registerLazySingleton<OnboardDatasource>(
      () => OnboardDatasourceImpl(storageService: sl<StorageService>()),
    )
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(sl<OnboardDatasource>()),
    )
    ..registerLazySingleton<SplashRepository>(
      () => SplashRepositoryImpl(
        onboardingRepository: sl<OnboardingRepository>(),
        tokenStorageService: sl<TokenStorageService>(),
        storageService: sl<StorageService>(),
      ),
    )
    ..registerLazySingleton<CheckSplashStatusUsecase>(
      () => CheckSplashStatusUsecase(splashRepository: sl<SplashRepository>()),
    );

  //-------------------------------------------------------------------------------
  // STEP 3: Now register services that depend on User Repository
  //-------------------------------------------------------------------------------
  sl.registerLazySingleton<NetworkService>(
    () => DioNetworkService(
      dio: sl<Dio>(instanceName: 'jwtDioInstance'),
      tokenStorageService: sl<TokenStorageService>(),
      userRepository: sl<UserRepository>(),
    ),
    instanceName: 'dioNetworkService',
  );

  //-------------------------------------------------------------------------------
  // Dynamic Theme Dependencies
  //-------------------------------------------------------------------------------
  sl.registerLazySingleton<AppThemeLocalDataSource>(
    () => AppThemeLocalDataSourceImpl(storageService: sl<StorageService>()),
  );

  sl.registerLazySingleton<AppThemeRemoteDataSource>(
    () => AppThemeRemoteDataSourceImpl(
      networkService: sl<NetworkService>(instanceName: 'dioNetworkService'),
    ),
  );

  sl.registerLazySingleton<AppThemeRepository>(
    () => AppThemeRepositoryImpl(
      local: sl<AppThemeLocalDataSource>(),
      remote: sl<AppThemeRemoteDataSource>(),
    ),
  );

  //-------------------------------------------------------------------------------
  // Custom Fields (Dynamic Form) Dependencies
  //-------------------------------------------------------------------------------
  sl.registerLazySingleton<CustomFieldsLocalDataSource>(
    () => CustomFieldsLocalDataSourceImpl(storageService: sl<StorageService>()),
  );

  sl.registerLazySingleton<CustomFieldsRemoteDataSource>(
    () => CustomFieldsRemoteDataSourceImpl(
      networkService: sl<NetworkService>(instanceName: 'dioNetworkService'),
    ),
  );

  sl.registerLazySingleton<CustomFieldsRepository>(
    () => CustomFieldsRepositoryImpl(
      local: sl<CustomFieldsLocalDataSource>(),
      remote: sl<CustomFieldsRemoteDataSource>(),
    ),
  );

  //-------------------------------------------------------------------------------
  // STEP 4: Register Firebase API (after its dependencies are registered)
  //-------------------------------------------------------------------------------

  //-------------------------------------------------------------------------------
  // STEP 5: Register Language Services
  //-------------------------------------------------------------------------------
  sl.registerLazySingleton<LanguageLocalDataSource>(
    () => LanguageLocalDatasourceImpl(storageService: sl<StorageService>()),
  );

  sl.registerLazySingleton<LanguagePrefRepository>(
    () => LanguagePrefRepoImpl(
      languageLocalDataSource: sl<LanguageLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton(
    () => GetSelectedLanguageUseCase(sl<LanguagePrefRepository>()),
  );

  sl.registerLazySingleton(
    () => SetSelectedLanguageUseCase(sl<LanguagePrefRepository>()),
  );

  sl.registerFactory(
    () => LanguageBloc(
      getSelectedLanguageUseCase: sl<GetSelectedLanguageUseCase>(),
      setSelectedLanguageUseCase: sl<SetSelectedLanguageUseCase>(),
    ),
  );

  //Auth
  sl.registerLazySingleton<AuthDatasource>(
    () => AuthDataSourceImpl(
      userRepository: sl<UserRepository>(),
      tokenStorageService: sl<TokenStorageService>(),
      networkService: sl<NetworkService>(instanceName: 'authNetworkService'),
      fcmTokenService: sl<FCMTokenService>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthDatasource>()),
  );

  // Register Auth Use Cases

  sl.registerLazySingleton(
    () => RegisterUsecase(authRepository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton(
    () => LoginUsecase(authRepository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton(
    () => LogoutUsecase(authRepository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(() => OtpResendUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtpUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUsecase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUsecase(sl<AuthRepository>()));

  // Register Auth Bloc
  sl.registerFactory(
    () => AuthBloc(
      registerUsecase: sl<RegisterUsecase>(),
      loginUsecase: sl<LoginUsecase>(),
      logoutUsecase: sl<LogoutUsecase>(),
      otpResendUsecase: sl<OtpResendUsecase>(),
      verifyOtpUsecase: sl<VerifyOtpUsecase>(),
      forgotPasswordUseCase: sl<ForgotPasswordUsecase>(),
      resetPasswordUseCase: sl<ResetPasswordUsecase>(),
    ),
  );

  // Account Feature Dependencies
  sl.registerLazySingleton<AccountDatasource>(
    () => AccountDatasourceImpl(
      tokenStorageService: sl<TokenStorageService>(),
      userLocalDataSource: sl<UserLocalDataSource>(),
      networkService: sl<NetworkService>(instanceName: 'dioNetworkService'),
    ),
  );

  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(sl<AccountDatasource>()),
  );

  sl.registerLazySingleton(
    () => ChangePasswordUsecase(sl<AccountRepository>()),
  );

  sl.registerFactory(
    () => AccountBloc(changePasswordUsecase: sl<ChangePasswordUsecase>()),
  );
  
  

  //-------------------------------------------------------------------------------
  // STEP 15: Register Notification Feature Dependencies
  //-------------------------------------------------------------------------------
  sl.registerLazySingleton<INotificationDatasource>(
    () => NotificationDatasourceImpl(
      fcmTokenService: sl<FCMTokenService>(),
      networkService: sl<NetworkService>(instanceName: 'dioNetworkService'),
    ),
  );

  sl.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      notificationDatasource: sl<INotificationDatasource>(),
    ),
  );

  sl.registerLazySingleton(
    () => GetNotificationsUsecase(
      repository: sl<INotificationRepository>(),
    ),
  );

  sl.registerLazySingleton(
    () => MarkAsReadUsecase(sl<INotificationRepository>()),
  );

  sl.registerFactory(
    () => NotificationBloc(
      getNotificationsUsecase: sl<GetNotificationsUsecase>(),
      markAsReadUsecase: sl<MarkAsReadUsecase>(),
    ),
  );

  //-------------------------------------------------------------------------------
  // STEP 16: Offline-first layer (database, file store, sync engine, and the
  // project/book/chapter/source features). Registered last because it depends on
  // UserRepository, StorageService and the jwt NetworkService above. Nothing in
  // this file was modified to make room for it.
  //-------------------------------------------------------------------------------
  await registerOfflineFirstDependencies();
}