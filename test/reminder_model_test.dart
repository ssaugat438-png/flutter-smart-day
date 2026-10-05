import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartday/models/category.dart';
import 'package:smartday/models/reminder.dart';

void main() {
  group('Reminder Model Unit Tests', () {
    test('Reminder initializes with correct properties and computes fullDueDateTime', () {
      final dueDate = DateTime(2026, 10, 15);
      const dueTime = TimeOfDay(hour: 14, minute: 30);

      final reminder = Reminder(
        id: 'test_1',
        title: 'Project Presentation',
        description: 'Final deck review with stakeholders',
        dueDate: dueDate,
        dueTime: dueTime,
        categoryId: 'work',
        priority: PriorityLevel.high,
        reminderMethod: ReminderMethod.alarm,
        reminderMinutesBefore: 30,
        recurrence: RecurrenceType.weekly,
        notificationId: 101,
      );

      expect(reminder.id, equals('test_1'));
      expect(reminder.title, equals('Project Presentation'));
      expect(reminder.fullDueDateTime, equals(DateTime(2026, 10, 15, 14, 30)));
      expect(reminder.alertDateTime, equals(DateTime(2026, 10, 15, 14, 0)));
      expect(reminder.isCompleted, isFalse);
    });

    test('Serialization toMap and fromMap works seamlessly', () {
      final dueDate = DateTime(2026, 11, 20);
      const dueTime = TimeOfDay(hour: 9, minute: 15);

      final original = Reminder(
        id: 'rem_123',
        title: 'Doctor Checkup',
        description: 'Annual medical exam',
        dueDate: dueDate,
        dueTime: dueTime,
        categoryId: 'health',
        priority: PriorityLevel.medium,
        reminderMethod: ReminderMethod.notification,
        reminderMinutesBefore: 15,
        recurrence: RecurrenceType.none,
        status: TaskState.completed,
        notificationId: 202,
        notes: 'Clinic room 4B',
      );

      final map = original.toMap();
      final recreated = Reminder.fromMap(map);

      expect(recreated.id, equals(original.id));
      expect(recreated.title, equals(original.title));
      expect(recreated.description, equals(original.description));
      expect(recreated.dueDate.year, equals(original.dueDate.year));
      expect(recreated.dueTime.hour, equals(original.dueTime.hour));
      expect(recreated.dueTime.minute, equals(original.dueTime.minute));
      expect(recreated.categoryId, equals(original.categoryId));
      expect(recreated.priority, equals(original.priority));
      expect(recreated.reminderMethod, equals(original.reminderMethod));
      expect(recreated.status, equals(TaskState.completed));
      expect(recreated.notes, equals('Clinic room 4B'));
    });

    test('isOverdue logic works correctly for past and future tasks', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 1));

      final overdueReminder = Reminder(
        id: 'overdue_1',
        title: 'Past Task',
        dueDate: pastDate,
        dueTime: const TimeOfDay(hour: 8, minute: 0),
        notificationId: 1,
        status: TaskState.pending,
      );

      final futureReminder = Reminder(
        id: 'future_1',
        title: 'Future Task',
        dueDate: futureDate,
        dueTime: const TimeOfDay(hour: 18, minute: 0),
        notificationId: 2,
        status: TaskState.pending,
      );

      final completedOverdueReminder = overdueReminder.copyWith(
        status: TaskState.completed,
      );

      expect(overdueReminder.isOverdue, isTrue);
      expect(futureReminder.isOverdue, isFalse);
      expect(completedOverdueReminder.isOverdue, isFalse);
    });

    test('CategoryItem default categories are well-formed', () {
      final defaults = CategoryItem.defaultCategories;
      expect(defaults.length, greaterThanOrEqualTo(8));
      expect(defaults.any((c) => c.name == 'Work'), isTrue);
      expect(defaults.any((c) => c.name == 'Personal'), isTrue);
      expect(defaults.any((c) => c.name == 'Health'), isTrue);
    });
  });
}
