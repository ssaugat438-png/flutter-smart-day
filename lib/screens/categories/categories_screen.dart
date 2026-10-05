import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/category.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Screen allowing users to view and add customized categories.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  void _openAddCategoryModal(BuildContext context) {
    final titleController = TextEditingController();
    int selectedColor = AppColors.primary.toARGB32();
    IconData selectedIcon = Icons.folder_open_rounded;

    final availableColors = [
      AppColors.catWork,
      AppColors.catPersonal,
      AppColors.catHealth,
      AppColors.catStudy,
      AppColors.catMeeting,
      AppColors.catAppointment,
      AppColors.catShopping,
      AppColors.catOther,
    ];

    final availableIcons = [
      Icons.folder_open_rounded,
      Icons.work_outline_rounded,
      Icons.fitness_center_rounded,
      Icons.home_outlined,
      Icons.flight_outlined,
      Icons.music_note_rounded,
      Icons.book_outlined,
      Icons.pets_outlined,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isDark = Theme.of(modalCtx).brightness == Brightness.dark;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Category',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(modalCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'CATEGORY NAME',
                    hint: 'e.g. Finances, Fitness, Hobby',
                    controller: titleController,
                    validator: Validators.validateCategoryName,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CHOOSE COLOR',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: availableColors.map((color) {
                      final isSelected = selectedColor == color.toARGB32();
                      return GestureDetector(
                        onTap: () => setModalState(
                            () => selectedColor = color.toARGB32()),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CHOOSE ICON',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: availableIcons.map((icon) {
                      final isSelected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () =>
                            setModalState(() => selectedIcon = icon),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary)
                                : (isDark
                                    ? AppColors.darkCardBg
                                    : AppColors.lightCardBg),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                            ),
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: isSelected
                                ? (isDark ? AppColors.darkBg : Colors.white)
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Create Category',
                    onPressed: () {
                      final name = titleController.text.trim();
                      if (name.isEmpty) return;

                      final newCat = CategoryItem(
                        id: name.toLowerCase().replaceAll(' ', '_'),
                        name: name,
                        iconCodePoint: selectedIcon.codePoint,
                        iconFontFamily: selectedIcon.fontFamily,
                        colorValue: selectedColor,
                      );

                      context.read<ReminderProvider>().addCategory(newCat);
                      Navigator.of(modalCtx).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ReminderProvider>();
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Category',
            onPressed: () => _openAddCategoryModal(context),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final usageCount = provider.allReminders
              .where((r) => r.categoryId == cat.id)
              .length;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.subtleTint(cat.color, isDark: isDark),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(cat.icon, size: 20, color: cat.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                Text(
                  '$usageCount ${usageCount == 1 ? 'task' : 'tasks'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomButton(
          label: '+ Add Custom Category',
          variant: ButtonVariant.outlined,
          onPressed: () => _openAddCategoryModal(context),
        ),
      ),
    );
  }
}
