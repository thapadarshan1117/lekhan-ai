import 'package:lekhan_ai/features/notifications/domain/repositories/notification_repository.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class AllowNotificationUseCase extends Usecase<String> {
  final INotificationRepository repository;

  AllowNotificationUseCase(this.repository);

  @override
  Future<Either<AppException, String>> call([void params]) {
    // delegates to repository/datasource to send device token
    return repository.allowNotification();
  }
}
