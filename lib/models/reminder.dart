import 'package:flutter/material.dart';

/// Priority levels for SmartDay reminders.
enum PriorityLevel {
  low('Low'),
  medium('Medium'),
  high('High');

  final String label;
  const PriorityLevel(this.label);

  static PriorityLevel fromString(String val) {
    return PriorityLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => PriorityLevel.medium,
    );
  }
}

/// Reminder delivery mechanism.
enum ReminderMethod {
  notification('Notification'),
  alarm('Alarm-Style'),
  both('Notification + Alarm');

  final String label;
  const ReminderMethod(this.label);

  static ReminderMethod fromString(String val) {
    return ReminderMethod.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ReminderMethod.notification,
    );
  }
}

/// Recurrence pattern for recurring reminders.
enum RecurrenceType {
  none('Never'),
  daily('Every day'),
  weekdays('Weekdays (Mon-Fri)'),
  weekly('Every week'),
  monthly('Every month');

  final String label;
  const RecurrenceType(this.label);

  static RecurrenceType fromString(String val) {
    return RecurrenceType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => RecurrenceType.none,
    );
  }
}

/// Task lifecycle completion state.
enum TaskState {
  pending('Pending'),
  completed('Completed'),
  skipped('Skipped');

  final String label;
  const TaskState(this.label);

  static TaskState fromString(String val) {
    return TaskState.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => TaskState.pending,
    );
  }
}

/// Core model representing a reminder or scheduled activity.
class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TimeOfDay dueTime;
  final String categoryId;
  final PriorityLevel priority;
  final ReminderMethod reminderMethod;
  final int reminderMinutesBefore;
  final RecurrenceType recurrence;
  final TaskState status;
  final int notificationId;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.dueTime,
    this.categoryId = 'personal',
    this.priority = PriorityLevel.medium,
    this.reminderMethod = ReminderMethod.notification,
    this.reminderMinutesBefore = 15,
    this.recurrence = RecurrenceType.none,
    this.status = TaskState.pending,
    required this.notificationId,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Precise [DateTime] combined from [dueDate] and [dueTime].
  DateTime get fullDueDateTime => DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueTime.hour,
        dueTime.minute,
      );

  /// Precise [DateTime] when the notification or alarm should trigger.
  DateTime get alertDateTime =>
      fullDueDateTime.subtract(Duration(minutes: reminderMinutesBefore));

  /// Whether this task has been marked complete.
  bool get isCompleted => status == TaskState.completed;

  /// Whether this task is overdue (past due date & time and still pending).
  bool get isOverdue {
    if (isCompleted || status == TaskState.skipped) return false;
    return fullDueDateTime.isBefore(DateTime.now());
  }

  /// Whether this reminder is scheduled for today.
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  /// Whether this reminder is scheduled for tomorrow.
  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day;
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    String? categoryId,
    PriorityLevel? priority,
    ReminderMethod? reminderMethod,
    int? reminderMinutesBefore,
    RecurrenceType? recurrence,
    TaskState? status,
    int? notificationId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      reminderMethod: reminderMethod ?? this.reminderMethod,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      recurrence: recurrence ?? this.recurrence,
      status: status ?? this.status,
      notificationId: notificationId ?? this.notificationId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': {
        'hour': dueTime.hour,
        'minute': dueTime.minute,
      },
      'categoryId': categoryId,
      'priority': priority.name,
      'reminderMethod': reminderMethod.name,
      'reminderMinutesBefore': reminderMinutesBefore,
      'recurrence': recurrence.name,
      'status': status.name,
      'notificationId': notificationId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    final timeMap = map['dueTime'] as Map<String, dynamic>;
    return Reminder(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      dueDate: DateTime.parse(map['dueDate'] as String),
      dueTime: TimeOfDay(
        hour: timeMap['hour'] as int,
        minute: timeMap['minute'] as int,
      ),
      categoryId: map['categoryId'] as String? ?? 'personal',
      priority: PriorityLevel.fromString(map['priority'] as String? ?? 'medium'),
      reminderMethod:
          ReminderMethod.fromString(map['reminderMethod'] as String? ?? 'notification'),
      reminderMinutesBefore: map['reminderMinutesBefore'] as int? ?? 15,
      recurrence:
          RecurrenceType.fromString(map['recurrence'] as String? ?? 'none'),
      status: TaskState.fromString(map['status'] as String? ?? 'pending'),
      notificationId: map['notificationId'] as int? ?? 0,
      notes: map['notes'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reminder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reminder(id: $id, title: $title, due: $dueDate $dueTime, status: $status)';
  }
}
