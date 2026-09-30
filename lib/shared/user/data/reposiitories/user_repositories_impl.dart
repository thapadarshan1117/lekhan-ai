
import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/user/data/datasource/local/user_local_datasource.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_repository.dart';



class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource userDataSource;

  UserRepositoryImpl(this.userDataSource);

  @override
  Future<Either<AppException, bool>> deleteUser() async {
    return await userDataSource.deleteUser();
  }

  @override
  Future<Either<AppException, User>> getUser() async {

    return await userDataSource.getUser();
  }

  @override
  Future<Either<AppException, bool>> hasUser() async {
    return await userDataSource.hasUser();
  }

  @override
  Future<Either<AppException, String>> saveUser({required User user}) async {
   
    return await userDataSource.saveUser(user: user);
  }
}
