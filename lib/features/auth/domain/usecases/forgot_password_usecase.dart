import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
class ForgotPasswordUsecase
    extends UsecaseWithParam<Map<String, dynamic>, String> {
  final AuthRepository authRepository;

  ForgotPasswordUsecase(this.authRepository);

  @override
  Future<Either<AppException, Map<String, dynamic>>> call(String params) async {
    return await authRepository.forgotPassword(email: params);
  }
}
