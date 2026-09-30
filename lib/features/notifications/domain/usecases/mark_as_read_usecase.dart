import 'package:lekhan_ai/shared/domain/models/usecase.dart';
import 'package:lekhan_ai/shared/exceptions/http_exception.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/notification_repository.dart';

class MarkAsReadUsecase implements UsecaseWithParam<String, MarkAsReadParams> {
  final INotificationRepository repository;

  const MarkAsReadUsecase(this.repository);

  @override
  Future<Either<AppException, String>> call(MarkAsReadParams params) {
    return repository.markAsRead(params.notificationId);
  }
}

class MarkAsReadParams extends Equatable {
  final String notificationId;

  const MarkAsReadParams({
    required this.notificationId,
  });

  Map<String, dynamic> toJson() => {
        'notification': notificationId,
      };

  @override
  List<Object?> get props => [notificationId];
}
