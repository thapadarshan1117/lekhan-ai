import 'dart:ui';

enum Language {
  english(Locale('en'), 'English'),
  nepali(Locale('ne'), 'नेपाली');

  const Language(this.value, this.text);

  final Locale value;
  final String text;
}
