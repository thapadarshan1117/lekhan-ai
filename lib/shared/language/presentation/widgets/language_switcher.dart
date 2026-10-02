import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/l10n/l10n.dart';
import 'package:lekhan_ai/shared/language/domain/model/language_model.dart';
import 'package:lekhan_ai/shared/language/presentation/language_bloc/language_bloc.dart';

/// A large, plain-language control for switching between English and Nepali.
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      buildWhen: (LanguageState previous, LanguageState current) =>
          previous.selectedLanguage != current.selectedLanguage,
      builder: (BuildContext context, LanguageState state) {
        final String selectedLabel = state.selectedLanguage == Language.nepali
            ? context.l10n.nepali
            : context.l10n.english;

        return Semantics(
          button: true,
          label: '${context.l10n.changeLanguage}: $selectedLabel',
          child: PopupMenuButton<Language>(
            tooltip: context.l10n.changeLanguage,
            constraints: const BoxConstraints(minWidth: 190),
            onSelected: (Language language) => context
                .read<LanguageBloc>()
                .add(ChangeLanguage(selectedLanguage: language)),
            itemBuilder: (BuildContext menuContext) => <PopupMenuEntry<Language>>[
              _languageItem(
                language: Language.english,
                label: menuContext.l10n.english,
                selected: state.selectedLanguage == Language.english,
              ),
              _languageItem(
                language: Language.nepali,
                label: menuContext.l10n.nepali,
                selected: state.selectedLanguage == Language.nepali,
              ),
            ],
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.language_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedLabel,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static PopupMenuItem<Language> _languageItem({
    required Language language,
    required String label,
    required bool selected,
  }) {
    return PopupMenuItem<Language>(
      value: language,
      height: 58,
      child: Row(
        children: <Widget>[
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
