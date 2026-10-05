import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../models/reminder.dart';
import '../providers/reminder_provider.dart';
import '../providers/settings_provider.dart';
import 'priority_badge.dart';

/// Interactive card presenting a reminder with animated completion state.
class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ReminderProvider>();
    final settings = context.watch<SettingsProvider>();
    final category = provider.getCategoryById(reminder.categoryId);

    final isCompleted = reminder.isCompleted;
    final isOverdue = reminder.isOverdue;

    final cardBg = isCompleted
        ? (isDark
            ? AppColors.darkCardBg.withValues(alpha: 0.6)
            : AppColors.lightCardBg.withValues(alpha: 0.7))
        : (isDark ? AppColors.darkCardBg : AppColors.lightCardBg);

    final border = isOverdue
        ? AppColors.error.withValues(alpha: 0.4)
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: isOverdue ? 1.4 : 1),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Subtle Animated Checkbox
              GestureDetector(
                onTap: () {
                  provider.toggleComplete(
                    reminder.id,
                    settings: settings.settings,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.success
                          : (isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary),
                      width: 1.8,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 14),

              // 2. Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with subtle strike-through if completed
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? (isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      child: Text(
                        reminder.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Time & Category row
                    Row(
                      children: [
                        // Category Icon & Name
                        Icon(
                          category.icon,
                          size: 13,
                          color: category.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: category.color,
                          ),
                        ),

                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Time
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: isOverdue
                              ? AppColors.error
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatTime(
                            reminder.dueTime,
                            use24Hour: settings.use24HourFormat,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOverdue
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isOverdue
                                ? AppColors.error
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),

                        // Recurrence indicator if recurring
                        if (reminder.recurrence != RecurrenceType.none) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.repeat_rounded,
                            size: 13,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // 3. Priority badge & Reminder method icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriorityBadge(
                    priority: reminder.priority,
                    isCompact: true,
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    reminder.reminderMethod == ReminderMethod.alarm ||
                            reminder.reminderMethod == ReminderMethod.both
                        ? Icons.alarm_rounded
                        : Icons.notifications_none_rounded,
                    size: 15,
                    color: reminder.reminderMethod == ReminderMethod.alarm ||
                            reminder.reminderMethod == ReminderMethod.both
                        ? AppColors.warning
                        : (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
