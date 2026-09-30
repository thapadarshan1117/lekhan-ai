import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';

abstract class UserRemoteRepository {
  Future<Either<AppException, User>> getUserFromRemote();
}
