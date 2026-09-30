import 'package:lekhan_ai/core/services/app_timezone_service.dart';
import 'package:intl/intl.dart';

// Format timestamp to show just time for today, or date and time for older messages
String formatTimestamp(String? isoTimestamp) {
  if (isoTimestamp == null || isoTimestamp.isEmpty) {
    return 'Now';
  }

  try {
    final dateTime = DateTime.parse(isoTimestamp);
    final timezoneService = AppTimezoneService.instance;
    final now = timezoneService.now();
    final localDateTime = timezoneService.toUserTime(dateTime);
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
    );

    // Format the time part (used in all cases)
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    final formattedTime = '$hour:$minute';

    // If message is from today, show only time
    if (messageDate == today) {
      return formattedTime;
    }

    // If message is from this year, show day, month and time
    if (localDateTime.year == now.year) {
      // Get month name
      const monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final monthName = monthNames[localDateTime.month - 1];

      // Format: "15 May 02:42"
      return '${localDateTime.day} $monthName $formattedTime';
    }

    // For previous years, include the year
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final monthName = monthNames[localDateTime.month - 1];

    // Format: "15 May 2024 02:42"
    return '${localDateTime.day} $monthName ${localDateTime.year} $formattedTime';
  } catch (e) {
    return 'Now';
  }
}

String formatDateTime(Object? dateTime) {
  if (dateTime == null) {
    return 'Now';
  }

  try {
    final parsedDateTime = switch (dateTime) {
      DateTime value => value,
      String value => DateTime.parse(value),
      _ => throw const FormatException('Unsupported date value'),
    };

    final timezoneService = AppTimezoneService.instance;
    final localDateTime = timezoneService.toUserTime(parsedDateTime);

    return DateFormat('MMM dd, yyyy • hh:mm a').format(localDateTime);
  } catch (_) {
    return 'Now';
  }
}
