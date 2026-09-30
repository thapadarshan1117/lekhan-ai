import 'package:lekhan_ai/core/config/dependency_injection/di_config.dart';
import 'package:lekhan_ai/core/config/size_config/size.config.dart';
import 'package:lekhan_ai/main.dart' show scaffoldMessengerKey;
import 'package:lekhan_ai/core/router/route_manager.dart';
import 'package:lekhan_ai/core/theme/customs/chip_theme.dart';
import 'package:lekhan_ai/core/theme/customs/elevated_button_theme.dart';
import 'package:lekhan_ai/core/theme/customs/outlined_button_theme.dart';
import 'package:lekhan_ai/core/theme/customs/text_theme.dart';
import 'package:lekhan_ai/core/utils/snack_bars.dart';
import 'package:lekhan_ai/core/utils/snackbra_utils.dart';
import 'package:lekhan_ai/core/utils/text_scaler.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';

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
        BlocProvider(create: (context) => sl<LanguageBloc>()),
        BlocProvider(create: (context) => sl<NotificationBloc>()),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          return BlocBuilder<AppThemeCubit, AppThemeState>(
            builder: (context, themeState) {
              final scheme = themeState.colorScheme;

              return MaterialApp.router(
                scaffoldMessengerKey: scaffoldMessengerKey,
                routerConfig: RouterManager.router,
                theme: ThemeData(
                  dividerColor: Colors.transparent,
                  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
                  outlinedButtonTheme: outlinedButtonTheme(scheme),
                  elevatedButtonTheme: elevatedButtonTheme(context, scheme),
                  colorScheme: scheme,
                  chipTheme: CustomChipTheme.lightChipTheme,
                  textTheme: TTextTheme.textTheme(const Color(0xFF191c1f)),
                ),
                debugShowCheckedModeBanner: false,
                locale: state.selectedLanguage.value,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: L10n.all,
                builder: (context, child) {
                  final MediaQueryData data = MediaQuery.of(context);
                  SizeConfig.init(context);
                  return BlocListener<
                    InternetConnectionCubit,
                    InternetConnectionState
                  >(
                    listener: (context, state) {
                      if (state.status == ConnectivityStatus.disconnected) {
                        SnackbarUtils.internetConnectionSnackBar(
                          context,
                          'No internet connection!',
                        );
                      } else {
                        SnackBars.hideCurrentSnackBar(context);
                      }
                    },
                    child: MediaQuery(
                      data: data.copyWith(
                        textScaler: TextScaler.linear(
                          ScaleSize.textScaleFactor(context),
                        ),
                      ),
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
