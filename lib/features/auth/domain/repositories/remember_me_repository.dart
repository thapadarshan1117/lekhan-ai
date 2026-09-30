import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

abstract class RememberMeRepository {
  Future<Either<AppException, String>> getEmail();
  Future<Either<AppException, String>> setEmail({required String email});
  Future<Either<AppException, bool>> deleteEmail();
}
