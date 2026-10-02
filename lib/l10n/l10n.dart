import 'package:flutter/material.dart';
import 'package:lekhan_ai/l10n/app_localizations.dart';

class L10n {
  const L10n._();

  static const List<Locale> all = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
