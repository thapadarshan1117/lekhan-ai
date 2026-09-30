import 'package:flutter/services.dart';
import 'dart:async';

enum HapticIntensity {
  selection,
  light,
  medium,
}

/// Small helpers for lightweight haptic feedback.
/// Use these so we can centralize behavior later if we need platform-specific tweaks.
class HapticUtils {
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Light impact suitable for taps
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium impact
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  static Future<void> perform(HapticIntensity intensity) async {
    switch (intensity) {
      case HapticIntensity.selection:
        return selection();
      case HapticIntensity.light:
        return light();
      case HapticIntensity.medium:
        return medium();
    }
  }

  /// Wrap a callback so it triggers haptic feedback first.
  ///
  /// This keeps haptic behavior centralized and consistent.
  static VoidCallback? wrap(
    VoidCallback? callback, {
    HapticIntensity intensity = HapticIntensity.light,
  }) {
    if (callback == null) return null;
    return () {
      unawaited(perform(intensity));
      callback();
    };
  }
}
