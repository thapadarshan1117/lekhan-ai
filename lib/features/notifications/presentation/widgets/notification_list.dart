import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/notification_model.dart';
import '../bloc/notification_bloc.dart';
import 'notification_card.dart';
import 'notification_detail_bottom_sheet.dart';

class NotificationsList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final bool hasReachedEnd;
  final ScrollController? scrollController; // Add this parameter

  const NotificationsList({
    super.key,
    required this.notifications,
    required this.isLoading,
    required this.hasReachedEnd,
    this.scrollController, // Make it optional
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty && !isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No notifications found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController, // Use the passed scroll controller
      padding: const EdgeInsets.all(12.0),
      itemCount: notifications.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index >= notifications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final notification = notifications[index];
        return NotificationCard(
          notification: notification,
          timeAgo: _getTimeAgo(notification.createdAt),
          onTap: () async {
            // Mark as read first (if not already read)
            if (!notification.isSeen) {
              context.read<NotificationBloc>().add(
                    NotificationEvent.markAsRead(notification.id),
                  );
              // Small delay to allow API call to initiate
              await Future.delayed(const Duration(milliseconds: 300));
            }
            // Then navigate
            if (context.mounted) {
              _handleNotificationTap(context, notification);
            }
          },
        );
      },
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(
      BuildContext context, NotificationModel notification) {
    final nType = notification.notificationType.toLowerCase();
    final contentId = notification.contentId;

    switch (nType) {
      case 'system':
        // System notifications should always open a full detail view so long
        // messages and any extra content can be read in one place.
        showNotificationDetailSheet(context, notification);
        break;
      case 'insight':
        // Navigate to blog detail page
        if (contentId != null && contentId.isNotEmpty) {
          context.push('/blog_detail_page', extra: {'id': contentId});
        }
        break;
      case 'audio':
        // Navigate to audio player page and load audio by ID
        if (contentId != null && contentId.isNotEmpty) {
          context.push('/audio_player_page', extra: {'id': contentId});
        }
        break;
      case 'video':
        // Video playback feature not available in current version
        return;
      default:
        break;
    }
  }
}
