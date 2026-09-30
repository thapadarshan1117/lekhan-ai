import 'package:lekhan_ai/features/notifications/data/datasources/notification_datasource.dart';
import 'package:lekhan_ai/features/notifications/domain/models/notification_model.dart';
import 'package:lekhan_ai/features/notifications/domain/repositories/notification_repository.dart';
import 'package:lekhan_ai/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:lekhan_ai/shared/domain/models/paginated_response_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final INotificationDatasource notificationDatasource;

  NotificationRepositoryImpl({
    required this.notificationDatasource,
  });

  @override
  Future<Either<AppException, PaginationResponseModel<NotificationModel>>>
      getNotifications({
    required GetNotificationsParams params,
  }) async {
    return await notificationDatasource.getNotifications(
      params: params,
    );
  }

  @override
  Future<Either<AppException, String>> markAsRead(String notificationId) async {
    return await notificationDatasource.markAsRead(notificationId);
  }

  @override
  Future<Either<AppException, String>> allowNotification() {
    return notificationDatasource.allowNotification();
  }
}
