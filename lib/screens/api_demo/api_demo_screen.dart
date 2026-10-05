import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reminder.dart';
import '../../models/remote_task.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';

/// Screen demonstrating external REST API consumption and optional task import.
class ApiDemoScreen extends StatefulWidget {
  const ApiDemoScreen({super.key});

  @override
  State<ApiDemoScreen> createState() => _ApiDemoScreenState();
}

class _ApiDemoScreenState extends State<ApiDemoScreen> {
  final ApiService _apiService = ApiService();
  List<RemoteTask> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _apiService.fetchRemoteTasks(limit: 10);
      setState(() {
        _tasks = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _importTask(RemoteTask task) async {
    final provider = context.read<ReminderProvider>();
    final settings = context.read<SettingsProvider>();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final newReminder = Reminder(
      id: const Uuid().v4(),
      title: task.title,
      description: 'Imported from REST API demonstration.',
      dueDate: today,
      dueTime: TimeOfDay(hour: (now.hour + 2) % 24, minute: 0),
      categoryId: 'work',
      priority: PriorityLevel.medium,
      reminderMethod: ReminderMethod.notification,
      reminderMinutesBefore: 15,
      status: task.completed ? TaskState.completed : TaskState.pending,
      notificationId: 0,
      notes: 'Remote API Task #${task.id}',
    );

    final success =
        await provider.addReminder(newReminder, settings: settings.settings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Imported "${task.title}" to today\'s schedule.'
              : 'Failed to import task.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Feed',
            onPressed: _isLoading ? null : _fetchTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner explaining standalone lab nature
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.6)
                : AppColors.lightBorder.withValues(alpha: 0.5),
            child: Row(
              children: [
                const Icon(Icons.cloud_outlined,
                    color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live REST API Integration',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Demonstrates async GET requests, JSON decoding & error handling. SmartDay runs offline by default.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content body
          Expanded(
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Fetching remote tasks...',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: AppColors.warning),
              const SizedBox(height: 16),
              const Text(
                'Connection Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Retry Connection',
                width: 160,
                onPressed: _fetchTasks,
              ),
            ],
          ),
        ),
      );
    }

    if (_tasks.isEmpty) {
      return const Center(child: Text('No remote tasks returned.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = _tasks[index];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                task.completed
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                size: 20,
                color: task.completed
                    ? AppColors.success
                    : (isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'API ID: #${task.id} • ${task.completed ? "Completed" : "Pending"}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_task_rounded,
                    color: AppColors.primary),
                tooltip: 'Import into SmartDay',
                onPressed: () => _importTask(task),
              ),
            ],
          ),
        );
      },
    );
  }
}
