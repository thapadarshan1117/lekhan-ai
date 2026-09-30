import 'package:equatable/equatable.dart';
import 'package:lekhan_ai/core/enums/notification_status_enum.dart';

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final String notificationType;
  final String? imageUrl;
  final String? contentId;
  final bool sent;
  final bool isSeen;
  final NotificationStatus status; // Add status field from API
  // final String user; // Add user field from API
  final Map<String, dynamic>?
      contentData; // Optional expanded content for system notifications
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    this.imageUrl,
    this.contentId,
    required this.sent,
    required this.isSeen,
    required this.status,
    // required this.user,
    this.contentData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      final statusString = json['status'] as String? ?? 'Unread';
      final notificationStatus = NotificationStatus.fromString(statusString);
      return NotificationModel(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        notificationType: json['notification_type'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        contentId: json['content_id'] as String?,
        sent: json['sent'] as bool? ?? false,
        isSeen: notificationStatus.isRead,
        status: notificationStatus,
        // user: json['user'] as String? ?? '',
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
      return NotificationModel(
        id: '',
        title: 'Error',
        message: 'Failed to load notification',
        notificationType: 'error',
        sent: false,
        isSeen: false,
        status: NotificationStatus.unread,
        // user: '',
        contentData: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'notification_type': notificationType,
        'image_url': imageUrl,
        'content_id': contentId,
        'sent': sent,
        'status': status.toApiString(),
        // 'user': user,
        'content_data': contentData,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? notificationType,
    String? imageUrl,
    String? contentId,
    bool? sent,
    bool? isSeen,
    NotificationStatus? status,
    String? user,
    Map<String, dynamic>? contentData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      imageUrl: imageUrl ?? this.imageUrl,
      contentId: contentId ?? this.contentId,
      sent: sent ?? this.sent,
      isSeen: isSeen ?? this.isSeen,
      status: status ??
          (isSeen != null
              ? (isSeen ? NotificationStatus.read : NotificationStatus.unread)
              : this.status),
      // user: user ?? this.user,
      contentData: contentData ?? this.contentData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if this notification has expandable content
  bool get hasExpandableContent =>
      contentData != null && contentData!.isNotEmpty;

  /// Get display value from contentData for a given key
  String? getContentValue(String key) => contentData?[key]?.toString();

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        notificationType,
        imageUrl,
        contentId,
        sent,
        isSeen,
        status,
        // user,
        contentData,
        createdAt,
        updatedAt,
      ];
}
