import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:lekhan_ai/shared/user/domain/model/user.dart';
import 'package:lekhan_ai/shared/user/domain/repository/user_repository.dart';

abstract class UserRemoteDatasource {
  Future<Either<AppException, User>> getUser();
}

class UserRemoteDatasourceImpl implements UserRemoteDatasource {
  const UserRemoteDatasourceImpl({
    NetworkService? networkService,
    UserRepository? userRepository,
  });

  @override
  Future<Either<AppException, User>> getUser() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Return a mock user
      final mockUser = User(
        userId: 'mock_user_123',
        name: 'Mock User',
        email: 'mock@example.com',
        phone: '+1234567890',
        profileImage: null,
        isActive: true,
        whatsapp: null,
        role: 'user',
        branch: null,
        country: null,
        timezone: null,
        isTeamMember: false,
      );

      return Right(mockUser);
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to get user details',
          statusCode: 1,
          identifier: 'userDataSourceImpl.getUser',
        ),
      );
    }
  }
}
