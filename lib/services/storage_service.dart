import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/category.dart';
import '../models/reminder.dart';

/// Service managing offline-first local persistence using [SharedPreferences].
class StorageService {
  /// Saves list of reminders to persistent storage.
  static Future<bool> saveReminders(List<Reminder> reminders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = reminders.map((r) => r.toMap()).toList();
      final jsonString = jsonEncode(rawList);
      final success =
          await prefs.setString(AppConstants.prefsRemindersKey, jsonString);
      debugPrint(
          'StorageService: Saved ${reminders.length} reminders (success=$success)');
      return success;
    } catch (e, stack) {
      debugPrint('StorageService.saveReminders error: $e\n$stack');
      return false;
    }
  }

  /// Loads list of reminders from persistent storage.
  static Future<List<Reminder>> loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(AppConstants.prefsRemindersKey);
      if (jsonString == null || jsonString.trim().isEmpty) {
        return [];
      }
      final rawList = jsonDecode(jsonString) as List<dynamic>;
      final reminders = rawList
          .map((item) => Reminder.fromMap(item as Map<String, dynamic>))
          .toList();
      debugPrint('StorageService: Loaded ${reminders.length} reminders.');
      return reminders;
    } catch (e, stack) {
      debugPrint('StorageService.loadReminders error: $e\n$stack');
      return [];
    }
  }

  /// Saves user categories to persistent storage.
  static Future<bool> saveCategories(List<CategoryItem> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = categories.map((c) => c.toMap()).toList();
      final jsonString = jsonEncode(rawList);
      return await prefs.setString(AppConstants.prefsCategoriesKey, jsonString);
    } catch (e) {
      debugPrint('StorageService.saveCategories error: $e');
      return false;
    }
  }

  /// Loads user categories or returns defaults if none saved.
  static Future<List<CategoryItem>> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(AppConstants.prefsCategoriesKey);
      if (jsonString == null || jsonString.trim().isEmpty) {
        return CategoryItem.defaultCategories;
      }
      final rawList = jsonDecode(jsonString) as List<dynamic>;
      return rawList
          .map((item) => CategoryItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('StorageService.loadCategories error: $e');
      return CategoryItem.defaultCategories;
    }
  }

  /// Saves user preferences to persistent storage.
  static Future<bool> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefsSoundEnabled, settings.soundEnabled);
      await prefs.setBool(
          AppConstants.prefsVibrationEnabled, settings.vibrationEnabled);
      await prefs.setInt(AppConstants.prefsDefaultReminderMinutes,
          settings.defaultReminderMinutes);
      await prefs.setBool(
          AppConstants.prefs24HourFormat, settings.use24HourFormat);
      await prefs.setInt(
          AppConstants.prefsFirstDayOfWeek, settings.startOfWeek);
      return true;
    } catch (e) {
      debugPrint('StorageService.saveSettings error: $e');
      return false;
    }
  }

  /// Loads user preferences from persistent storage.
  static Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sound = prefs.getBool(AppConstants.prefsSoundEnabled) ?? true;
      final vibration =
          prefs.getBool(AppConstants.prefsVibrationEnabled) ?? true;
      final defaultOffset =
          prefs.getInt(AppConstants.prefsDefaultReminderMinutes) ?? 15;
      final use24Hour =
          prefs.getBool(AppConstants.prefs24HourFormat) ?? false;
      final startOfWeek =
          prefs.getInt(AppConstants.prefsFirstDayOfWeek) ?? 1;

      return AppSettings(
        soundEnabled: sound,
        vibrationEnabled: vibration,
        defaultReminderMinutes: defaultOffset,
        use24HourFormat: use24Hour,
        startOfWeek: startOfWeek,
      );
    } catch (e) {
      debugPrint('StorageService.loadSettings error: $e');
      return const AppSettings();
    }
  }

  /// Clears stored reminders.
  static Future<bool> clearReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(AppConstants.prefsRemindersKey);
    } catch (e) {
      debugPrint('StorageService.clearReminders error: $e');
      return false;
    }
  }

  /// Generates realistic starter reminders dynamically based on current time.
  static List<Reminder> getSampleReminders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return [
      Reminder(
        id: 'sample_1',
        title: 'Project Standup',
        description: 'Review morning sprint backlog with the engineering team.',
        dueDate: today,
        dueTime: const TimeOfDay(hour: 9, minute: 0),
        categoryId: 'work',
        priority: PriorityLevel.high,
        reminderMethod: ReminderMethod.notification,
        reminderMinutesBefore: 15,
        recurrence: RecurrenceType.weekdays,
        status: TaskState.completed,
        notificationId: 1001,
        notes: 'Room 302 or Google Meet link',
      ),
      Reminder(
        id: 'sample_2',
        title: 'Team Product Meeting',
        description: 'Quarterly feature alignment and roadmap presentation.',
        dueDate: today,
        dueTime: const TimeOfDay(hour: 10, minute: 30),
        categoryId: 'meeting',
        priority: PriorityLevel.high,
        reminderMethod: ReminderMethod.alarm,
        reminderMinutesBefore: 30,
        recurrence: RecurrenceType.none,
        status: TaskState.pending,
        notificationId: 1002,
        notes: 'Bring updated design prototypes',
      ),
      Reminder(
        id: 'sample_3',
        title: 'Lunch with Alex',
        description: 'Catch up on weekend plans at the local cafe.',
        dueDate: today,
        dueTime: const TimeOfDay(hour: 13, minute: 0),
        categoryId: 'personal',
        priority: PriorityLevel.low,
        reminderMethod: ReminderMethod.notification,
        reminderMinutesBefore: 10,
        recurrence: RecurrenceType.none,
        status: TaskState.pending,
        notificationId: 1003,
      ),
      Reminder(
        id: 'sample_4',
        title: 'Client Sync Call',
        description: 'Discuss feedback on mobile application deliverables.',
        dueDate: today,
        dueTime: const TimeOfDay(hour: 15, minute: 0),
        categoryId: 'work',
        priority: PriorityLevel.medium,
        reminderMethod: ReminderMethod.both,
        reminderMinutesBefore: 15,
        recurrence: RecurrenceType.none,
        status: TaskState.pending,
        notificationId: 1004,
      ),
      Reminder(
        id: 'sample_5',
        title: 'Doctor Appointment',
        description: 'Annual health checkup at Metro Medical Clinic.',
        dueDate: tomorrow,
        dueTime: const TimeOfDay(hour: 10, minute: 0),
        categoryId: 'health',
        priority: PriorityLevel.high,
        reminderMethod: ReminderMethod.alarm,
        reminderMinutesBefore: 60,
        recurrence: RecurrenceType.none,
        status: TaskState.pending,
        notificationId: 1005,
        notes: 'Fast for 8 hours prior to test',
      ),
      Reminder(
        id: 'sample_6',
        title: 'Weekly Grocery Shopping',
        description: 'Pick up fresh vegetables, fruits, and essentials.',
        dueDate: tomorrow,
        dueTime: const TimeOfDay(hour: 17, minute: 30),
        categoryId: 'shopping',
        priority: PriorityLevel.low,
        reminderMethod: ReminderMethod.notification,
        reminderMinutesBefore: 15,
        recurrence: RecurrenceType.weekly,
        status: TaskState.pending,
        notificationId: 1006,
      ),
    ];
  }
}
