import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/category.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

/// Central reactive state management for reminders, categories, metrics, and filters.
class ReminderProvider extends ChangeNotifier {
  List<Reminder> _reminders = [];
  List<CategoryItem> _categories = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Filter state
  String _searchQuery = '';
  String _selectedCategoryFilter = 'all';
  PriorityLevel? _selectedPriorityFilter;
  TaskState? _selectedStatusFilter;
  String _selectedDateTab = 'today'; // 'today', 'tomorrow', 'upcoming', 'all'

  // Getters
  List<Reminder> get allReminders => List.unmodifiable(_reminders);
  List<CategoryItem> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  PriorityLevel? get selectedPriorityFilter => _selectedPriorityFilter;
  TaskState? get selectedStatusFilter => _selectedStatusFilter;
  String get selectedDateTab => _selectedDateTab;

  /// Total number of stored reminders.
  int get totalCount => _reminders.length;

  /// Dynamic calculation: Number of pending tasks.
  int get pendingCount =>
      _reminders.where((r) => r.status == TaskState.pending).length;

  /// Dynamic calculation: Number of completed tasks.
  int get completedCount =>
      _reminders.where((r) => r.status == TaskState.completed).length;

  /// Dynamic calculation: Number of overdue tasks.
  int get overdueCount => _reminders.where((r) => r.isOverdue).length;

  /// Dynamic calculation: Number of tasks scheduled for today.
  int get todayCount => _reminders.where((r) => r.isDueToday).length;

  /// The single next upcoming pending reminder based on current time.
  Reminder? get nextUpcomingReminder {
    final now = DateTime.now();
    final upcomingPending = _reminders
        .where((r) =>
            r.status == TaskState.pending && r.fullDueDateTime.isAfter(now))
        .toList();

    if (upcomingPending.isEmpty) {
      // Fallback to any pending today's reminder
      final todayPending = _reminders
          .where((r) => r.status == TaskState.pending && r.isDueToday)
          .toList();
      if (todayPending.isEmpty) return null;
      todayPending.sort((a, b) => a.fullDueDateTime.compareTo(b.fullDueDateTime));
      return todayPending.first;
    }

    upcomingPending.sort((a, b) => a.fullDueDateTime.compareTo(b.fullDueDateTime));
    return upcomingPending.first;
  }

  /// Reminders scheduled for today, sorted chronologically.
  List<Reminder> get todayReminders {
    final list = _reminders.where((r) => r.isDueToday).toList();
    list.sort((a, b) => a.fullDueDateTime.compareTo(b.fullDueDateTime));
    return list;
  }

  /// Reminders scheduled for tomorrow, sorted chronologically.
  List<Reminder> get tomorrowReminders {
    final list = _reminders.where((r) => r.isDueTomorrow).toList();
    list.sort((a, b) => a.fullDueDateTime.compareTo(b.fullDueDateTime));
    return list;
  }

  /// Reminders scheduled after tomorrow, sorted chronologically.
  List<Reminder> get upcomingReminders {
    final now = DateTime.now();
    final dayAfterTomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 2));

    final list = _reminders
        .where((r) => r.dueDate.isAtSameMomentAs(dayAfterTomorrow) ||
            r.dueDate.isAfter(dayAfterTomorrow))
        .toList();
    list.sort((a, b) => a.fullDueDateTime.compareTo(b.fullDueDateTime));
    return list;
  }

  /// Filtered list of reminders according to active date tab, category, priority, status, and search query.
  List<Reminder> get filteredReminders {
    var result = List<Reminder>.from(_reminders);

    // 1. Date tab filter
    if (_selectedDateTab == 'today') {
      result = result.where((r) => r.isDueToday).toList();
    } else if (_selectedDateTab == 'tomorrow') {
      result = result.where((r) => r.isDueTomorrow).toList();
    } else if (_selectedDateTab == 'upcoming') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      result = result.where((r) => r.dueDate.isAfter(today)).toList();
    } else if (_selectedDateTab == 'overdue') {
      result = result.where((r) => r.isOverdue).toList();
    }

    // 2. Category filter
    if (_selectedCategoryFilter != 'all') {
      result = result
          .where((r) => r.categoryId == _selectedCategoryFilter)
          .toList();
    }

    // 3. Priority filter
    if (_selectedPriorityFilter != null) {
      result =
          result.where((r) => r.priority == _selectedPriorityFilter).toList();
    }

    // 4. Status filter
    if (_selectedStatusFilter != null) {
      result = result.where((r) => r.status == _selectedStatusFilter).toList();
    }

    // 5. Search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((r) {
        final matchTitle = r.title.toLowerCase().contains(q);
        final matchDesc = r.description.toLowerCase().contains(q);
        final matchNotes = r.notes.toLowerCase().contains(q);
        final category = getCategoryById(r.categoryId);
        final matchCategory = category.name.toLowerCase().contains(q);
        return matchTitle || matchDesc || matchNotes || matchCategory;
      }).toList();
    }

    // Sort chronologically
    result.sort((a, b) => a.fullDueDateTime.compareTo(b.fullDueDateTime));
    return result;
  }

  ReminderProvider({bool autoLoad = true}) {
    if (autoLoad) {
      loadInitialData();
    }
  }

  /// Loads reminders and categories from local storage.
  /// If storage is empty, seeds high quality sample data.
  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await StorageService.loadCategories();
      final storedReminders = await StorageService.loadReminders();

      if (storedReminders.isNotEmpty) {
        _reminders = storedReminders;
      } else {
        // First run seed
        _reminders = StorageService.getSampleReminders();
        await StorageService.saveReminders(_reminders);

        // Schedule notifications for initial active reminders
        for (final r in _reminders) {
          if (!r.isCompleted) {
            await NotificationService().scheduleReminder(r);
          }
        }
      }
    } catch (e, stack) {
      _errorMessage = 'Failed to load reminders: $e';
      debugPrint('ReminderProvider.loadInitialData error: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new reminder, schedules its notification, and persists changes.
  Future<bool> addReminder(
    Reminder reminder, {
    AppSettings settings = const AppSettings(),
  }) async {
    try {
      // Ensure notification ID is unique
      final safeNotificationId = reminder.notificationId == 0
          ? (Random().nextInt(900000) + 100000)
          : reminder.notificationId;

      final safeReminder =
          reminder.copyWith(notificationId: safeNotificationId);

      _reminders.add(safeReminder);
      notifyListeners();

      // Schedule offline notification
      await NotificationService()
          .scheduleReminder(safeReminder, settings: settings);

      // Persist to local storage
      await StorageService.saveReminders(_reminders);
      return true;
    } catch (e) {
      debugPrint('ReminderProvider.addReminder error: $e');
      return false;
    }
  }

  /// Updates an existing reminder, reschedules its notification, and persists.
  Future<bool> updateReminder(
    Reminder updatedReminder, {
    AppSettings settings = const AppSettings(),
  }) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
      if (index == -1) return false;

      final oldReminder = _reminders[index];

      // Cancel old notification
      await NotificationService()
          .cancelNotification(oldReminder.notificationId);

      _reminders[index] = updatedReminder;
      notifyListeners();

      // Reschedule new notification if not completed
      if (!updatedReminder.isCompleted) {
        await NotificationService()
            .scheduleReminder(updatedReminder, settings: settings);
      }

      await StorageService.saveReminders(_reminders);
      return true;
    } catch (e) {
      debugPrint('ReminderProvider.updateReminder error: $e');
      return false;
    }
  }

  /// Deletes a reminder, cancels its scheduled notification, and persists.
  Future<bool> deleteReminder(String id) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index == -1) return false;

      final reminder = _reminders[index];
      await NotificationService().cancelNotification(reminder.notificationId);

      _reminders.removeAt(index);
      notifyListeners();

      await StorageService.saveReminders(_reminders);
      return true;
    } catch (e) {
      debugPrint('ReminderProvider.deleteReminder error: $e');
      return false;
    }
  }

  /// Toggles task completion state between [TaskState.completed] and [TaskState.pending].
  Future<bool> toggleComplete(
    String id, {
    AppSettings settings = const AppSettings(),
  }) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index == -1) return false;

      final current = _reminders[index];
      final newStatus = current.status == TaskState.completed
          ? TaskState.pending
          : TaskState.completed;

      final updated = current.copyWith(status: newStatus);
      _reminders[index] = updated;
      notifyListeners();

      if (newStatus == TaskState.completed) {
        // Cancel notification since task is done
        await NotificationService().cancelNotification(current.notificationId);
      } else {
        // Reschedule notification if alert is still in the future
        await NotificationService()
            .scheduleReminder(updated, settings: settings);
      }

      await StorageService.saveReminders(_reminders);
      return true;
    } catch (e) {
      debugPrint('ReminderProvider.toggleComplete error: $e');
      return false;
    }
  }

  /// Sets specific task state (pending, completed, skipped).
  Future<bool> setTaskState(String id, TaskState state) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return false;

    final current = _reminders[index];
    final updated = current.copyWith(status: state);
    _reminders[index] = updated;
    notifyListeners();

    if (state != TaskState.pending) {
      await NotificationService().cancelNotification(current.notificationId);
    } else {
      await NotificationService().scheduleReminder(updated);
    }

    await StorageService.saveReminders(_reminders);
    return true;
  }

  // Filter modifiers
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategoryFilter(String categoryId) {
    _selectedCategoryFilter = categoryId;
    notifyListeners();
  }

  void setSelectedPriorityFilter(PriorityLevel? priority) {
    _selectedPriorityFilter = priority;
    notifyListeners();
  }

  void setSelectedStatusFilter(TaskState? status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setSelectedDateTab(String tab) {
    _selectedDateTab = tab;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryFilter = 'all';
    _selectedPriorityFilter = null;
    _selectedStatusFilter = null;
    notifyListeners();
  }

  /// Resolves [CategoryItem] by its ID.
  CategoryItem getCategoryById(String id) {
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => CategoryItem.defaultCategories.first,
    );
  }

  /// Adds a custom category.
  Future<void> addCategory(CategoryItem category) async {
    if (!_categories.any((c) => c.id == category.id)) {
      _categories.add(category);
      notifyListeners();
      await StorageService.saveCategories(_categories);
    }
  }
}
