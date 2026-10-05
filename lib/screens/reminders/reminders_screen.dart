import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../animations/page_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/reminder_card.dart';
import '../add_reminder/add_edit_reminder_screen.dart';
import '../reminder_details/reminder_details_screen.dart';

/// Comprehensive reminder management screen with dynamic search and multi-facet filtering.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ReminderProvider>();
    final filtered = provider.filteredReminders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders & Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Reminder',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditReminderScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search title, description, category...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // 2. Segmented Date Tabs (Today, Tomorrow, Upcoming, All)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip(context, label: 'Today', tab: 'today', provider: provider),
                  const SizedBox(width: 8),
                  _buildTabChip(context, label: 'Tomorrow', tab: 'tomorrow', provider: provider),
                  const SizedBox(width: 8),
                  _buildTabChip(context, label: 'Upcoming', tab: 'upcoming', provider: provider),
                  const SizedBox(width: 8),
                  _buildTabChip(context, label: 'Overdue', tab: 'overdue', provider: provider),
                  const SizedBox(width: 8),
                  _buildTabChip(context, label: 'All Tasks', tab: 'all', provider: provider),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 3. Category Filter Chips Bar
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('All Categories'),
                  selected: provider.selectedCategoryFilter == 'all',
                  onSelected: (_) => provider.setSelectedCategoryFilter('all'),
                  selectedColor: isDark
                      ? AppColors.primaryLight.withValues(alpha: 0.25)
                      : AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor:
                      isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(width: 8),
                ...provider.categories.map((cat) {
                  final isSelected = provider.selectedCategoryFilter == cat.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(cat.icon, size: 14, color: cat.color),
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (_) =>
                          provider.setSelectedCategoryFilter(cat.id),
                      selectedColor:
                          AppColors.subtleTint(cat.color, isDark: isDark),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4. Result Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'task found' : 'tasks found'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                if (provider.searchQuery.isNotEmpty ||
                    provider.selectedCategoryFilter != 'all')
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      provider.clearFilters();
                    },
                    child: Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 5. Filtered List
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    title: 'No reminders found',
                    subtitle: provider.searchQuery.isNotEmpty
                        ? 'Try searching with different keywords.'
                        : 'No reminders match your active filters.',
                    actionLabel: '+ New Reminder',
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddEditReminderScreen(),
                        ),
                      );
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return AnimatedFadeSlide(
                        index: index,
                        child: ReminderCard(
                          reminder: item,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReminderDetailsScreen(reminderId: item.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(
    BuildContext context, {
    required String label,
    required String tab,
    required ReminderProvider provider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = provider.selectedDateTab == tab;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) provider.setSelectedDateTab(tab);
      },
      selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? (isDark ? AppColors.darkBg : Colors.white)
            : (isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
      ),
      showCheckmark: false,
    );
  }
}
