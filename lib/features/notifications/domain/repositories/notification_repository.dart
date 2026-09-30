import 'package:lekhan_ai/shared/domain/models/paginated_response_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';
import '../models/notification_model.dart';
import '../usecases/get_notifications_usecase.dart';

abstract class INotificationRepository {
  Future<Either<AppException, PaginationResponseModel<NotificationModel>>>
      getNotifications({
    required GetNotificationsParams params,
  });

  Future<Either<AppException, String>> markAsRead(String notificationId);
  Future<Either<AppException, String>> allowNotification();
}
