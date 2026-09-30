import 'package:fpdart/fpdart.dart';
import 'package:lekhan_ai/core/services/app_timezone_service.dart';

/// Utility class for date validation in attendance operations
class DateValidation {
  /// Validates if a date is allowed for attendance operations
  /// Returns Right(true) if valid, Left(errorMessage) if invalid
  static Either<String, bool> validateAttendanceDate(DateTime date) {
    final now = AppTimezoneService.instance.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    // Check if date is in the future
    if (targetDate.isAfter(today)) {
      return const Left('Attendance cannot be marked for future dates. Please select today or a past date.');
    }
    
    // Check if date is too far in the past (optional business rule)
    final maxPastDays = 30; // Allow attendance marking up to 30 days in the past
    final earliestAllowedDate = today.subtract(Duration(days: maxPastDays));
    
    if (targetDate.isBefore(earliestAllowedDate)) {
      return Left('Attendance cannot be marked for dates older than $maxPastDays days. Please contact administration for older records.');
    }
    
    return const Right(true);
  }
  
  /// Checks if a date is a future date
  static bool isFutureDate(DateTime date) {
    final now = AppTimezoneService.instance.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    return targetDate.isAfter(today);
  }
  
  /// Checks if a date is today
  static bool isToday(DateTime date) {
    final now = AppTimezoneService.instance.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    return targetDate == today;
  }
  
  /// Gets the maximum allowed date for attendance (today)
  static DateTime getMaxAllowedDate() {
    return AppTimezoneService.instance.now();
  }
  
  /// Gets the minimum allowed date for attendance (30 days ago)
  static DateTime getMinAllowedDate() {
    final now = AppTimezoneService.instance.now();
    return now.subtract(const Duration(days: 30));
  }
  
  /// Formats validation error message based on the type of date error
  static String getValidationErrorMessage(DateTime date) {
    if (isFutureDate(date)) {
      return 'Attendance cannot be marked for future dates. Please select today or a past date.';
    }
    
    final minDate = getMinAllowedDate();
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate.isBefore(DateTime(minDate.year, minDate.month, minDate.day))) {
      return 'Attendance cannot be marked for dates older than 30 days. Please contact administration for older records.';
    }
    
    return 'Invalid date selected for attendance marking.';
  }
}