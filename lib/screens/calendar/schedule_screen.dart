import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/priority_badge.dart';
import '../add_reminder/add_edit_reminder_screen.dart';
import '../reminder_details/reminder_details_screen.dart';

/// Chronological daily schedule and calendar view.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ReminderProvider>();
    final settings = context.watch<SettingsProvider>();

    // Filter reminders for the selected date
    final dateReminders = provider.allReminders.where((r) {
      return r.dueDate.year == _selectedDate.year &&
          r.dueDate.month == _selectedDate.month &&
          r.dueDate.day == _selectedDate.day;
    }).toList();

    dateReminders.sort((a, b) => a.fullDueDateTime.compareTo(b.fullDueDateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Go to Today',
            onPressed: () {
              setState(() => _selectedDate = DateTime.now());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Horizontal Date Carousel
          _buildDateCarousel(context),

          const SizedBox(height: 8),

          // 2. Schedule Subheader with count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatSmartDate(_selectedDate).toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  '${dateReminders.length} ${dateReminders.length == 1 ? 'activity' : 'activities'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),

          // 3. Chronological Time-based Timeline List
          Expanded(
            child: dateReminders.isEmpty
                ? EmptyState(
                    title: 'No schedule entries',
                    subtitle:
                        'Nothing planned for ${DateFormat('MMMM d').format(_selectedDate)}.',
                    actionLabel: '+ Schedule Activity',
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditReminderScreen(
                            preselectedDate: _selectedDate,
                          ),
                        ),
                      );
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: dateReminders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = dateReminders[index];
                      return _buildTimelineCard(
                        context,
                        reminder: item,
                        provider: provider,
                        settings: settings,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditReminderScreen(
                preselectedDate: _selectedDate,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add to Date'),
      ),
    );
  }

  Widget _buildDateCarousel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 30, // 30 days window
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index - 2)); // 2 days past, 28 forward
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark ? AppColors.darkCardBg : AppColors.lightCardBg),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isToday
                          ? (isDark ? AppColors.primaryLight : AppColors.primary)
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder)),
                  width: isToday && !isSelected ? 1.6 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (isDark ? AppColors.darkBg : Colors.white)
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? (isDark ? AppColors.darkBg : Colors.white)
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context, {
    required Reminder reminder,
    required ReminderProvider provider,
    required SettingsProvider settings,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = provider.getCategoryById(reminder.categoryId);
    final isCompleted = reminder.isCompleted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ReminderDetailsScreen(reminderId: reminder.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Time Column
                Container(
                  width: 82,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withValues(alpha: 0.5)
                        : AppColors.lightBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormatter.formatTime(
                          reminder.dueTime,
                          use24Hour: settings.use24HourFormat,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        reminder.reminderMethod == ReminderMethod.alarm ||
                                reminder.reminderMethod == ReminderMethod.both
                            ? Icons.alarm_rounded
                            : Icons.notifications_none_rounded,
                        size: 15,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ],
                  ),
                ),

                // Vertical accent stripe by category
                Container(
                  width: 4,
                  color: category.color,
                ),

                // 2. Event Information
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                reminder.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: isCompleted
                                      ? (isDark
                                          ? AppColors.darkTextTertiary
                                          : AppColors.lightTextTertiary)
                                      : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                            PriorityBadge(
                              priority: reminder.priority,
                              isCompact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(category.icon,
                                size: 13, color: category.color),
                            const SizedBox(width: 4),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: category.color,
                              ),
                            ),
                            if (reminder.description.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text('•',
                                  style: TextStyle(
                                      color: isDark
                                          ? AppColors.darkTextTertiary
                                          : AppColors.lightTextTertiary)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  reminder.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Quick Checkbox
                IconButton(
                  icon: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isCompleted
                        ? AppColors.success
                        : (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary),
                    size: 22,
                  ),
                  onPressed: () {
                    provider.toggleComplete(
                      reminder.id,
                      settings: settings.settings,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
