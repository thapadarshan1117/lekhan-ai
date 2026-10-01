part of 'pdf_viewer_cubit.dart';

@freezed
class PdfViewerState with _$PdfViewerState {
  const factory PdfViewerState.initial() = _Initial;

  const factory PdfViewerState.loading() = _Loading;

  const factory PdfViewerState.loaded({
    required int totalPages,
    required int currentPage,
  }) = _Loaded;

  const factory PdfViewerState.error(String message) = _Error;
}
