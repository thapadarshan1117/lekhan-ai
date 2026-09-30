import 'package:lekhan_ai/features/notifications/domain/models/notification_model.dart';
import 'package:lekhan_ai/features/notifications/domain/repositories/notification_repository.dart';
import 'package:lekhan_ai/shared/domain/models/paginated_response_model.dart';
import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:fpdart/fpdart.dart';

class GetNotificationsUsecase
    implements
        UsecaseWithParam<PaginationResponseModel<NotificationModel>,
            GetNotificationsParams> {
  final INotificationRepository repository;

  GetNotificationsUsecase({required this.repository});

  @override
  Future<Either<AppException, PaginationResponseModel<NotificationModel>>> call(
      GetNotificationsParams params) {
    return repository.getNotifications(params: params);
  }
}

class GetNotificationsParams {
  final int page;
  final int pageSize;
  final String? filter;

  GetNotificationsParams({
    required this.page,
    required this.pageSize,
    this.filter,
  });
}
