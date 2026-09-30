import 'package:flutter/material.dart';
import 'package:lekhan_ai/core/image/custom_image.dart';
import '../../domain/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.timeAgo,
    required this.onTap,
    this.onLongPress,
  });

  bool get _unread => !notification.isSeen;
  bool get _hasExpandableContent => notification.hasExpandableContent;

  IconData _getTypeIcon() {
    switch (notification.notificationType.toLowerCase()) {
      case 'video':
        return Icons.play_circle_outline_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      case 'insight':
        return Icons.menu_book_rounded;
      case 'system':
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: .25)
                  : Colors.black.withValues(alpha: .055),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: _unread
                ? (isDark
                    ? colorScheme.primary.withValues(alpha: .08)
                    : colorScheme.primary.withValues(alpha: .04))
                : theme.cardColor,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              splashColor: colorScheme.primary.withValues(alpha: .07),
              highlightColor: colorScheme.primary.withValues(alpha: .04),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Unread accent bar
                    _UnreadAccentBar(visible: _unread),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAvatar(colorScheme),
                            const SizedBox(width: 13),
                            Expanded(
                              child: _TextSection(
                                title: notification.title,
                                message: notification.message,
                                timeAgo: timeAgo,
                                unread: _unread,
                                hasExpandableContent: _hasExpandableContent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
    if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty) {
      return _AvatarShell(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomNetworkImage(
            imageUrl: notification.imageUrl,
            fit: BoxFit.cover,
            errorWidget: _buildIconContent(colorScheme),
          ),
        ),
      );
    }
    return _AvatarShell(child: _buildIconContent(colorScheme));
  }

  Widget _buildIconContent(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: .12),
            colorScheme.primary.withValues(alpha: .06),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getTypeIcon(),
          color: colorScheme.primary.withValues(alpha: .6),
          size: 20,
        ),
      ),
    );
  }
}

class _AvatarShell extends StatelessWidget {
  final Widget child;
  const _AvatarShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        child: child,
      ),
    );
  }
}

class _UnreadAccentBar extends StatelessWidget {
  final bool visible;
  const _UnreadAccentBar({required this.visible});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: visible ? 3.5 : 0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary,
            primary.withValues(alpha: .4),
          ],
        ),
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  final String title;
  final String message;
  final String timeAgo;
  final bool unread;
  final bool hasExpandableContent;

  const _TextSection({
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.unread,
    required this.hasExpandableContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: unread ? FontWeight.w800 : FontWeight.w700,
                  color: baseColor.withValues(alpha: unread ? 1.0 : .75),
                  letterSpacing: 0.1,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              timeAgo,
              style: theme.textTheme.labelSmall?.copyWith(
                color: baseColor.withValues(alpha: .38),
                fontWeight: FontWeight.w400,
                fontSize: 10.5,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Message row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: baseColor.withValues(alpha: .52),
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),
            ),
            if (hasExpandableContent) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: colorScheme.primary.withValues(alpha: .7),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
