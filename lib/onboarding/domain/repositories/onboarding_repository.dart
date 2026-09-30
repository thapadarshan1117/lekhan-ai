import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

abstract class OnboardingRepository {
  Future<Either<AppException, bool>> isOnboard();
  Future<Either<AppException, bool>> setOnboardStatus();
}
