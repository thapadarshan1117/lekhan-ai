import 'dart:developer';

import 'package:lekhan_ai/core/config/api/api_configs.dart';
import 'package:lekhan_ai/core/enums/notification_status_enum.dart';
import 'package:lekhan_ai/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:lekhan_ai/shared/data/local/fcm_token_service.dart';
import 'package:lekhan_ai/shared/data/remote/network_service.dart';
import 'package:lekhan_ai/shared/domain/models/paginated_response_model.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

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
  final NetworkService networkService;
  final FCMTokenService fcmTokenService;

  const NotificationDatasourceImpl(
      {required this.networkService, required this.fcmTokenService});

  @override
  Future<Either<AppException, PaginationResponseModel<NotificationModel>>>
      getNotifications({
    required GetNotificationsParams params,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'p': params.page.toString(),
        'page_size': params.pageSize.toString(),
      };

      if (params.filter != null && params.filter?.toLowerCase() != 'all') {
        queryParams['status'] = params.filter?.toLowerCase() == 'unread'
            ? NotificationStatus.unread.toApiString()
            : NotificationStatus.read.toApiString();
      }

      final response = await networkService.get(
        ApiConfigs.notifications,
        queryParameters: queryParams,
      );

      return response.fold(
        (exception) {
          return Left(exception);
        },
        (result) {
          log(result.data.toString());
          try {
            if (result.data != null) {
              return Right(
                PaginationResponseModel.fromJson(
                  result.data,
                  (item) => NotificationModel.fromJson(item),
                ),
              );
            } else {
              return Right(PaginationResponseModel<NotificationModel>(
                totalItems: 0,
                totalPages: 1,
                currentPage: 1,
                pageSize: 10,
                results: [],
              ));
            }
          } catch (e) {
            return Left(
              AppException(
                message: 'Failed to parse notifications',
                statusCode: 422,
                identifier: 'NotificationDatasourceImpl.getNotifications.parse',
              ),
            );
          }
        },
      );
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
      final response = await networkService.patch(
        '${ApiConfigs.notifications}/$notificationId/read',
      );

      return response.fold(
        (exception) => Left(exception),
        (result) => const Right('Notification marked as read'),
      );
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
    log('Allowing notification - NotificationDataSourceImpl.allowNotification');
    try {
      // Ensure we have (or create) a valid device token even if permission was denied initially
      final token = await fcmTokenService.getOrCreateToken();
      if (token == null || token.isEmpty) {
        log('No valid device token found');
        return Left(
          AppException(
            message:
                'Unable to obtain device token. Retry after enabling notifications.',
            statusCode: 1,
            identifier:
                'NotificationDataSourceImpl.allowNotification.tokenNull',
          ),
        );
      }
      final response = await networkService.put(
        ApiConfigs.saveDeviceToken,
        data: {"deviceToken": token},
      );

      log('Device token sent to server: $token');
      return response.fold(
        (exception) => Left(exception),
        (result) => const Right('Notification permission granted'),
      );
    } catch (e) {
      log('Error while allowing notification: $e');
      return Left(
        AppException(
          message: "Error while allowing notification",
          statusCode: 1,
          identifier:
              "${e.toString()}\nNotificationDataSourceImpl.allowNotification",
        ),
      );
    }
  }
}
