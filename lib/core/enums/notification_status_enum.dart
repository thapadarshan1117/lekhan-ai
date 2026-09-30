/// Enum for notification status
enum NotificationStatus {
  unread('Unread'),
  read('Read');

  final String displayName;

  const NotificationStatus(this.displayName);

  /// Convert string to enum
  static NotificationStatus fromString(String? value) {
    if (value == null || value.isEmpty) {
      return NotificationStatus.unread;
    }

    final normalizedValue = value.toLowerCase().trim();

    return NotificationStatus.values.firstWhere(
      (status) => status.displayName.toLowerCase() == normalizedValue,
      orElse: () => NotificationStatus.unread,
    );
  }

  /// Convert enum to API-compatible string
  String toApiString() => displayName;

  /// Check if this status is unread
  bool get isUnread => this == NotificationStatus.unread;

  /// Check if this status is read
  bool get isRead => this == NotificationStatus.read;
}
