import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/config/api/api_configs.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_repository.dart';

abstract class UserRemoteDatasource {
  Future<Either<AppException, User>> getUser();
}

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  final NetworkService networkService;
  final UserRepository userRepository;

  UserRemoteDatasourceImpl(
      {required this.networkService, required this.userRepository});

  @override
  Future<Either<AppException, User>> getUser() async {
    try {
      final response = await networkService.get(
        ApiConfigs.authProfile,
      );

      return response.fold(
        (exception) async {
          debugPrint(
            'UserRemoteDatasourceImpl.getUser: Error occurred while fetching user data: ${exception.statusCode}',
          );
          if (exception.statusCode == 1) {
            final localUserEither = await userRepository.getUser();
            return localUserEither.fold(
              (l) => Left(AppException(
                  identifier: 'userDataSource.getUser',
                  message: "Local doesn't contain data",
                  statusCode: 1)),
              (user) {
                debugPrint(
                  'UserRemoteDatasourceImpl.getUser: Fallback to local user data',
                );
                return Right(user);
              },
            );
          }
          return Left(exception);
        },
        (result) async {
          debugPrint('UserRemoteDatasource: Received API response: ${result.data}');
          final dynamic root = result.data;
          final dynamic dataNode =
              root is Map<String, dynamic> ? root['data'] : null;

          if (dataNode == null || dataNode is! Map<String, dynamic>) {
            debugPrint('UserRemoteDatasource: dataNode is null or not a Map: $dataNode');
            return Left(
              AppException(
                message: 'User data not found',
                statusCode: 404,
                identifier: 'userDataSourceImpl.getUser',
              ),
            );
          }

          // The user data is directly in the 'data' node
          final Map<String, dynamic> userJson = Map<String, dynamic>.from(dataNode);
          debugPrint('UserRemoteDatasource: Parsed userJson: $userJson');

          final user = User.fromJson(userJson);
          debugPrint('UserRemoteDatasource: Created user object: ${user.toJson()}');
          
          final saveResult = await userRepository.saveUser(user: user);
          saveResult.fold(
            (error) => debugPrint('UserRemoteDatasource: Failed to save user: ${error.message}'),
            (success) => debugPrint('UserRemoteDatasource: User saved successfully: $success'),
          );
          
          return Right(user);
        },
      );
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to get user details',
          statusCode: 1,
          identifier: 'userDataSourceImpl.getuserById',
        ),
      );
    }
  }
}
