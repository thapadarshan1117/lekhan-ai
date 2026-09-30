import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/globals.dart';


abstract class RememberMeDataSource {
  String get storageKey;

  Future<Either<AppException, String>> getEmail();
  Future<Either<AppException, String>> setRememberMe({required String data});
  Future<Either<AppException, bool>> deleteEmail();
}

class RememberMeDatasourceImpl implements RememberMeDataSource {
  final StorageService storageService;

  RememberMeDatasourceImpl({required this.storageService});

  @override
  String get storageKey => rememberMeKey;

  @override
  Future<Either<AppException, bool>> deleteEmail() async {
    try {
      final hasEmail = await storageService.has(storageKey);
      if (hasEmail) {
        final result = await storageService.remove(storageKey);
        return Right(result);
      } else {
        return const Right(true);
      }
    } catch (e) {
      return Left(
        AppException(
          message: "Error while deleting email",
          statusCode: 1,
          identifier: 'At RememberMeDatasourceImpl.deleteEmail',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, String>> getEmail() async {
    try {
      final hasEmail = await storageService.has(storageKey);
      if (!hasEmail) {
        return const Right('');
      }
      final data = await storageService.get(storageKey);
      return Right(data.toString());
    } catch (e) {
      return Left(
        AppException(
          message: "Error while getting email",
          statusCode: 1,
          identifier: 'At RememberMeDatasourceImpl.getEmail',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, String>> setRememberMe(
      {required String data}) async {
    try {
      final result = await storageService.set(storageKey, data);
      if (result == true) {
        return const Right('Set Successful');
      } else {
        return Left(
          AppException(
            message: "Error while saving user",
            statusCode: 1,
            identifier: 'At UserLocalDatasourceImpl.saveUser',
          ),
        );
      }
    } catch (e) {
      return Left(
        AppException(
          message: "Error while saving email",
          statusCode: 1,
          identifier: 'At RememberMeDatasourceImpl.setRememberMe',
        ),
      );
    }
  }
}
