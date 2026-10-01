import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/source_content/presentation/bloc/pdf_viewer_bloc/pdf_viewer_cubit.dart';

/// Reusable PDF navigation controls: page buttons, counter, and slider.
///
/// Displays:
/// - Previous/Next page buttons
/// - Current page indicator
/// - Page slider for quick navigation
///
/// Reads from PdfViewerCubit to access current page and total pages.
class PdfNavigationControls extends StatelessWidget {
  const PdfNavigationControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfViewerCubit, PdfViewerState>(
      builder: (BuildContext context, PdfViewerState state) {
        return state.maybeWhen(
          loaded: (int totalPages, int currentPage) {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: <Widget>[
                  _buildPageControls(
                    context: context,
                    currentPage: currentPage,
                    totalPages: totalPages,
                  ),
                  _buildPageSlider(
                    context: context,
                    currentPage: currentPage,
                    totalPages: totalPages,
                  ),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  /// Previous/Next buttons and page counter row.
  Widget _buildPageControls({
    required BuildContext context,
    required int currentPage,
    required int totalPages,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: currentPage > 1
              ? () => context.read<PdfViewerCubit>().previousPage(
                    currentPage,
                    totalPages,
                  )
              : null,
          icon: const Icon(Icons.chevron_left),
          color: AppColors.primary,
          disabledColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        Text(
          'Page $currentPage of $totalPages',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: currentPage < totalPages
              ? () => context.read<PdfViewerCubit>().nextPage(
                    currentPage,
                    totalPages,
                  )
              : null,
          icon: const Icon(Icons.chevron_right),
          color: AppColors.primary,
          disabledColor: AppColors.primary.withValues(alpha: 0.4),
        ),
      ],
    );
  }

  /// Interactive page slider for quick navigation.
  Widget _buildPageSlider({
    required BuildContext context,
    required int currentPage,
    required int totalPages,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 8,
          ),
        ),
        child: Slider(
          value: currentPage.toDouble(),
          min: 1,
          max: totalPages.toDouble(),
          divisions: totalPages > 1 ? totalPages - 1 : 1,
          onChanged: (double value) {
            context.read<PdfViewerCubit>().goToPage(
              value.toInt(),
              totalPages,
            );
          },
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
