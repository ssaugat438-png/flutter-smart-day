import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartday/models/category.dart';
import 'package:smartday/models/reminder.dart';
import 'package:smartday/providers/reminder_provider.dart';
import 'package:smartday/providers/settings_provider.dart';
import 'package:smartday/providers/theme_provider.dart';
import 'package:smartday/screens/add_reminder/add_edit_reminder_screen.dart';
import 'package:smartday/widgets/category_chip.dart';
import 'package:smartday/widgets/custom_button.dart';
import 'package:smartday/widgets/empty_state.dart';
import 'package:smartday/widgets/priority_badge.dart';
import 'package:smartday/widgets/reminder_card.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  group('SmartDay Widget Tests', () {
    testWidgets('EmptyState widget renders headline, message, and executes action',
        (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: 'Your day is clear',
              subtitle: 'Create a reminder to stay organized.',
              actionLabel: '+ Add Reminder',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Your day is clear'), findsOneWidget);
      expect(find.text('Create a reminder to stay organized.'), findsOneWidget);
      expect(find.text('+ Add Reminder'), findsOneWidget);

      await tester.tap(find.text('+ Add Reminder'));
      await tester.pump();
      expect(actionTapped, isTrue);
    });

    testWidgets('PriorityBadge renders High, Medium, and Low priorities',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PriorityBadge(priority: PriorityLevel.high),
                PriorityBadge(priority: PriorityLevel.medium),
                PriorityBadge(priority: PriorityLevel.low),
              ],
            ),
          ),
        ),
      );

      expect(find.text('High Priority'), findsOneWidget);
      expect(find.text('Medium Priority'), findsOneWidget);
      expect(find.text('Low Priority'), findsOneWidget);
    });

    testWidgets('CategoryChip displays icon and responds to user selection',
        (tester) async {
      bool tapped = false;
      final testCat = CategoryItem.defaultCategories.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChip(
              category: testCat,
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text(testCat.name), findsOneWidget);
      await tester.tap(find.text(testCat.name));
      expect(tapped, isTrue);
    });

    testWidgets('CustomButton renders label and triggers onPressed',
        (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Save Activity',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Save Activity'), findsOneWidget);
      await tester.tap(find.text('Save Activity'));
      expect(pressed, isTrue);
    });

    testWidgets('ReminderCard displays title, time, and category in MultiProvider context',
        (tester) async {
      final now = DateTime.now();
      final testReminder = Reminder(
        id: 'test_card_1',
        title: 'Design Review Standup',
        dueDate: DateTime(now.year, now.month, now.day),
        dueTime: const TimeOfDay(hour: 10, minute: 30),
        categoryId: 'work',
        priority: PriorityLevel.high,
        notificationId: 999,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            ChangeNotifierProvider(create: (_) => ReminderProvider(autoLoad: false)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ReminderCard(reminder: testReminder),
            ),
          ),
        ),
      );

      expect(find.text('Design Review Standup'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('AddEditReminderScreen validates empty title on submit',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            ChangeNotifierProvider(create: (_) => ReminderProvider(autoLoad: false)),
          ],
          child: const MaterialApp(
            home: AddEditReminderScreen(),
          ),
        ),
      );

      expect(find.text('New Reminder'), findsOneWidget);
      expect(find.text('Create Reminder'), findsOneWidget);

      // Tap submit with empty title
      await tester.tap(find.text('Create Reminder'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a reminder title.'), findsOneWidget);
    });
  });
}
