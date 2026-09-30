import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

class RegisterUsecase extends UsecaseWithParam<String, RegisterParams> {
  final AuthRepository authRepository;

  RegisterUsecase({required this.authRepository});

  @override
  Future<Either<AppException, String>> call(RegisterParams params) async {
    return await authRepository.register(
      fullName: params.fullName,
      userType: params.userType,
      email: params.email,
      phone: params.phone,
      password: params.password,
    );
  }
}

class RegisterParams {
  final String fullName;
  final String userType;
  final String email;
  final String phone;
  final String password;

  RegisterParams({
    required this.fullName,
    required this.userType,
    required this.email,
    required this.phone,
    required this.password,
  });
}
