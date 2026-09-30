import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

abstract class AccountRepository {
  Future<Either<AppException, String>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
  Future<Either<AppException, String>> logout();
}