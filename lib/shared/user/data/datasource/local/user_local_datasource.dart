import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/globals.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';




abstract class UserLocalDataSource {
  String get storageKey;

  Future<Either<AppException, User>> getUser();
  Future<Either<AppException, String>> saveUser({required User user});
  Future<Either<AppException, bool>> hasUser();
  Future<Either<AppException, bool>> deleteUser();
}

class UserLocalDatasourceImpl implements UserLocalDataSource {
  final StorageService storageService;

  UserLocalDatasourceImpl({required this.storageService});

  @override
  String get storageKey => userLocalDataSourceKey;

  @override
  Future<Either<AppException, bool>> deleteUser() async {
    try {
      final result = await storageService.remove(storageKey);
      return Right(result);
    } catch (e) {
      return Left(
        AppException(
          message: "Error while deleting user",
          statusCode: 1,
          identifier: 'At UserLocalDatasourceImpl.deleteUser',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, User>> getUser() async {
    try {
      final data = await storageService.get(storageKey);
      if (data == null) {
        return Left(
          AppException(
            message: 'User not found',
            statusCode: 404,
            identifier: 'UserLocalDataSource',
          ),
        );
      }
      final userJson = jsonDecode(data.toString());
      final user = User.fromJson(userJson);

      print("User retrieved from local storage: ${user.toJson()}");
      return Right(user);
    } catch (e) {
      return Left(
        AppException(
          message: "Error while getting user",
          statusCode: 1,
          identifier: 'At UserLocalDatasourceImpl.getUser',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> hasUser() async {
    try {
      final result = await storageService.has(storageKey);
      return Right(result);
    } catch (e) {
      return Left(
        AppException(
          message: "Error while checking user",
          statusCode: 1,
          identifier: 'At UserLocalDatasourceImpl.hasUser',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, String>> saveUser({required User user}) async {
    try {
      final userJson = user.toJson();
      final result = await storageService.set(storageKey, jsonEncode(userJson));
      if (result == true) {
        print("User saved to local storage: ${user.toJson()}");
        return const Right('User saved successfully');
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
          message: "Error while saving user",
          statusCode: 1,
          identifier: 'At UserLocalDatasourceImpl.saveUser',
        ),
      );
    }
  }
}
