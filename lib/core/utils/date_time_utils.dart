import 'package:intl/intl.dart';

/// Date helpers used by the domain entities and the sync layer.
class DateTimeUtils {
  const DateTimeUtils._();

  static final DateFormat _dateFormat = DateFormat('d MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');

  /// `12 Sep 2026`
  static String readableDate(DateTime? value) {
    if (value == null) return '-';
    return _dateFormat.format(value.toLocal());
  }

  /// `1:42 PM`
  static String readableTime(DateTime? value) {
    if (value == null) return '-';
    return _timeFormat.format(value.toLocal());
  }

  /// `Today, 1:42 PM` / `Yesterday, 9:10 AM` / `12 Sep 2026, 1:42 PM`
  static String readableStamp(DateTime? value) {
    if (value == null) return 'Never';
    final DateTime local = value.toLocal();
    final DateTime now = DateTime.now();
    final int days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(local.year, local.month, local.day))
        .inDays;

    if (days == 0) return 'Today, ${_timeFormat.format(local)}';
    if (days == 1) return 'Yesterday, ${_timeFormat.format(local)}';
    return '${_dateFormat.format(local)}, ${_timeFormat.format(local)}';
  }

  /// `just now`, `4 min ago`, `3 h ago`, `2 d ago`
  static String relative(DateTime? value) {
    if (value == null) return 'never';
    final Duration diff = DateTime.now().difference(value);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 30) return '${diff.inDays} d ago';
    return readableDate(value);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
