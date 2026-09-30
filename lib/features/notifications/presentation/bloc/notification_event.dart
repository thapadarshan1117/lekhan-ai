part of 'notification_bloc.dart';

@freezed
class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.getNotifications({
    String? filter,
    @Default(1) int page,
    @Default(false) bool isRefresh,
  }) = _GetNotifications;

  const factory NotificationEvent.loadMoreNotifications({
    required String filter,
    required int page,
  }) = _LoadMoreNotifications;

  const factory NotificationEvent.markAsRead(String notificationId) = _MarkAsRead;
}