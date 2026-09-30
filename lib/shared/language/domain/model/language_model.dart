import 'dart:ui';

enum Language {
  nepali(
    Locale('ne', 'NP'),
    'Nepali',
  ),
  english(
    Locale('en', 'US'),
    'English',
  ),
  arabic(
    Locale('ar', 'SA'),
    'العربية',
  );

  const Language(
      this.value,
      this.text,
      );

  final Locale value;
  final String text;
}