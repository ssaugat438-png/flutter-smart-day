import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/priority_badge.dart';
import '../add_reminder/add_edit_reminder_screen.dart';

/// Detailed view of a single reminder with edit, delete, and completion actions.
class ReminderDetailsScreen extends StatelessWidget {
  final String reminderId;

  const ReminderDetailsScreen({super.key, required this.reminderId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ReminderProvider>();
    final settings = context.watch<SettingsProvider>();

    final reminder = provider.allReminders.cast<Reminder?>().firstWhere(
          (r) => r?.id == reminderId,
          orElse: () => null,
        );

    if (reminder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reminder Details')),
        body: const Center(child: Text('Reminder not found.')),
      );
    }

    final category = provider.getCategoryById(reminder.categoryId);
    final isCompleted = reminder.isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Reminder',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AddEditReminderScreen(initialReminder: reminder),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Reminder',
            onPressed: () => _confirmDelete(context, reminder),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & Priority row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.subtleTint(category.color, isDark: isDark),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: category.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, size: 14, color: category.color),
                      const SizedBox(width: 5),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: category.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PriorityBadge(priority: reminder.priority),
                const Spacer(),
                // Status pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.subtleTint(AppColors.success, isDark: isDark)
                        : AppColors.subtleTint(AppColors.warning, isDark: isDark),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        size: 13,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.status.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Title
            Text(
              reminder.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),

            if (reminder.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                reminder.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Information Cards
            _buildDetailTile(
              context,
              icon: Icons.calendar_today_rounded,
              title: 'Date & Time',
              value:
                  '${DateFormatter.formatFullDate(reminder.dueDate)} at ${DateFormatter.formatTime(reminder.dueTime, use24Hour: settings.use24HourFormat)}',
              subtitle: DateFormatter.formatRelativeTime(reminder.fullDueDateTime),
            ),

            const SizedBox(height: 12),

            _buildDetailTile(
              context,
              icon: reminder.reminderMethod == ReminderMethod.alarm ||
                      reminder.reminderMethod == ReminderMethod.both
                  ? Icons.alarm_rounded
                  : Icons.notifications_active_outlined,
              title: 'Reminder Method',
              value: reminder.reminderMethod.label,
              subtitle: reminder.reminderMinutesBefore == 0
                  ? 'Alert at exact time'
                  : 'Alert ${reminder.reminderMinutesBefore} minutes before',
            ),

            const SizedBox(height: 12),

            _buildDetailTile(
              context,
              icon: Icons.repeat_rounded,
              title: 'Recurrence',
              value: reminder.recurrence.label,
              subtitle: reminder.recurrence == RecurrenceType.none
                  ? 'One-time event'
                  : 'Repeats automatically',
            ),

            if (reminder.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailTile(
                context,
                icon: Icons.notes_rounded,
                title: 'Additional Notes',
                value: reminder.notes,
              ),
            ],

            const SizedBox(height: 36),

            // Quick Complete / Pending Button
            CustomButton(
              label: isCompleted ? 'Mark as Pending' : 'Mark as Completed',
              variant: isCompleted
                  ? ButtonVariant.secondary
                  : ButtonVariant.primary,
              icon: isCompleted
                  ? Icons.undo_rounded
                  : Icons.check_circle_outline_rounded,
              onPressed: () {
                provider.toggleComplete(
                  reminder.id,
                  settings: settings.settings,
                );
              },
            ),

            const SizedBox(height: 12),

            // Destructive Delete Button
            CustomButton(
              label: 'Delete Reminder',
              variant: ButtonVariant.outlined,
              icon: Icons.delete_outline_rounded,
              onPressed: () => _confirmDelete(context, reminder),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.subtleTint(AppColors.primary, isDark: isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: Text(
          'Are you sure you want to delete "${reminder.title}"? Any scheduled notification will be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ReminderProvider>().deleteReminder(reminder.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder deleted successfully.')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
