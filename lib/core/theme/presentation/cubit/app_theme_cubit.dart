import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/theme/customs/color_scheme.dart';
import 'package:lekhan_ai/core/theme/domain/model/app_theme_config.dart';
import 'package:lekhan_ai/core/theme/domain/repository/app_theme_repository.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:flutter/material.dart';

class AppThemeState {
  final AppThemeConfig? config;
  final ColorScheme colorScheme;
  final bool isRefreshing;
  final AppException? lastError;

  const AppThemeState({
    required this.config,
    required this.colorScheme,
    required this.isRefreshing,
    required this.lastError,
  });

  factory AppThemeState.initial({AppThemeConfig? config}) {
    // Lekhan AI now has a fixed, accessible green identity. Keep the cached
    // config as metadata, but never let an older cached colour flash on launch.
    return AppThemeState(
      config: config,
      colorScheme: lightColorScheme,
      isRefreshing: false,
      lastError: null,
    );
  }

  AppThemeState copyWith({
    AppThemeConfig? config,
    ColorScheme? colorScheme,
    bool? isRefreshing,
    AppException? lastError,
    bool clearError = false,
  }) {
    return AppThemeState(
      config: config ?? this.config,
      colorScheme: colorScheme ?? this.colorScheme,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

class AppThemeCubit extends Cubit<AppThemeState> {
  final AppThemeRepository repository;

  AppThemeCubit({
    required this.repository,
    AppThemeConfig? initialConfig,
  }) : super(AppThemeState.initial(config: initialConfig));

  /// Refreshes theme from API, but keeps cache-first UX.
  Future<void> refreshIfNeeded({
    Duration maxCacheAge = const Duration(seconds: 6),
  }) async {
    emit(state.copyWith(isRefreshing: true, clearError: true));

    final res = await repository.getActiveTheme(
      forceRefresh: false,
      maxCacheAge: maxCacheAge,
    );

    res.fold(
      (e) {
        emit(state.copyWith(isRefreshing: false, lastError: e));
      },
      (theme) {
        if (theme == null) {
          emit(state.copyWith(isRefreshing: false));
          return;
        }

        // Avoid rebuild loops.
        if (state.config == theme) {
          emit(state.copyWith(isRefreshing: false));
          return;
        }

        emit(
          state.copyWith(
            config: theme,
            colorScheme: lightColorScheme,
            isRefreshing: false,
          ),
        );
      },
    );
  }

  Future<void> forceRefresh() async {
    emit(state.copyWith(isRefreshing: true, clearError: true));

    final res = await repository.getActiveTheme(
      forceRefresh: true,
      maxCacheAge: Duration.zero,
    );

    res.fold(
      (e) => emit(state.copyWith(isRefreshing: false, lastError: e)),
      (theme) {
        if (theme == null) {
          emit(state.copyWith(isRefreshing: false));
          return;
        }
        emit(
          state.copyWith(
            config: theme,
            colorScheme: lightColorScheme,
            isRefreshing: false,
          ),
        );
      },
    );
  }
}
