import 'package:lekhan_ai/core/enums/notification_status_enum.dart';

import '../../domain/models/notification_model.dart';

class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final String notificationType;
  final String? imageUrl;
  final bool sent;
  final bool isSeen;
  final NotificationStatus status; // Add status field from API
  final String user; // Add user field from API
  final Map<String, dynamic>?
      contentData; // Optional expanded content for system notifications
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    this.imageUrl,
    required this.sent,
    required this.isSeen,
    required this.status,
    required this.user,
    this.contentData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    try {
      final statusString = json['status'] as String? ?? 'Unread';
      final notificationStatus = NotificationStatus.fromString(statusString);
      return NotificationEntity(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        notificationType: json['notification_type'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        sent: json['sent'] as bool? ?? false,
        isSeen: notificationStatus.isRead,
        status: notificationStatus,
        user: json['user'] as String? ?? '',
        contentData: json['content_data'] as Map<String, dynamic>?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      // ignore: avoid_print
      return NotificationEntity(
        id: '',
        title: 'Error',
        message: 'Failed to load notification',
        notificationType: 'error',
        sent: false,
        isSeen: false,
        status: NotificationStatus.unread,
        user: '',
        contentData: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  NotificationModel toDomain() {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      notificationType: notificationType,
      imageUrl: imageUrl,
      sent: sent,
      isSeen: isSeen,
      status: status,
      // user: user,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'notification_type': notificationType,
        'image_url': imageUrl,
        'sent': sent,
        'status': status.toApiString(),
        'user': user,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    String? notificationType,
    String? imageUrl,
    bool? sent,
    bool? isSeen,
    NotificationStatus? status,
    String? user,
    Map<String, dynamic>? contentData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      imageUrl: imageUrl ?? this.imageUrl,
      sent: sent ?? this.sent,
      isSeen: isSeen ?? this.isSeen,
      status: status ??
          (isSeen != null
              ? (isSeen ? NotificationStatus.read : NotificationStatus.unread)
              : this.status),
      user: user ?? this.user,
      contentData: contentData ?? this.contentData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
