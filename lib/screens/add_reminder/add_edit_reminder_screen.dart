import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/priority_badge.dart';

/// Form screen to add a new reminder or edit an existing one.
class AddEditReminderScreen extends StatefulWidget {
  final Reminder? initialReminder;
  final DateTime? preselectedDate;

  const AddEditReminderScreen({
    super.key,
    this.initialReminder,
    this.preselectedDate,
  });

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _notesController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedCategoryId;
  late PriorityLevel _selectedPriority;
  late ReminderMethod _selectedMethod;
  late int _selectedMinutesBefore;
  late RecurrenceType _selectedRecurrence;

  bool _isSaving = false;

  bool get isEditing => widget.initialReminder != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialReminder;

    final now = DateTime.now();
    _titleController = TextEditingController(text: initial?.title ?? '');
    _descController = TextEditingController(text: initial?.description ?? '');
    _notesController = TextEditingController(text: initial?.notes ?? '');

    _selectedDate = initial?.dueDate ??
        widget.preselectedDate ??
        DateTime(now.year, now.month, now.day);

    _selectedTime = initial?.dueTime ??
        TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);

    _selectedCategoryId = initial?.categoryId ?? 'work';
    _selectedPriority = initial?.priority ?? PriorityLevel.medium;
    _selectedMethod = initial?.reminderMethod ?? ReminderMethod.notification;
    _selectedMinutesBefore = initial?.reminderMinutesBefore ?? 15;
    _selectedRecurrence = initial?.recurrence ?? RecurrenceType.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<ReminderProvider>();
    final settings = context.read<SettingsProvider>();

    try {
      if (isEditing) {
        final updated = widget.initialReminder!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          dueDate: _selectedDate,
          dueTime: _selectedTime,
          categoryId: _selectedCategoryId,
          priority: _selectedPriority,
          reminderMethod: _selectedMethod,
          reminderMinutesBefore: _selectedMinutesBefore,
          recurrence: _selectedRecurrence,
          notes: _notesController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await provider.updateReminder(updated, settings: settings.settings);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder updated successfully.')),
          );
        }
      } else {
        final newReminder = Reminder(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          dueDate: _selectedDate,
          dueTime: _selectedTime,
          categoryId: _selectedCategoryId,
          priority: _selectedPriority,
          reminderMethod: _selectedMethod,
          reminderMinutesBefore: _selectedMinutesBefore,
          recurrence: _selectedRecurrence,
          notificationId: 0, // Assigned automatically by provider
          notes: _notesController.text.trim(),
        );

        await provider.addReminder(newReminder, settings: settings.settings);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder scheduled successfully.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save reminder: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ReminderProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Reminder' : 'New Reminder'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              CustomTextField(
                label: 'TITLE',
                hint: 'e.g. Team Standup or Submit Report',
                controller: _titleController,
                validator: Validators.validateTitle,
                prefixIcon: Icons.title_rounded,
              ),

              const SizedBox(height: 16),

              // Description Field
              CustomTextField(
                label: 'DESCRIPTION (OPTIONAL)',
                hint: 'Add brief details...',
                controller: _descController,
                maxLines: 2,
                prefixIcon: Icons.description_outlined,
              ),

              const SizedBox(height: 20),

              // Date & Time Selectors Row
              Row(
                children: [
                  Expanded(
                    child: _buildPickerCard(
                      context,
                      label: 'DATE',
                      value: DateFormatter.formatSmartDate(_selectedDate),
                      icon: Icons.calendar_today_rounded,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPickerCard(
                      context,
                      label: 'TIME',
                      value: DateFormatter.formatTime(
                        _selectedTime,
                        use24Hour: settings.use24HourFormat,
                      ),
                      icon: Icons.schedule_rounded,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Category Selector
              Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = provider.categories[index];
                    final isSelected = cat.id == _selectedCategoryId;
                    return CategoryChip(
                      category: cat,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Priority Selector
              Text(
                'PRIORITY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: PriorityLevel.values.map((p) {
                  final isSelected = p == _selectedPriority;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPriority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.primaryLight.withValues(alpha: 0.2)
                                    : AppColors.primary.withValues(alpha: 0.12))
                                : (isDark
                                    ? AppColors.darkCardBg
                                    : AppColors.lightCardBg),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary)
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Center(
                            child: PriorityBadge(priority: p, isCompact: true),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Reminder Method Selector (Notification, Alarm, Both)
              Text(
                'REMINDER TYPE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ReminderMethod.values.map((method) {
                  final isSelected = method == _selectedMethod;
                  IconData icon;
                  switch (method) {
                    case ReminderMethod.notification:
                      icon = Icons.notifications_none_rounded;
                      break;
                    case ReminderMethod.alarm:
                      icon = Icons.alarm_rounded;
                      break;
                    case ReminderMethod.both:
                      icon = Icons.add_alert_rounded;
                      break;
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMethod = method),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.primaryLight.withValues(alpha: 0.2)
                                    : AppColors.primary.withValues(alpha: 0.12))
                                : (isDark
                                    ? AppColors.darkCardBg
                                    : AppColors.lightCardBg),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary)
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 18,
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary)
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary)
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Alert Offset (Before)
              Text(
                'REMIND ME BEFORE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.reminderOffsetOptions.map((offset) {
                  final isSelected = offset == _selectedMinutesBefore;
                  String label = offset == 0
                      ? 'At time'
                      : offset < 60
                          ? '${offset}m before'
                          : '${offset ~/ 60}h before';

                  return FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedMinutesBefore = offset);
                    },
                    selectedColor: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.25)
                        : AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Recurrence Selector
              Text(
                'REPEAT',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RecurrenceType>(
                    value: _selectedRecurrence,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: RecurrenceType.values.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(
                          r.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRecurrence = val);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Notes Field
              CustomTextField(
                label: 'NOTES / DETAILS',
                hint: 'Add any specific instructions or links...',
                controller: _notesController,
                maxLines: 3,
                prefixIcon: Icons.notes_rounded,
              ),

              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                label: isEditing ? 'Save Changes' : 'Create Reminder',
                isLoading: _isSaving,
                onPressed: _saveReminder,
                icon: isEditing ? Icons.check_rounded : Icons.add_rounded,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
