// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Represents a reminder category (e.g., Work, Personal, Health).
class CategoryItem {
  final String id;
  final String name;
  final int iconCodePoint;
  final String? iconFontFamily;
  final int colorValue;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily,
    required this.colorValue,
  });

  IconData get icon => IconData(
        iconCodePoint,
        fontFamily: iconFontFamily ?? 'MaterialIcons',
      );

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'colorValue': colorValue,
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCodePoint: map['iconCodePoint'] as int,
      iconFontFamily: map['iconFontFamily'] as String?,
      colorValue: map['colorValue'] as int,
    );
  }

  /// Built-in standard categories for SmartDay.
  static List<CategoryItem> get defaultCategories => [
        CategoryItem(
          id: 'work',
          name: 'Work',
          iconCodePoint: Icons.work_outline_rounded.codePoint,
          iconFontFamily: Icons.work_outline_rounded.fontFamily,
          colorValue: AppColors.catWork.toARGB32(),
        ),
        CategoryItem(
          id: 'personal',
          name: 'Personal',
          iconCodePoint: Icons.person_outline_rounded.codePoint,
          iconFontFamily: Icons.person_outline_rounded.fontFamily,
          colorValue: AppColors.catPersonal.toARGB32(),
        ),
        CategoryItem(
          id: 'meeting',
          name: 'Meeting',
          iconCodePoint: Icons.groups_outlined.codePoint,
          iconFontFamily: Icons.groups_outlined.fontFamily,
          colorValue: AppColors.catMeeting.toARGB32(),
        ),
        CategoryItem(
          id: 'health',
          name: 'Health',
          iconCodePoint: Icons.favorite_border_rounded.codePoint,
          iconFontFamily: Icons.favorite_border_rounded.fontFamily,
          colorValue: AppColors.catHealth.toARGB32(),
        ),
        CategoryItem(
          id: 'study',
          name: 'Study',
          iconCodePoint: Icons.school_outlined.codePoint,
          iconFontFamily: Icons.school_outlined.fontFamily,
          colorValue: AppColors.catStudy.toARGB32(),
        ),
        CategoryItem(
          id: 'appointment',
          name: 'Appointment',
          iconCodePoint: Icons.calendar_today_outlined.codePoint,
          iconFontFamily: Icons.calendar_today_outlined.fontFamily,
          colorValue: AppColors.catAppointment.toARGB32(),
        ),
        CategoryItem(
          id: 'shopping',
          name: 'Shopping',
          iconCodePoint: Icons.shopping_bag_outlined.codePoint,
          iconFontFamily: Icons.shopping_bag_outlined.fontFamily,
          colorValue: AppColors.catShopping.toARGB32(),
        ),
        CategoryItem(
          id: 'other',
          name: 'Other',
          iconCodePoint: Icons.more_horiz_rounded.codePoint,
          iconFontFamily: Icons.more_horiz_rounded.fontFamily,
          colorValue: AppColors.catOther.toARGB32(),
        ),
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
