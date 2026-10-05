import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartday/models/reminder.dart';
import 'package:smartday/providers/reminder_provider.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('ReminderProvider State Management Tests', () {
    test('Initializes with default sample data when storage is empty', () async {
      final provider = ReminderProvider(autoLoad: false);
      await provider.loadInitialData();

      expect(provider.totalCount, greaterThan(0));
      expect(provider.categories.length, greaterThanOrEqualTo(8));
      expect(provider.pendingCount, greaterThanOrEqualTo(1));
    });

    test('addReminder adds a reminder and recalculates dynamic metrics', () async {
      final provider = ReminderProvider(autoLoad: false);
      expect(provider.totalCount, equals(0));

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final newReminder = Reminder(
        id: 'rem_alpha',
        title: 'Complete Mobile Redesign',
        dueDate: today,
        dueTime: const TimeOfDay(hour: 16, minute: 0),
        categoryId: 'work',
        priority: PriorityLevel.high,
        notificationId: 501,
      );

      final success = await provider.addReminder(newReminder);
      expect(success, isTrue);
      expect(provider.totalCount, equals(1));
      expect(provider.pendingCount, equals(1));
      expect(provider.todayCount, equals(1));
      expect(provider.allReminders.first.title, equals('Complete Mobile Redesign'));
    });

    test('updateReminder updates existing reminder in state', () async {
      final provider = ReminderProvider(autoLoad: false);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final original = Reminder(
        id: 'rem_beta',
        title: 'Original Title',
        dueDate: today,
        dueTime: const TimeOfDay(hour: 10, minute: 0),
        notificationId: 502,
      );

      await provider.addReminder(original);
      expect(provider.allReminders.first.title, equals('Original Title'));

      final updated = original.copyWith(
        title: 'Updated Title',
        priority: PriorityLevel.high,
      );

      await provider.updateReminder(updated);
      expect(provider.allReminders.first.title, equals('Updated Title'));
      expect(provider.allReminders.first.priority, equals(PriorityLevel.high));
    });

    test('toggleComplete toggles status between pending and completed', () async {
      final provider = ReminderProvider(autoLoad: false);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final reminder = Reminder(
        id: 'rem_gamma',
        title: 'Toggle Task',
        dueDate: today,
        dueTime: const TimeOfDay(hour: 12, minute: 0),
        notificationId: 503,
        status: TaskState.pending,
      );

      await provider.addReminder(reminder);
      expect(provider.pendingCount, equals(1));
      expect(provider.completedCount, equals(0));

      // Mark completed
      await provider.toggleComplete('rem_gamma');
      expect(provider.pendingCount, equals(0));
      expect(provider.completedCount, equals(1));
      expect(provider.allReminders.first.isCompleted, isTrue);

      // Revert back to pending
      await provider.toggleComplete('rem_gamma');
      expect(provider.pendingCount, equals(1));
      expect(provider.completedCount, equals(0));
      expect(provider.allReminders.first.isCompleted, isFalse);
    });

    test('deleteReminder removes entry and decrements count', () async {
      final provider = ReminderProvider(autoLoad: false);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final reminder = Reminder(
        id: 'rem_delta',
        title: 'To Be Deleted',
        dueDate: today,
        dueTime: const TimeOfDay(hour: 11, minute: 0),
        notificationId: 504,
      );

      await provider.addReminder(reminder);
      expect(provider.totalCount, equals(1));

      await provider.deleteReminder('rem_delta');
      expect(provider.totalCount, equals(0));
    });

    test('searchQuery dynamically filters matching title and description', () async {
      final provider = ReminderProvider(autoLoad: false);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await provider.addReminder(
        Reminder(
          id: '1',
          title: 'Quarterly Financial Review',
          description: 'Review Q3 balances and spreadsheets',
          dueDate: today,
          dueTime: const TimeOfDay(hour: 9, minute: 0),
          notificationId: 601,
        ),
      );

      await provider.addReminder(
        Reminder(
          id: '2',
          title: 'Gym Workout Session',
          description: 'Leg day and cardio routine',
          dueDate: today,
          dueTime: const TimeOfDay(hour: 18, minute: 0),
          notificationId: 602,
        ),
      );

      provider.setSelectedDateTab('all');

      provider.setSearchQuery('Financial');
      expect(provider.filteredReminders.length, equals(1));
      expect(provider.filteredReminders.first.title, contains('Financial'));

      provider.setSearchQuery('Workout');
      expect(provider.filteredReminders.length, equals(1));
      expect(provider.filteredReminders.first.title, contains('Gym'));

      provider.setSearchQuery('NonExistentQuery');
      expect(provider.filteredReminders.isEmpty, isTrue);
    });
  });
}
