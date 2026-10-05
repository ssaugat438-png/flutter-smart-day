import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

/// State management for app configuration and notification permissions.
class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();
  bool _notificationPermissionGranted = true;
  bool _isCheckingPermission = false;

  AppSettings get settings => _settings;
  bool get soundEnabled => _settings.soundEnabled;
  bool get vibrationEnabled => _settings.vibrationEnabled;
  int get defaultReminderMinutes => _settings.defaultReminderMinutes;
  bool get use24HourFormat => _settings.use24HourFormat;
  int get startOfWeek => _settings.startOfWeek;
  bool get notificationPermissionGranted => _notificationPermissionGranted;
  bool get isCheckingPermission => _isCheckingPermission;

  SettingsProvider() {
    loadSettings();
    checkPermissionStatus();
  }

  Future<void> loadSettings() async {
    _settings = await StorageService.loadSettings();
    notifyListeners();
  }

  Future<void> checkPermissionStatus() async {
    _isCheckingPermission = true;
    notifyListeners();

    _notificationPermissionGranted =
        await NotificationService().checkPermission();
    _isCheckingPermission = false;
    notifyListeners();
  }

  Future<bool> requestNotificationPermission() async {
    final granted = await NotificationService().requestPermission();
    _notificationPermissionGranted = granted;
    notifyListeners();
    return granted;
  }

  Future<void> setSoundEnabled(bool value) async {
    _settings = _settings.copyWith(soundEnabled: value);
    notifyListeners();
    await StorageService.saveSettings(_settings);
  }

  Future<void> setVibrationEnabled(bool value) async {
    _settings = _settings.copyWith(vibrationEnabled: value);
    notifyListeners();
    await StorageService.saveSettings(_settings);
  }

  Future<void> setDefaultReminderMinutes(int minutes) async {
    _settings = _settings.copyWith(defaultReminderMinutes: minutes);
    notifyListeners();
    await StorageService.saveSettings(_settings);
  }

  Future<void> set24HourFormat(bool value) async {
    _settings = _settings.copyWith(use24HourFormat: value);
    notifyListeners();
    await StorageService.saveSettings(_settings);
  }

  Future<void> setStartOfWeek(int day) async {
    _settings = _settings.copyWith(startOfWeek: day);
    notifyListeners();
    await StorageService.saveSettings(_settings);
  }
}
