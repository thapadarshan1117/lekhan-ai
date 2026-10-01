import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfx/pdfx.dart';
import 'package:lekhan_ai/core/theme/app_color.dart';
import 'package:lekhan_ai/features/source_content/domain/entities/chapter_source.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/load_pdf_usecase.dart';
import 'package:lekhan_ai/features/source_content/presentation/bloc/pdf_viewer_bloc/pdf_viewer_cubit.dart';
import 'package:lekhan_ai/features/source_content/presentation/widgets/pdf_navigation_controls.dart';


class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({
    super.key,
    required this.source,
  });

  final ChapterSource source;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PdfViewerCubit>(
      create: (BuildContext context) => PdfViewerCubit(
        loadPdfUsecase: const LoadPdfUsecase(),
      )..loadPdf(source.localPath),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  /// App bar showing PDF name and file size.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            source.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${(source.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the PDF body based on the Cubit's current state.
  Widget _buildBody() {
    return BlocBuilder<PdfViewerCubit, PdfViewerState>(
      builder: (
        BuildContext context,
        PdfViewerState state,
      ) {
        return state.maybeWhen(
          loading: _buildLoadingState,

          error: (String message) {
            return _buildErrorState(message);
          },

          loaded: (
            int totalPages,
            int currentPage,
          ) {
            final PdfControllerPinch? controller =
                context.read<PdfViewerCubit>().controller;

            if (controller == null) {
              return _buildErrorState(
                'PDF controller not initialized.',
              );
            }

            return _buildLoadedState(controller);
          },

          orElse: _buildLoadingState,
        );
      },
    );
  }

  /// Loading state.
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primary,
        ),
      ),
    );
  }

  /// Error state.
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Loaded PDF viewer.
  Widget _buildLoadedState(
    PdfControllerPinch controller,
  ) {
    return Column(
      children: <Widget>[
        Expanded(
          child: PdfViewPinch(
            controller: controller,

            builders: PdfViewPinchBuilders(
              /// Required by the current pdfx API.
              options: const DefaultBuilderOptions(),

              /// Shown while the PDF document is loading.
              documentLoaderBuilder: (
                BuildContext context,
              ) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                );
              },

              /// Shown while an individual page is loading.
              pageLoaderBuilder: (
                BuildContext context,
              ) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                );
              },

              /// Shown if a page/document rendering error occurs.
              errorBuilder: (
                BuildContext context,
                Exception error,
              ) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 56,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to display this PDF page.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        /// Page navigation controls.
        const PdfNavigationControls(),
      ],
    );
  }
}