import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:lekhan_ai/shared/data/local/fcm_token_service.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/paginated_response_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';

import '../../domain/models/notification_model.dart';

abstract class INotificationDatasource {
  Future<Either<AppException, PaginationResponseModel<NotificationModel>>>
      getNotifications({
    required GetNotificationsParams params,
  });
  Future<Either<AppException, String>> markAsRead(String notificationId);
  Future<Either<AppException, String>> allowNotification();
}

class NotificationDatasourceImpl implements INotificationDatasource {
  const NotificationDatasourceImpl(
      {NetworkService? networkService, FCMTokenService? fcmTokenService});

  @override
  Future<Either<AppException, PaginationResponseModel<NotificationModel>>>
      getNotifications({
    required GetNotificationsParams params,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      return Right(PaginationResponseModel<NotificationModel>(
        totalItems: 0,
        totalPages: 1,
        currentPage: 1,
        pageSize: 10,
        results: [],
      ));
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to fetch notifications',
          statusCode: 500,
          identifier: 'NotificationDatasourceImpl.getNotifications',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, String>> markAsRead(String notificationId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      return const Right('Notification marked as read');
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to mark notification as read',
          statusCode: 500,
          identifier: 'NotificationDatasourceImpl.markAsRead',
        ),
      );
    }
  }

  @override
  Future<Either<AppException, String>> allowNotification() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));

      return const Right('Notification permission granted');
    } catch (e) {
      return Left(
        AppException(
          message: "Error while allowing notification",
          statusCode: 1,
          identifier: "${e.toString()}\nNotificationDatasourceImpl.allowNotification",
        ),
      );
    }
  }
}
