import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';


class LogoutUsecase extends Usecase<String> {
  final AuthRepository authRepository;

  LogoutUsecase({required this.authRepository});

  @override
  Future<Either<AppException, String>> call() async {
    return await authRepository.logout();
  }
}
