import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/chapters/domain/entities/chapter.dart';
import 'package:lekhan_ai/features/chapters/presentation/widgets/chapter_card.dart';
import 'package:lekhan_ai/l10n/app_localizations.dart';

void main() {
  test('the primary brand colour is green', () {
    final int value = AppColors.primary.value;
    final int red = (value >> 16) & 0xFF;
    final int green = (value >> 8) & 0xFF;
    final int blue = value & 0xFF;

    expect(green, greaterThan(red));
    expect(green, greaterThan(blue));
  });

  testWidgets('voice action stays usable with enlarged text', (
    WidgetTester tester,
  ) async {
    bool recordPressed = false;
    final DateTime now = DateTime(2026, 10, 2);
    final Chapter chapter = Chapter(
      id: 'chapter-1',
      bookId: 'book-1',
      projectId: 'project-1',
      number: 1,
      title: 'My Childhood',
      summary: 'Memories of home, family, and school.',
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        home: MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.6),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ChapterCard(
                chapter: chapter,
                onTap: () {},
                onUpload: () => recordPressed = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Record voice'), findsOneWidget);
    expect(find.text('Open chapter'), findsOneWidget);
    expect(find.text('No voice recording yet'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('record-voice-button')),
    );
    await tester.pump();

    expect(recordPressed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chapter voice actions are available in Nepali', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime(2026, 10, 2);
    final Chapter chapter = Chapter(
      id: 'chapter-ne',
      bookId: 'book-ne',
      projectId: 'project-ne',
      number: 1,
      title: 'मेरो बाल्यकाल',
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ne'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ChapterCard(
              chapter: chapter,
              onTap: () {},
              onUpload: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('आवाज रेकर्ड गर्नुहोस्'), findsOneWidget);
    expect(find.text('अध्याय खोल्नुहोस्'), findsOneWidget);
    expect(find.text('अहिलेसम्म आवाज रेकर्ड गरिएको छैन'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
