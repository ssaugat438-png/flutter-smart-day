/// Represents user configuration preferences for SmartDay.
class AppSettings {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final int defaultReminderMinutes;
  final bool use24HourFormat;
  final int startOfWeek; // 1 = Monday, 7 = Sunday

  const AppSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.defaultReminderMinutes = 15,
    this.use24HourFormat = false,
    this.startOfWeek = 1,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    int? defaultReminderMinutes,
    bool? use24HourFormat,
    int? startOfWeek,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      startOfWeek: startOfWeek ?? this.startOfWeek,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'defaultReminderMinutes': defaultReminderMinutes,
      'use24HourFormat': use24HourFormat,
      'startOfWeek': startOfWeek,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
      defaultReminderMinutes: map['defaultReminderMinutes'] as int? ?? 15,
      use24HourFormat: map['use24HourFormat'] as bool? ?? false,
      startOfWeek: map['startOfWeek'] as int? ?? 1,
    );
  }
}
