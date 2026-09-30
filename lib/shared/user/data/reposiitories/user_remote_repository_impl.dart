import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/user/data/datasource/remote/user_remote_datasource.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_remote_repository.dart';



class UserRemoteRepositoryImpl implements UserRemoteRepository {
  final UserRemoteDatasource userRemoteDataSource;

  UserRemoteRepositoryImpl(this.userRemoteDataSource);

  @override
  Future<Either<AppException, User>> getUserFromRemote() async {
    return await userRemoteDataSource.getUser();
  }
}
