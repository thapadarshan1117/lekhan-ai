
import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_remote_repository.dart';


class GetRemoteUserUsecase extends Usecase<User > {
  final UserRemoteRepository repository;

  GetRemoteUserUsecase(this.repository);

  @override
  Future<Either<AppException, User>> call( ) async {
    return await repository.getUserFromRemote(
   
    );
  }
}

