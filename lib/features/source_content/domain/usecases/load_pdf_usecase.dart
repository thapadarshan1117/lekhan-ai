import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:pdfx/pdfx.dart';
import 'package:lekhan_ai/core/error/exception_types.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

/// Parameters for loading a PDF document.
class LoadPdfParams {
  const LoadPdfParams({required this.localPath});

  final String localPath;
}

/// Load PDF document by file path from local storage.
///
/// Validates:
/// - File exists
/// - File is accessible
/// - PDF can be opened by pdfx renderer
///
/// Returns `Either<AppException, PdfDocument>` following the error handling pattern.
/// Failures are wrapped as AppException with appropriate status codes.
class LoadPdfUsecase {
  const LoadPdfUsecase();

  /// Execute the usecase.
  ///
  /// Returns:
  /// - Right(PdfDocument) on success
  /// - Left(AppException) on failure with appropriate error code
  Future<Either<AppException, PdfDocument>> call(LoadPdfParams params) async {
    try {
      final File pdfFile = File(params.localPath);

      // Check if file exists
      if (!pdfFile.existsSync()) {
        return Left<AppException, PdfDocument>(
          AppException(
            message: 'PDF file not found on device.',
            statusCode: LocalErrorCodes.notFound,
            identifier: 'pdf_not_found',
          ),
        );
      }

      // Check if file is readable
      final bool accessible = await pdfFile.exists();
      if (!accessible) {
        return Left<AppException, PdfDocument>(
          AppException(
            message: 'PDF file is not accessible. Check permissions.',
            statusCode: LocalErrorCodes.permissionDenied,
            identifier: 'pdf_permission_denied',
          ),
        );
      }

      // Attempt to open PDF document
      final PdfDocument document =
          await PdfDocument.openFile(params.localPath);

      return Right<AppException, PdfDocument>(document);
    } catch (e) {
      return Left<AppException, PdfDocument>(
        AppException(
          message: 'An unexpected error occurred while loading the PDF.',
          statusCode: LocalErrorCodes.localFailure,
          identifier: 'pdf_load_error',
          data: {'error': e.toString()},
        ),
      );
    }
  }
}
