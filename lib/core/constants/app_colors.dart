import 'package:flutter/material.dart';

/// Centralized, accessible color system for SmartDay in Light and Dark themes.
class AppColors {
  // Brand Primary & Accents
  static const Color primary = Color(0xFF3B82F6); // Vibrant Blue
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color secondary = Color(0xFF6366F1); // Indigo
  static const Color accent = Color(0xFF06B6D4); // Cyan

  // Neutral Background & Surface (Light Theme)
  static const Color lightBg = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightTextTertiary = Color(0xFF94A3B8); // Slate 400

  // Neutral Background & Surface (Dark Theme)
  static const Color darkBg = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCardBg = Color(0xFF1E293B);
  static const Color darkCardElevated = Color(0xFF243045);
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextTertiary = Color(0xFF64748B); // Slate 500

  // Status & Priority Colors (Subtle & Professional, Never Overbearing)
  static const Color priorityLow = Color(0xFF0284C7); // Sky Blue
  static const Color priorityMedium = Color(0xFFD97706); // Amber
  static const Color priorityHigh = Color(0xFFE11D48); // Rose Red

  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Category Colors
  static const Color catWork = Color(0xFF4F46E5); // Indigo
  static const Color catPersonal = Color(0xFF059669); // Emerald
  static const Color catHealth = Color(0xFFE11D48); // Rose
  static const Color catStudy = Color(0xFF0284C7); // Sky
  static const Color catMeeting = Color(0xFF7C3AED); // Violet
  static const Color catAppointment = Color(0xFF2563EB); // Royal Blue
  static const Color catShopping = Color(0xFFD97706); // Amber
  static const Color catOther = Color(0xFF64748B); // Slate

  // Reminder Method Colors
  static const Color methodNotification = Color(0xFF3B82F6);
  static const Color methodAlarm = Color(0xFFF59E0B);
  static const Color methodBoth = Color(0xFF8B5CF6);

  /// Helper to get a subtle background tint for chips and badges
  static Color subtleTint(Color color, {bool isDark = false}) {
    return isDark ? color.withValues(alpha: 0.22) : color.withValues(alpha: 0.12);
  }
}
