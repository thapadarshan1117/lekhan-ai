import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/shared/data/local/storage_service.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';


abstract class OnboardDatasource {
  String get storageKey;
  Future<Either<AppException, bool>> isOnboard();
  Future<Either<AppException, bool>> setOnboardStatus();
}

class OnboardDatasourceImpl implements OnboardDatasource {
  final StorageService storageService;

  OnboardDatasourceImpl({required this.storageService});

  @override
  String get storageKey => 'sahara_app_onboard_key';

  @override
  Future<Either<AppException, bool>> isOnboard() async {
    try {
      final data = await storageService.has(storageKey);
      return Right(data);
    } catch (e) {
      return Left(
        AppException(
          message: "Error while getting onboard status",
          statusCode: 1,
          identifier: 'At OnboardDatasourceImpl.isOnboard',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> setOnboardStatus() async {
    try {
      final result = await storageService.set(storageKey, "true");
      return Right(result);
    } catch (e) {
      return Left(
        AppException(
          message: "Error while setting onboard status",
          statusCode: 1,
          identifier: 'At OnboardDatasourceImpl.setOnboardStatus',
        ),
      );
    }
  }
}
