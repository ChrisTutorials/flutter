import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/screens/settings_screen.dart';
import '../../lib/services/unit_settings_service.dart';
import '../../lib/services/theme_service.dart';

void main() {
  group('Unit Settings UI Tests', () {
    late ThemeController themeController;

    setUp(() async {
      themeController = ThemeController();
      await themeController.load();
      // Reset to defaults before each test
      await UnitSettingsService.resetToDefaults();
    });

    testWidgets('should show unit visibility card in settings', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            themeController: themeController,
            widgetAvailable: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show the unit visibility card
      expect(find.text('Unit visibility'), findsOneWidget);
      expect(find.text('Hide low-value units that you rarely use to simplify conversion lists.'), findsOneWidget);
    });

    testWidgets('should show toggle switches for low-value units', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            themeController: themeController,
            widgetAvailable: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show toggle switches for default low-value units
      expect(find.text('Micrometer'), findsOneWidget);
      expect(find.text('Milligram'), findsOneWidget);
      expect(find.text('Square Millimeter'), findsOneWidget);
      expect(find.text('Pinch'), findsOneWidget);
      expect(find.text('Dash'), findsOneWidget);
      expect(find.text('Bit'), findsOneWidget);
    });

    testWidgets('should show correct initial states for unit toggles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            themeController: themeController,
            widgetAvailable: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find all the switch widgets
      final switches = find.byType(SwitchListTile);
      expect(switches, findsAtLeastNWidgets(6));

      // All should be in "off" position (units are hidden by default)
      for (int i = 0; i < 6; i++) {
        final switchTile = tester.widget<SwitchListTile>(switches.at(i));
        expect(switchTile.value, false); // Switch is off = unit is hidden
      }

      // Should show "Hidden" subtitle for all
      expect(find.text('Hidden'), findsAtLeastNWidgets(6));
    });

    testWidgets('should toggle unit visibility when switch is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            themeController: themeController,
            widgetAvailable: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Micrometer switch
      final micrometerSwitch = find.ancestor(
        of: find.text('Micrometer'),
        matching: find.byType(SwitchListTile),
      );
      expect(micrometerSwitch, findsOneWidget);

      // Initially should be off (hidden)
      expect(find.text('Hidden'), findsAtLeastNWidgets(1));
      
      // Tap the switch to enable Micrometer
      await tester.tap(micrometerSwitch);
      await tester.pumpAndSettle();

      // Should now show "Visible" for Micrometer
      final micrometerVisible = find.ancestor(
        of: find.text('Micrometer'),
        matching: find.text('Visible'),
      );
      expect(micrometerVisible, findsOneWidget);

      // Verify the setting was actually changed
      expect(await UnitSettingsService.isUnitHidden('Micrometer'), false);
    });

    testWidgets('should show reset button and reset functionality', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            themeController: themeController,
            widgetAvailable: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show reset button
      expect(find.text('Reset to defaults'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Enable a unit first
      final micrometerSwitch = find.ancestor(
        of: find.text('Micrometer'),
        matching: find.byType(SwitchListTile),
      );
      await tester.tap(micrometerSwitch);
      await tester.pumpAndSettle();

      // Verify unit is enabled
      expect(find.text('Visible'), findsAtLeastNWidgets(1));

      // Tap reset button
      final resetButton = find.text('Reset to defaults');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Should reset back to hidden
      expect(find.text('Hidden'), findsAtLeastNWidgets(6));
      expect(find.text('Visible'), findsNothing);
    });

    testWidgets('should handle multiple unit toggles independently', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            themeController: themeController,
            widgetAvailable: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enable Micrometer
      final micrometerSwitch = find.ancestor(
        of: find.text('Micrometer'),
        matching: find.byType(SwitchListTile),
      );
      await tester.tap(micrometerSwitch);
      await tester.pumpAndSettle();

      // Enable Bit
      final bitSwitch = find.ancestor(
        of: find.text('Bit'),
        matching: find.byType(SwitchListTile),
      );
      await tester.tap(bitSwitch);
      await tester.pumpAndSettle();

      // Should show 2 visible units, 4 hidden
      expect(find.text('Visible'), findsExactly(2));
      expect(find.text('Hidden'), findsExactly(4));

      // Verify settings
      expect(await UnitSettingsService.isUnitHidden('Micrometer'), false);
      expect(await UnitSettingsService.isUnitHidden('Bit'), false);
      expect(await UnitSettingsService.isUnitHidden('Milligram'), true);
      expect(await UnitSettingsService.isUnitHidden('Square Millimeter'), true);
      expect(await UnitSettingsService.isUnitHidden('Pinch'), true);
      expect(await UnitSettingsService.isUnitHidden('Dash'), true);
    });

    testWidgets('should show loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            themeController: themeController,
            widgetAvailable: false,
          ),
        ),
      );

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Should show content after loading
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Unit visibility'), findsOneWidget);
    });

    testWidgets('should handle rapid toggle changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            themeController: themeController,
            widgetAvailable: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final micrometerSwitch = find.ancestor(
        of: find.text('Micrometer'),
        matching: find.byType(SwitchListTile),
      );

      // Rapidly toggle multiple times
      for (int i = 0; i < 5; i++) {
        await tester.tap(micrometerSwitch);
        await tester.pump(); // Don't wait for settle to simulate rapid taps
      }
      await tester.pumpAndSettle();

      // Should handle gracefully and show final state
      expect(find.text('Micrometer'), findsOneWidget);
      final subtitle = find.ancestor(
        of: find.text('Micrometer'),
        matching: find.text('Hidden'), // or 'Visible' depending on final state
      );
      expect(subtitle, findsOneWidget);
    });
  });
}

