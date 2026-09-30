import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    /// Limit the length of the text to 10 characters (yyyy-MM-dd)
    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }

    /// Add '-' after year and month
    if (oldValue.text.length < newValue.text.length) {
      if (newText.length == 4 || newText.length == 7) {
        newText += '-';
      }
    } else {
      /// Remove '-' if the user deletes it
      if (newText.length == 4 || newText.length == 7) {
        newText = newText.substring(0, newText.length - 1);
      }
    }

    // Get current date for validation
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    final currentDay = now.day;
    final minAllowedYear = 1900;

    /// Validate year - limit to range (1900 to current year)
    if (newText.length >= 4) {
      int year = int.tryParse(newText.substring(0, 4)) ?? 0;
      if (year > currentYear) {
        newText = '$currentYear${newText.substring(4)}';
      } else if (year < minAllowedYear && year != 0) {
        // Only modify if it's less than min year and not empty/incomplete
        newText = '$minAllowedYear${newText.substring(4)}';
      }
    }

    /// Validate month
    if (newText.length >= 7) {
      int year = int.tryParse(newText.substring(0, 4)) ?? 0;
      int month = int.tryParse(newText.substring(5, 7)) ?? 0;

      // If it's the current year, don't allow future months
      if (year == currentYear && month > currentMonth) {
        newText =
            '${newText.substring(0, 5)}${currentMonth.toString().padLeft(2, '0')}${newText.substring(7)}';
      } else if (month > 12) {
        newText = '${newText.substring(0, 5)}12${newText.substring(7)}';
      } else if (month == 0 && newText.length > 7) {
        newText = '${newText.substring(0, 5)}01${newText.substring(7)}';
      }
    }

    /// Validate day
    if (newText.length >= 10) {
      int year = int.tryParse(newText.substring(0, 4)) ?? 0;
      int month = int.tryParse(newText.substring(5, 7)) ?? 0;
      int day = int.tryParse(newText.substring(8, 10)) ?? 0;
      int maxDay = _getMaxDayForMonth(month, year);

      // If it's the current year and month, don't allow future days
      if (year == currentYear && month == currentMonth && day > currentDay) {
        newText =
            newText.substring(0, 8) + currentDay.toString().padLeft(2, '0');
      } else if (day > maxDay) {
        newText = newText.substring(0, 8) + maxDay.toString().padLeft(2, '0');
      } else if (day == 0) {
        newText = newText.substring(0, 8) + '01';
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  int _getMaxDayForMonth(int month, int year) {
    // Handle leap years correctly for February
    if (month == 2) {
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    } else if (month == 4 || month == 6 || month == 9 || month == 11) {
      return 30; // April, June, September, November
    } else {
      return 31; // January, March, May, July, August, October, December
    }
  }
}
