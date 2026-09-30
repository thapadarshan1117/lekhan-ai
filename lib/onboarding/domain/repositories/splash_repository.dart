import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

enum SplashDecision {
  authenticated,
  unauthenticated,
  needsOnboarding,
  firstLaunch,
}

abstract class SplashRepository {
  Future<Either<AppException, SplashDecision>> checkStatus();
}
