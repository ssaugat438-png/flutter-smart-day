import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../core/constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/reminder.dart';

/// Notification tap callback handler type.
typedef NotificationTapCallback = void Function(String? payload);

/// Robust offline notification & alarm service using [FlutterLocalNotificationsPlugin].
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  NotificationTapCallback? onNotificationTap;

  /// Initializes timezone data, notification channels, and platform settings.
  Future<bool> initialize({NotificationTapCallback? onSelect}) async {
    if (_isInitialized) return true;
    onNotificationTap = onSelect;

    try {
      // 1. Initialize timezone database
      tz.initializeTimeZones();
      final localName = tz.local.name;
      debugPrint('NotificationService: Local timezone initialized ($localName)');

      // 2. Android Initialization Settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS / macOS Initialization Settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      final initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint(
              'NotificationService: Notification tapped with payload: ${response.payload}');
          if (onNotificationTap != null) {
            onNotificationTap!(response.payload);
          }
        },
      );

      // 4. Create Android Notification Channels
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImpl != null) {
          // Channel 1: General Reminders
          await androidImpl.createNotificationChannel(
            const AndroidNotificationChannel(
              AppConstants.channelRemindersId,
              AppConstants.channelRemindersName,
              description: AppConstants.channelRemindersDesc,
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            ),
          );

          // Channel 2: Important Reminders
          await androidImpl.createNotificationChannel(
            const AndroidNotificationChannel(
              AppConstants.channelImportantId,
              AppConstants.channelImportantName,
              description: AppConstants.channelImportantDesc,
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            ),
          );

          // Channel 3: Alarm-Style Reminders
          await androidImpl.createNotificationChannel(
            const AndroidNotificationChannel(
              AppConstants.channelAlarmsId,
              AppConstants.channelAlarmsName,
              description: AppConstants.channelAlarmsDesc,
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
              enableLights: true,
            ),
          );
          debugPrint('NotificationService: Android notification channels registered.');
        }
      }

      _isInitialized = initialized ?? true;
      return _isInitialized;
    } catch (e, stack) {
      debugPrint('NotificationService.initialize error: $e\n$stack');
      return false;
    }
  }

  /// Checks if notification permissions are currently granted.
  Future<bool> checkPermission() async {
    try {
      if (kIsWeb) return false;
      if (Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final areEnabled = await androidImpl?.areNotificationsEnabled();
        return areEnabled ?? true;
      }
      return true;
    } catch (e) {
      debugPrint('NotificationService.checkPermission error: $e');
      return true;
    }
  }

  /// Requests notification permissions on Android (API 33+) or iOS.
  Future<bool> requestPermission() async {
    try {
      if (kIsWeb) return false;
      if (Platform.isAndroid) {
        final androidImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted =
            await androidImpl?.requestNotificationsPermission();
        return granted ?? false;
      } else if (Platform.isIOS) {
        final iosImpl = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('NotificationService.requestPermission error: $e');
      return false;
    }
  }

  /// Formats notification title and contextual body based on reminder details.
  Map<String, String> generateNotificationContent(Reminder reminder) {
    String title;
    String body;

    final isAlarm = reminder.reminderMethod == ReminderMethod.alarm ||
        reminder.reminderMethod == ReminderMethod.both;

    if (isAlarm) {
      title = '🚨 ${reminder.title}';
    } else {
      title = '⏰ ${reminder.title}';
    }

    final minutes = reminder.reminderMinutesBefore;
    if (minutes == 0) {
      body = isAlarm
          ? '${reminder.title} starts NOW!'
          : '${reminder.title} is due now.';
    } else if (minutes < 60) {
      body = reminder.recurrence != RecurrenceType.none
          ? 'Recurring: Starts in $minutes minutes.'
          : 'Starts in $minutes minutes (${reminder.timeRangeOrDue()}).';
    } else {
      final hours = minutes ~/ 60;
      body = 'Starts in $hours hour(s) (${reminder.timeRangeOrDue()}).';
    }

    if (reminder.description.isNotEmpty) {
      body += ' • ${reminder.description}';
    }

    return {'title': title, 'body': body};
  }

  /// Schedules local notification or alarm for a given [Reminder].
  Future<bool> scheduleReminder(
    Reminder reminder, {
    AppSettings settings = const AppSettings(),
  }) async {
    if (reminder.isCompleted || reminder.status == TaskState.skipped) {
      debugPrint(
          'NotificationService: Skipping schedule for completed/skipped reminder ${reminder.id}');
      return false;
    }

    final alertTime = reminder.alertDateTime;
    final now = DateTime.now();

    // If alert time is already in the past, do not schedule
    if (alertTime.isBefore(now)) {
      debugPrint(
          'NotificationService: Alert time ($alertTime) is in the past. Skipping notification.');
      return false;
    }

    try {
      final content = generateNotificationContent(reminder);
      final channelId = _getChannelIdForReminder(reminder);

      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          channelDescription: _getChannelDesc(channelId),
          importance: _getImportance(reminder),
          priority: _getPriority(reminder),
          playSound: settings.soundEnabled,
          enableVibration: settings.vibrationEnabled,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: settings.soundEnabled,
        ),
      );

      tz.TZDateTime tzAlertTime;
      try {
        tzAlertTime = tz.TZDateTime.from(alertTime, tz.local);
      } catch (_) {
        tz.initializeTimeZones();
        tzAlertTime = tz.TZDateTime.from(alertTime, tz.local);
      }

      // Handle recurrence
      DateTimeComponents? matchComponents;
      switch (reminder.recurrence) {
        case RecurrenceType.daily:
        case RecurrenceType.weekdays:
          matchComponents = DateTimeComponents.time;
          break;
        case RecurrenceType.weekly:
          matchComponents = DateTimeComponents.dayOfWeekAndTime;
          break;
        case RecurrenceType.monthly:
          matchComponents = DateTimeComponents.dayOfMonthAndTime;
          break;
        case RecurrenceType.none:
          matchComponents = null;
          break;
      }

      await _notificationsPlugin.zonedSchedule(
        reminder.notificationId,
        content['title'],
        content['body'],
        tzAlertTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchComponents,
        payload: reminder.id,
      );

      debugPrint(
          'NotificationService: Scheduled [${reminder.title}] at $tzAlertTime (ID: ${reminder.notificationId}, match: $matchComponents)');
      return true;
    } catch (e, stack) {
      debugPrint('NotificationService.scheduleReminder error: $e\n$stack');
      return false;
    }
  }

  /// Cancels an existing scheduled notification by ID.
  Future<void> cancelNotification(int notificationId) async {
    try {
      await _notificationsPlugin.cancel(notificationId);
      debugPrint('NotificationService: Cancelled notification $notificationId');
    } catch (e) {
      debugPrint('NotificationService.cancelNotification error: $e');
    }
  }

  /// Cancels all pending notifications across the app.
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('NotificationService: Cancelled all notifications.');
    } catch (e) {
      debugPrint('NotificationService.cancelAllNotifications error: $e');
    }
  }

  String _getChannelIdForReminder(Reminder reminder) {
    if (reminder.reminderMethod == ReminderMethod.alarm ||
        reminder.reminderMethod == ReminderMethod.both) {
      return AppConstants.channelAlarmsId;
    }
    if (reminder.priority == PriorityLevel.high) {
      return AppConstants.channelImportantId;
    }
    return AppConstants.channelRemindersId;
  }

  String _getChannelName(String channelId) {
    if (channelId == AppConstants.channelAlarmsId) {
      return AppConstants.channelAlarmsName;
    }
    if (channelId == AppConstants.channelImportantId) {
      return AppConstants.channelImportantName;
    }
    return AppConstants.channelRemindersName;
  }

  String _getChannelDesc(String channelId) {
    if (channelId == AppConstants.channelAlarmsId) {
      return AppConstants.channelAlarmsDesc;
    }
    if (channelId == AppConstants.channelImportantId) {
      return AppConstants.channelImportantDesc;
    }
    return AppConstants.channelRemindersDesc;
  }

  Importance _getImportance(Reminder reminder) {
    if (reminder.reminderMethod == ReminderMethod.alarm ||
        reminder.priority == PriorityLevel.high) {
      return Importance.max;
    }
    return Importance.high;
  }

  Priority _getPriority(Reminder reminder) {
    if (reminder.reminderMethod == ReminderMethod.alarm ||
        reminder.priority == PriorityLevel.high) {
      return Priority.max;
    }
    return Priority.high;
  }
}

extension ReminderFormatting on Reminder {
  String timeRangeOrDue() {
    final hour = dueTime.hourOfPeriod == 0 ? 12 : dueTime.hourOfPeriod;
    final min = dueTime.minute.toString().padLeft(2, '0');
    final period = dueTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$min $period';
  }
}
