import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/l10n/l10n.dart';

/// The shelf categories the ghost-writing desk sorts its projects into.
///
/// [Project.type] arrives as a free-form string from the backend, so the label
/// and the colour are resolved here once instead of at every call site. Anything
/// unrecognised keeps its own name rather than being forced into a shelf.
class ProjectCategory {
  const ProjectCategory._();

  static const String fallbackLabel = 'Book';

  static const Color _memoir = Color(0xFF1B7F4B);
  static const Color _travel = Color(0xFF0F766E);
  static const Color _military = Color(0xFF52616B);
  static const Color _heritage = Color(0xFFB45309);
  static const Color _philosophy = Color(0xFF6D28D9);
  static const Color _business = Color(0xFF1D4ED8);
  static const Color _stories = Color(0xFFBE185D);
  static const Color _general = Color(0xFF5A6B7A);

  /// Display name for a stored project/book type.
  static String label(String? type) {
    switch (_key(type)) {
      case 'memoir':
      case 'biography':
      case 'autobiography':
      case 'life_story':
        return 'Memoir / Autobiography';
      case 'travel':
      case 'tourism':
      case 'tourism_exploration':
        return 'Tourism & Exploration';
      case 'military':
      case 'geopolitics':
      case 'military_geopolitics':
        return 'Military & Geopolitics';
      case 'history':
      case 'culture':
      case 'cultural_heritage':
      case 'non_fiction':
        return 'Non-Fiction / Cultural Heritage';
      case 'philosophy':
      case 'mindfulness':
      case 'spiritual':
      case 'philosophy_mindfulness':
        return 'Philosophy & Mindfulness';
      case 'business':
      case 'leadership':
      case 'business_leadership':
        return 'Business & Leadership';
      case 'fiction':
      case 'stories':
      case 'novel':
      case 'memoir_stories':
        return 'Fiction & Stories';
      default:
        final String raw = (type ?? '').trim();
        return raw.isEmpty ? fallbackLabel : _titleCase(raw);
    }
  }

  /// Localized display name for a stored project/book type.
  static String localizedLabel(BuildContext context, String? type) {
    switch (_key(type)) {
      case 'memoir':
      case 'biography':
      case 'autobiography':
      case 'life_story':
        return context.l10n.categoryMemoir;
      case 'travel':
      case 'tourism':
      case 'tourism_exploration':
        return context.l10n.categoryTravel;
      case 'military':
      case 'geopolitics':
      case 'military_geopolitics':
        return context.l10n.categoryMilitary;
      case 'history':
      case 'culture':
      case 'cultural_heritage':
      case 'non_fiction':
        return context.l10n.categoryHeritage;
      case 'philosophy':
      case 'mindfulness':
      case 'spiritual':
      case 'philosophy_mindfulness':
        return context.l10n.categoryPhilosophy;
      case 'business':
      case 'leadership':
      case 'business_leadership':
        return context.l10n.categoryBusiness;
      case 'fiction':
      case 'stories':
      case 'novel':
      case 'memoir_stories':
        return context.l10n.categoryFiction;
      default:
        final String raw = (type ?? '').trim();
        return raw.isEmpty ? context.l10n.categoryBook : _titleCase(raw);
    }
  }

  /// Localizes a canonical label returned by [label].
  static String localizeCanonicalLabel(BuildContext context, String label) {
    switch (label) {
      case 'Memoir / Autobiography':
        return context.l10n.categoryMemoir;
      case 'Tourism & Exploration':
        return context.l10n.categoryTravel;
      case 'Military & Geopolitics':
        return context.l10n.categoryMilitary;
      case 'Non-Fiction / Cultural Heritage':
        return context.l10n.categoryHeritage;
      case 'Philosophy & Mindfulness':
        return context.l10n.categoryPhilosophy;
      case 'Business & Leadership':
        return context.l10n.categoryBusiness;
      case 'Fiction & Stories':
        return context.l10n.categoryFiction;
      case fallbackLabel:
        return context.l10n.categoryBook;
      default:
        return label;
    }
  }

  /// Accent colour for the same shelf.
  static Color color(String? type) {
    switch (_key(type)) {
      case 'memoir':
      case 'biography':
      case 'autobiography':
      case 'life_story':
        return _memoir;
      case 'travel':
      case 'tourism':
      case 'tourism_exploration':
        return _travel;
      case 'military':
      case 'geopolitics':
      case 'military_geopolitics':
        return _military;
      case 'history':
      case 'culture':
      case 'cultural_heritage':
      case 'non_fiction':
        return _heritage;
      case 'philosophy':
      case 'mindfulness':
      case 'spiritual':
      case 'philosophy_mindfulness':
        return _philosophy;
      case 'business':
      case 'leadership':
      case 'business_leadership':
        return _business;
      case 'fiction':
      case 'stories':
      case 'novel':
      case 'memoir_stories':
        return _stories;
      default:
        return _general;
    }
  }

  /// `biography`, `Mountain History`, `cultural-heritage` → `cultural_heritage`.
  static String _key(String? type) =>
      (type ?? '').trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');

  static String _titleCase(String raw) {
    final List<String> words = raw.replaceAll('_', ' ').split(' ');
    return words
        .map((String word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

/// Small tinted pill naming the shelf a project sits on.
class ProjectCategoryChip extends StatelessWidget {
  const ProjectCategoryChip({super.key, required this.type, this.dense = false});

  final String? type;

  /// Tighter padding, for use inside a dense list row.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final Color color = ProjectCategory.color(type);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        ProjectCategory.localizedLabel(context, type),
        style: TextStyle(
          fontSize: dense ? 13 : 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
