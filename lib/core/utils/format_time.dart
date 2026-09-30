import 'package:intl/intl.dart';
import 'package:lekhan_ai/core/services/app_timezone_service.dart';



// Format time string like "14:30" to "2:30 PM"
String formatTimeForDisplay(String? timeString) {
  if (timeString == null || timeString.isEmpty) {
    return 'Unknown';
  }
  final parts = timeString.split(':');
  if (parts.length < 2) return timeString;

  int hour = int.tryParse(parts[0]) ?? 0;
  String minute = parts[1];

  String period = hour < 12 ? 'AM' : 'PM';
  if (hour > 12) {
    hour -= 12;
  } else if (hour == 0) {
    hour = 12;
  }

  return '$hour:$minute $period';
}

String getAppointMentTime(String startTime, String? endTime) {
  if (endTime == null) {
    return startTime;
  }
  return "$startTime - $endTime";
}

String formatTimeFromIsoString(String? isoString) {
  if (isoString == null || isoString.isEmpty) {
    return 'Unknown';
  }

  try {
    final dateTime = DateTime.parse(isoString);
    final timezoneService = AppTimezoneService.instance;
    final localDateTime = timezoneService.toUserTime(dateTime);
    final now = timezoneService.now();

    final formattedTime = DateFormat('h:mm a').format(localDateTime); // e.g., 1:53 PM

    final isToday = localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day;

    if (isToday) {
      return formattedTime;
    } else {
      final formattedDate = DateFormat('MMMM d').format(localDateTime); // e.g., July 13
      return '$formattedTime $formattedDate';
    }
  } catch (e) {
    return 'Invalid date format';
  }
}
