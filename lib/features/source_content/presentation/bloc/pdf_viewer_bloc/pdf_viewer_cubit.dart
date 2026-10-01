import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdfx/pdfx.dart';
import 'package:lekhan_ai/features/source_content/domain/usecases/load_pdf_usecase.dart';

part 'pdf_viewer_state.dart';
part 'pdf_viewer_cubit.freezed.dart';

/// Manages PDF document lifecycle: loading, navigation, and page tracking.
/// 
/// Responsibilities:
/// - Load PDF documents via usecase (domain layer)
/// - Track current page and total pages
/// - Expose controller to view layer for rendering
/// - Handle errors as AppException via Either
class PdfViewerCubit extends Cubit<PdfViewerState> {
  PdfViewerCubit({required this.loadPdfUsecase})
      : super(const PdfViewerState.initial());

  final LoadPdfUsecase loadPdfUsecase;

  PdfControllerPinch? _controller;

  /// The PDF controller for rendering. Null until loaded.
  PdfControllerPinch? get controller => _controller;

  /// Load a PDF document by its local file path.
  /// 
  /// Flow:
  /// 1. Emit loading state
  /// 2. Call usecase with path (handles `Either<AppException, T>`)
  /// 3. On success: create controller, emit loaded state
  /// 4. On failure: emit error state with message
  Future<void> loadPdf(String localPath) async {
    emit(const PdfViewerState.loading());

    final result = await loadPdfUsecase(LoadPdfParams(localPath: localPath));

    result.fold(
      (exception) {
        emit(PdfViewerState.error(exception.message));
      },
      (document) {
        _controller = PdfControllerPinch(document: Future.value(document));
        emit(PdfViewerState.loaded(
          totalPages: document.pagesCount,
          currentPage: 1,
        ));
      },
    );
  }

  /// Move to next page if available.
  void nextPage(int currentPage, int totalPages) {
    if (currentPage < totalPages) {
      emit(PdfViewerState.loaded(
        totalPages: totalPages,
        currentPage: currentPage + 1,
      ));
    }
  }

  /// Move to previous page if available.
  void previousPage(int currentPage, int totalPages) {
    if (currentPage > 1) {
      emit(PdfViewerState.loaded(
        totalPages: totalPages,
        currentPage: currentPage - 1,
      ));
    }
  }

  /// Jump to specific page.
  void goToPage(int page, int totalPages) {
    if (page >= 1 && page <= totalPages) {
      emit(PdfViewerState.loaded(
        totalPages: totalPages,
        currentPage: page,
      ));
    }
  }

  @override
  Future<void> close() async {
    _controller?.dispose();
    _controller = null;
    return super.close();
  }
}
