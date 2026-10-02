import 'dart:async';

import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/sync/sync_bootstrap.dart';
import 'package:lekhan_ai/core/config/size_config/size.config.dart';
import 'package:lekhan_ai/main.dart' show scaffoldMessengerKey;
import 'package:lekhan_ai/core/router/route_manager.dart';
import 'package:lekhan_ai/core/theme/customs/chip_theme.dart';
import 'package:lekhan_ai/core/theme/customs/elevated_button_theme.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/core/theme/customs/outlined_button_theme.dart';
import 'package:lekhan_ai/core/theme/customs/text_field_theme.dart';
import 'package:lekhan_ai/core/theme/customs/text_theme.dart';
import 'package:lekhan_ai/core/utils/snack_bars.dart';
import 'package:lekhan_ai/core/utils/snackbra_utils.dart';
import 'package:lekhan_ai/core/theme/domain/model/app_theme_config.dart';
import 'package:lekhan_ai/core/theme/domain/repository/app_theme_repository.dart';
import 'package:lekhan_ai/core/theme/presentation/cubit/app_theme_cubit.dart';
import 'package:lekhan_ai/features/account/presentation/bloc/account_bloc/account_bloc.dart';
import 'package:lekhan_ai/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:lekhan_ai/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:lekhan_ai/l10n/app_localizations.dart';
import 'package:lekhan_ai/l10n/l10n.dart';
import 'package:lekhan_ai/shared/bloc/cubit/internet_connection_cubit.dart';
import 'package:lekhan_ai/shared/language/presentation/language_bloc/language_bloc.dart';
import 'package:lekhan_ai/shared/user/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.initialThemeConfig});

  final AppThemeConfig? initialThemeConfig;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RouterManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(sl<SyncBootstrap>().onAppResumed());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(sl<SyncBootstrap>().onAppPaused());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => InternetConnectionCubit()),
        BlocProvider<AppThemeCubit>(
          lazy: false,
          // Backend has no custom-themes endpoint; skip the network refresh
          // and use the default/initial color scheme.
          create: (context) => AppThemeCubit(
            repository: sl<AppThemeRepository>(),
            initialConfig: widget.initialThemeConfig,
          ),
        ),
        BlocProvider(
          create: (context) =>
              sl<UserBloc>()..add(const UserEvent.getUserInfo()),
        ),
        BlocProvider(create: (context) => sl<AuthBloc>()),
        BlocProvider(create: (context) => sl<AccountBloc>()),
        BlocProvider(
          create: (context) =>
              sl<LanguageBloc>()..add(const FetchedSelectedLanguage()),
        ),
        BlocProvider(create: (context) => sl<NotificationBloc>()),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          return BlocBuilder<AppThemeCubit, AppThemeState>(
            builder: (context, themeState) {
              final scheme = themeState.colorScheme;

              final TextTheme accessibleTextTheme =
                  TTextTheme.textTheme(AppColors.textPrimary);

              return MaterialApp.router(
                scaffoldMessengerKey: scaffoldMessengerKey,
                routerConfig: RouterManager.router,
                color: AppColors.primary,
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: scheme,
                  scaffoldBackgroundColor: AppColors.background,
                  canvasColor: AppColors.background,
                  dividerColor: AppColors.dividerLight,
                  visualDensity: VisualDensity.standard,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  outlinedButtonTheme: outlinedButtonTheme(scheme),
                  elevatedButtonTheme: elevatedButtonTheme(scheme),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.primary,
                      minimumSize: const Size(48, 48),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  iconButtonTheme: IconButtonThemeData(
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size(48, 48),
                      iconSize: 26,
                    ),
                  ),
                  floatingActionButtonTheme: FloatingActionButtonThemeData(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    extendedTextStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    extendedPadding:
                        const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  appBarTheme: AppBarTheme(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.textPrimary,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    centerTitle: false,
                    iconTheme: const IconThemeData(
                      color: AppColors.textPrimary,
                      size: 28,
                    ),
                    titleTextStyle: accessibleTextTheme.titleLarge,
                  ),
                  inputDecorationTheme:
                      TTextFieldTheme.inputDecorationTheme(scheme),
                  chipTheme: CustomChipTheme.lightChipTheme,
                  textTheme: accessibleTextTheme,
                  snackBarTheme: const SnackBarThemeData(
                    behavior: SnackBarBehavior.floating,
                    contentTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
                locale: state.selectedLanguage.value,
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                supportedLocales: L10n.all,
                builder: (context, child) {
                  SizeConfig.init(context);
                  return BlocListener<AuthBloc, AuthState>(
                    listenWhen: (AuthState previous, AuthState current) =>
                        current.maybeWhen(
                      success: (_, __) => true,
                      otpVerified: (_, __, ___) => true,
                      orElse: () => false,
                    ),
                    listener: (BuildContext context, AuthState state) {
                      state.maybeWhen(
                        success: (_, __) =>
                            unawaited(sl<SyncBootstrap>().onSignedIn()),
                        otpVerified: (_, __, ___) =>
                            unawaited(sl<SyncBootstrap>().onSignedIn()),
                        orElse: () {},
                      );
                    },
                    child: BlocListener<
                      InternetConnectionCubit,
                      InternetConnectionState
                    >(
                      listener: (context, state) {
                        if (state.status == ConnectivityStatus.disconnected) {
                          SnackbarUtils.internetConnectionSnackBar(
                            context,
                            context.l10n.noInternet,
                          );
                        } else {
                          SnackBars.hideCurrentSnackBar(context);
                        }
                      },
                      // Preserve the operating system's text scale. Older users
                      // who enlarge text in phone settings should see that choice
                      // reflected throughout the app.
                      child: child!,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
