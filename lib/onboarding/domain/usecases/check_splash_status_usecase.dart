import 'package:lekhan_ai/onboarding/domain/repositories/splash_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

class CheckSplashStatusUsecase implements Usecase<SplashDecision> {
  final SplashRepository splashRepository;

  CheckSplashStatusUsecase({required this.splashRepository});

  @override
  Future<Either<AppException, SplashDecision>> call() {
    return splashRepository.checkStatus();
  }
}
