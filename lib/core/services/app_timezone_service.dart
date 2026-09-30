import 'package:lekhan_ai/shared/user/domain/model/user.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class AppTimezoneService {
  AppTimezoneService._();

  static final AppTimezoneService instance = AppTimezoneService._();

  static const String _defaultTimeZone = 'Asia/Kathmandu';

  static const Map<String, String> _countryTimeZones = {
    'uae': 'Asia/Dubai',
    'united arab emirates': 'Asia/Dubai',
    'oman': 'Asia/Muscat',
    'sultanate of oman': 'Asia/Muscat',
    'ksa': 'Asia/Riyadh',
    'saudi arabia': 'Asia/Riyadh',
    'kingdom of saudi arabia': 'Asia/Riyadh',
    'uganda': 'Africa/Kampala',
    'nepal': 'Asia/Kathmandu',
  };

  String _timeZoneName = _defaultTimeZone;

  void initialize() {
    tzdata.initializeTimeZones();
  }

  void setFromUser(User? user) {
    if (user == null) return;
    setRegion(
      country: user.country ?? user.branch,
      timezone: user.timezone,
    );
  }

  void setRegion({String? country, String? timezone}) {
    final resolved = _resolveTimeZoneName(
      country: country,
      timezone: timezone,
    );

    _timeZoneName = resolved;
  }

  String get timeZoneName => _timeZoneName;

  tz.Location get location {
    try {
      return tz.getLocation(_timeZoneName);
    } catch (_) {
      return tz.getLocation(_defaultTimeZone);
    }
  }

  DateTime now() {
    return tz.TZDateTime.now(location);
  }

  DateTime toUserTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime.toUtc(), location);
  }

  DateTime toUtc(DateTime dateTime) {
    return dateTime.toUtc();
  }

  bool isSameUserDay(DateTime first, DateTime second) {
    final firstLocal = toUserTime(first);
    final secondLocal = toUserTime(second);
    return firstLocal.year == secondLocal.year &&
        firstLocal.month == secondLocal.month &&
        firstLocal.day == secondLocal.day;
  }

  DateTime startOfUserDay(DateTime dateTime) {
    final local = toUserTime(dateTime);
    return DateTime(local.year, local.month, local.day);
  }

  String formatDateTime(
    DateTime dateTime, {
    String pattern = 'MMM dd, yyyy • hh:mm a',
  }) {
    return DateFormat(pattern).format(toUserTime(dateTime));
  }

  String formatDate(DateTime dateTime, {String pattern = 'MMM dd, yyyy'}) {
    return DateFormat(pattern).format(toUserTime(dateTime));
  }

  String formatTime(DateTime dateTime, {String pattern = 'hh:mm a'}) {
    return DateFormat(pattern).format(toUserTime(dateTime));
  }

  String _resolveTimeZoneName({String? country, String? timezone}) {
    final normalizedTimezone = timezone?.trim();
    if (normalizedTimezone != null && normalizedTimezone.isNotEmpty) {
      return normalizedTimezone;
    }

    final normalizedCountry = _normalizeKey(country);
    if (normalizedCountry != null) {
      final mapped = _countryTimeZones[normalizedCountry];
      if (mapped != null) return mapped;
    }

    return _defaultTimeZone;
  }

  String? _normalizeKey(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.toLowerCase();
  }
}
