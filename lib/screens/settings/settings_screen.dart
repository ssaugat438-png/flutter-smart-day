import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../api_demo/api_demo_screen.dart';
import '../categories/categories_screen.dart';

/// Settings screen for managing notifications, sound/vibration, themes, and app data.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final reminderProvider = context.read<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Section 1: Notifications & Channels
          _buildSectionHeader(context, 'NOTIFICATIONS & ALERTS'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              // Permission tile
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(
                  settingsProvider.notificationPermissionGranted
                      ? Icons.notifications_active_rounded
                      : Icons.notification_important_rounded,
                  color: settingsProvider.notificationPermissionGranted
                      ? AppColors.success
                      : AppColors.warning,
                ),
                title: Text(
                  settingsProvider.notificationPermissionGranted
                      ? 'Notifications Enabled'
                      : 'Permission Required',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  settingsProvider.notificationPermissionGranted
                      ? 'Android notification channels active.'
                      : 'Tap to grant permission for offline alerts.',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: !settingsProvider.notificationPermissionGranted
                    ? TextButton(
                        onPressed: () =>
                            settingsProvider.requestNotificationPermission(),
                        child: const Text('Enable'),
                      )
                    : const Icon(Icons.check,
                        color: AppColors.success, size: 18),
              ),
              const Divider(height: 1),

              // Sound toggle
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                secondary: const Icon(Icons.volume_up_rounded),
                title: const Text('Notification Sound',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: const Text('Play sound on reminder alert',
                    style: TextStyle(fontSize: 12)),
                value: settingsProvider.soundEnabled,
                onChanged: (val) => settingsProvider.setSoundEnabled(val),
              ),
              const Divider(height: 1),

              // Vibration toggle
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                secondary: const Icon(Icons.vibration_rounded),
                title: const Text('Vibration',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: const Text('Vibrate on reminder alert',
                    style: TextStyle(fontSize: 12)),
                value: settingsProvider.vibrationEnabled,
                onChanged: (val) => settingsProvider.setVibrationEnabled(val),
              ),
              const Divider(height: 1),

              // Default offset
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Default Reminder Time',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: Text(
                  settingsProvider.defaultReminderMinutes == 0
                      ? 'At exact time of event'
                      : '${settingsProvider.defaultReminderMinutes} minutes before',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: DropdownButton<int>(
                  value: settingsProvider.defaultReminderMinutes,
                  underline: const SizedBox(),
                  items: AppConstants.reminderOffsetOptions.map((offset) {
                    return DropdownMenuItem<int>(
                      value: offset,
                      child: Text(
                        offset == 0 ? 'At time' : '${offset}m before',
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      settingsProvider.setDefaultReminderMinutes(val);
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 2: Appearance & Preferences
          _buildSectionHeader(context, 'APPEARANCE & PREFERENCES'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              // Theme Mode Selector
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Theme Mode',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: Text(
                  themeProvider.themeMode == ThemeMode.system
                      ? 'Follow System'
                      : themeProvider.themeMode == ThemeMode.dark
                          ? 'Dark Theme'
                          : 'Light Theme',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: DropdownButton<ThemeMode>(
                  value: themeProvider.themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System', style: TextStyle(fontSize: 13)),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light', style: TextStyle(fontSize: 13)),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      themeProvider.setThemeMode(mode);
                    }
                  },
                ),
              ),
              const Divider(height: 1),

              // 24-hour format
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                secondary: const Icon(Icons.access_time_rounded),
                title: const Text('24-Hour Format',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: const Text('Display e.g. 14:00 instead of 02:00 PM',
                    style: TextStyle(fontSize: 12)),
                value: settingsProvider.use24HourFormat,
                onChanged: (val) => settingsProvider.set24HourFormat(val),
              ),
              const Divider(height: 1),

              // Categories Manager
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.category_outlined),
                title: const Text('Manage Categories',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: const Text('Customize category names, icons, & colors',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CategoriesScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 3: Data & Integrations
          _buildSectionHeader(context, 'DATA & DEMO'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.cloud_sync_outlined),
                title: const Text('REST API Demonstration',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: const Text('Async HTTP client & sample task import',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ApiDemoScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.restore_rounded),
                title: const Text('Reset Sample Data',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                subtitle: const Text('Re-seed initial demo tasks and schedules',
                    style: TextStyle(fontSize: 12)),
                onTap: () => _confirmResetData(context, reminderProvider),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section 4: About
          _buildSectionHeader(context, 'ABOUT'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(AppConstants.appName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(
                    '${AppConstants.appTagline}\nVersion ${AppConstants.appVersion}',
                    style: const TextStyle(fontSize: 12)),
                isThreeLine: true,
                trailing: TextButton(
                  onPressed: () => _showAboutDialog(context),
                  child: const Text('Details'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(children: children),
    );
  }

  void _confirmResetData(
      BuildContext context, ReminderProvider reminderProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Sample Data?'),
        content: const Text(
          'This will restore realistic starter tasks and sample reminders for today and upcoming days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await reminderProvider.loadInitialData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sample data reloaded.')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppConstants.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appTagline,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'A mobile-first productivity application featuring offline timezone-aware reminder scheduling, Android notification channels, task tracking, and recurring alarms.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Material 3 Design System\n• 100% Offline Core\n• Local Storage Persistence\n• Timezone Aware Local Notifications',
              style: TextStyle(fontSize: 12, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
