import 'package:fpdart/fpdart.dart';

import 'package:lekhan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';

import '../../../../shared/exceptions/http_exception.dart';

class LoginUsecase extends UsecaseWithParam<String, LoginParams> {
  final AuthRepository authRepository;

  LoginUsecase({required this.authRepository});
  @override
  Future<Either<AppException, String>> call(params) async {
    return await authRepository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
