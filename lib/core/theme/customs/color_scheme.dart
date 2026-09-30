import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';

ColorScheme lightColorScheme = const ColorScheme.light(
  // PRIMARY
  primary: AppColors.primary,
  onPrimary: AppColors.onPrimary,
  primaryContainer: AppColors.primaryContainer,
  onPrimaryContainer: AppColors.onPrimaryContainer,

  // SECONDARY
  secondary: AppColors.secondary,
  onSecondary: AppColors.onSecondary,
  secondaryContainer: AppColors.secondaryContainer,
  onSecondaryContainer: AppColors.onSecondaryContainer,

  // TERTIARY
  tertiary: AppColors.tertiary,
  onTertiary: AppColors.onPrimary, // Using onPrimary for tertiary text
  tertiaryContainer: AppColors.surfaceVariant,
  onTertiaryContainer: AppColors.onSurface,

  // ERROR
  error: AppColors.error,
  onError: AppColors.onError,
  errorContainer: AppColors.errorContainer,
  onErrorContainer: AppColors.onErrorContainer,

  // SURFACE
  surface: AppColors.surface,
  surfaceDim: AppColors.surfaceVariant,
  surfaceBright: AppColors.background,
  

  surfaceContainerLowest: AppColors.background,
  surfaceContainerLow: AppColors.surface,
  surfaceContainer: AppColors.surfaceVariant,
  surfaceContainerHigh: AppColors.surfaceVariant,
  surfaceContainerHighest: AppColors.surfaceVariant,

  onSurface: AppColors.onSurface,
  onSurfaceVariant: AppColors.onSurfaceVariant,

  // OUTLINES
  outline: AppColors.outline,
  outlineVariant: AppColors.outlineVariant,

  // INVERSE
  inverseSurface: AppColors.onSurface,
  onInverseSurface: AppColors.surface,
  inversePrimary: AppColors.primary,

  // SHADOW & SCRIM
  shadow: Color(0xFF000000),
  scrim: Color(0x66000000),

  brightness: Brightness.light,
);
