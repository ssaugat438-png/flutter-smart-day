import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formatting utilities for dates, times, relative labels, and greetings.
class DateFormatter {
  /// Returns contextual greeting based on the hour of the day.
  static String getGreeting([DateTime? time]) {
    final hour = (time ?? DateTime.now()).hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Formats date as e.g. "Monday, October 5".
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }

  /// Formats date for display in cards e.g. "Oct 5, 2026" or "Today" / "Tomorrow".
  static String formatSmartDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  /// Formats [TimeOfDay] into 12-hour ("09:30 AM") or 24-hour ("09:30") string.
  static String formatTime(TimeOfDay time, {bool use24Hour = false}) {
    if (use24Hour) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minuteStr = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:$minuteStr $period';
    }
  }

  /// Generates human-readable relative time string:
  /// e.g. "In 15 minutes", "Due now", "Starts in 2 hours", "Overdue by 30 mins".
  static String formatRelativeTime(DateTime targetDateTime) {
    final now = DateTime.now();
    final difference = targetDateTime.difference(now);

    if (difference.isNegative) {
      final passed = difference.abs();
      if (passed.inMinutes < 1) return 'Due just now';
      if (passed.inMinutes < 60) return 'Overdue by ${passed.inMinutes}m';
      if (passed.inHours < 24) return 'Overdue by ${passed.inHours}h';
      return 'Overdue by ${passed.inDays}d';
    } else {
      if (difference.inMinutes < 1) return 'Starts now';
      if (difference.inMinutes < 60) return 'In ${difference.inMinutes} mins';
      if (difference.inHours < 24) {
        final hours = difference.inHours;
        final mins = difference.inMinutes % 60;
        return mins > 0 ? 'In ${hours}h ${mins}m' : 'In ${hours}h';
      }
      if (difference.inDays == 1) return 'Tomorrow';
      return 'In ${difference.inDays} days';
    }
  }
}
