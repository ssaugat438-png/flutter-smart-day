/// Centralized constants for SmartDay application.
class AppConstants {
  static const String appName = 'SmartDay';
  static const String appTagline = 'Plan less. Remember more.';
  static const String appVersion = '1.0.0';

  // Notification Channels
  static const String channelRemindersId = 'smartday_reminders';
  static const String channelRemindersName = 'General Reminders';
  static const String channelRemindersDesc =
      'Scheduled notifications for your daily tasks and events';

  static const String channelImportantId = 'smartday_important';
  static const String channelImportantName = 'Important Reminders';
  static const String channelImportantDesc =
      'High-priority notifications with persistent sound and vibration';

  static const String channelAlarmsId = 'smartday_alarms';
  static const String channelAlarmsName = 'Alarm-Style Reminders';
  static const String channelAlarmsDesc =
      'Urgent time-critical alerts for immediate appointments';

  // SharedPreferences Keys
  static const String prefsThemeMode = 'smartday_theme_mode';
  static const String prefsRemindersKey = 'smartday_reminders_data_v1';
  static const String prefsCategoriesKey = 'smartday_categories_data_v1';
  static const String prefsSoundEnabled = 'smartday_sound_enabled';
  static const String prefsVibrationEnabled = 'smartday_vibration_enabled';
  static const String prefsDefaultReminderMinutes =
      'smartday_default_reminder_minutes';
  static const String prefs24HourFormat = 'smartday_use_24_hour';
  static const String prefsFirstDayOfWeek = 'smartday_first_day_of_week';

  // Reminder Offsets in Minutes
  static const List<int> reminderOffsetOptions = [0, 5, 10, 15, 30, 60, 120];

  // Remote Demo REST API URL
  static const String demoApiUrl =
      'https://jsonplaceholder.typicode.com/todos?_limit=10';
}
