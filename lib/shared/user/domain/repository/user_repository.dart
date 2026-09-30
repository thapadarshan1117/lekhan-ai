import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';


abstract class UserRepository {
  Future<Either<AppException, User>> getUser();
  Future<Either<AppException, String>> saveUser({required User user});
  Future<Either<AppException, bool>> hasUser();
  Future<Either<AppException, bool>> deleteUser();
}
