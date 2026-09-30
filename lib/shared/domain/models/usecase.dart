import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

abstract class UsecaseWithParam<Type, Params> {
  Future<Either<AppException, Type>> call(Params params);
}

abstract class Usecase<Type> {
  Future<Either<AppException, Type>> call();
}
 