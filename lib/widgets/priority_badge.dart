import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/reminder.dart';

/// Clean, semantic badge indicating reminder priority.
class PriorityBadge extends StatelessWidget {
  final PriorityLevel priority;
  final bool isCompact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color badgeColor;
    IconData badgeIcon;

    switch (priority) {
      case PriorityLevel.high:
        badgeColor = AppColors.priorityHigh;
        badgeIcon = Icons.priority_high_rounded;
        break;
      case PriorityLevel.medium:
        badgeColor = AppColors.priorityMedium;
        badgeIcon = Icons.remove_rounded;
        break;
      case PriorityLevel.low:
        badgeColor = AppColors.priorityLow;
        badgeIcon = Icons.arrow_downward_rounded;
        break;
    }

    final bgTint = AppColors.subtleTint(badgeColor, isDark: isDark);

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: bgTint,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(badgeIcon, size: 12, color: badgeColor),
            const SizedBox(width: 3),
            Text(
              priority.label,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            '${priority.label} Priority',
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
