import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unit_converter/widgets/currency_input_row.dart';
import 'package:unit_converter/widgets/recent_conversion_card.dart';
import 'package:unit_converter/widgets/favorite_conversion_card.dart';
import 'package:unit_converter/widgets/preset_card.dart';
import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/models/favorite_conversion.dart';
import 'package:unit_converter/models/quick_preset.dart';

void main() {
  group('Currency Name Helpers', () {
    testWidgets('CurrencyInputRow shows currency name next to code in dropdown, but only acronym in selected value', (tester) async {
      final controller = TextEditingController(text: '100');
      const currencies = {
        'USD': 'US Dollar',
        'EUR': 'Euro',
        'GBP': 'British Pound',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencyInputRow(
              label: 'From',
              controller: controller,
              selectedCode: 'USD',
              items: currencies,
              onChanged: (_) {},
              onCurrencyChanged: (_) {},
              readOnly: false,
            ),
          ),
        ),
      );

      // Verify selected value shows only acronym
      expect(find.text('USD'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('RecentConversionCard shows currency names in tooltip for currency conversions', (tester) async {
      final conversion = RecentConversion(
        category: 'Currency',
        fromUnit: 'USD',
        toUnit: 'EUR',
        inputValue: 100.0,
        outputValue: 92.0,
        timestamp: DateTime.now(),
      );
      const currencyNames = {
        'USD': 'US Dollar',
        'EUR': 'Euro',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentConversionCard(
              conversion: conversion,
              onDelete: () {},
              currencyNames: currencyNames,
            ),
          ),
        ),
      );

      // Find the tooltip widget
      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);

      // Verify tooltip message contains currency names
      final tooltip = tester.widget<Tooltip>(tooltipFinder);
      expect(tooltip.message, contains('USD (US Dollar)'));
      expect(tooltip.message, contains('EUR (Euro)'));
    });

    testWidgets('RecentConversionCard does not show currency names in tooltip for non-currency conversions', (tester) async {
      final conversion = RecentConversion(
        category: 'Temperature',
        fromUnit: '°F',
        toUnit: '°C',
        inputValue: 72.0,
        outputValue: 22.2,
        timestamp: DateTime.now(),
      );
      const currencyNames = {
        'USD': 'US Dollar',
        'EUR': 'Euro',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentConversionCard(
              conversion: conversion,
              onDelete: () {},
              currencyNames: currencyNames,
            ),
          ),
        ),
      );

      // Find the tooltip widget
      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);

      // Verify tooltip message does not contain currency names
      final tooltip = tester.widget<Tooltip>(tooltipFinder);
      expect(tooltip.message, isNot(contains('US Dollar')));
      expect(tooltip.message, isNot(contains('Euro')));
    });

    testWidgets('FavoriteConversionCard shows currency names in tooltip for currency conversions', (tester) async {
      final favorite = FavoriteConversion(
        categoryName: 'Currency',
        fromSymbol: 'USD',
        toSymbol: 'EUR',
        title: 'USD to EUR',
        createdAt: DateTime.now(),
      );
      const currencyNames = {
        'USD': 'US Dollar',
        'EUR': 'Euro',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavoriteConversionCard(
              favorite: favorite,
              onTap: () {},
              onRemove: () {},
              currencyNames: currencyNames,
            ),
          ),
        ),
      );

      // Find the tooltip widget - there are 2 tooltips (one for text, one for remove button)
      final tooltipFinders = find.byType(Tooltip);
      expect(tooltipFinders, findsNWidgets(2));

      // Get the tooltip that contains currency names (not the "Remove favorite" one)
      Tooltip? currencyTooltip;
      for (final element in tooltipFinders.evaluate()) {
        final tooltip = element.widget as Tooltip;
        if (tooltip.message != 'Remove favorite') {
          currencyTooltip = tooltip;
          break;
        }
      }

      expect(currencyTooltip, isNotNull);
      expect(currencyTooltip!.message, contains('USD (US Dollar)'));
      expect(currencyTooltip.message, contains('EUR (Euro)'));
    });

    testWidgets('FavoriteConversionCard does not show currency names in tooltip for non-currency conversions', (tester) async {
      final favorite = FavoriteConversion(
        categoryName: 'Temperature',
        fromSymbol: '°F',
        toSymbol: '°C',
        title: '°F to °C',
        createdAt: DateTime.now(),
      );
      const currencyNames = {
        'USD': 'US Dollar',
        'EUR': 'Euro',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FavoriteConversionCard(
              favorite: favorite,
              onTap: () {},
              onRemove: () {},
              currencyNames: currencyNames,
            ),
          ),
        ),
      );

      // Find the tooltip widget - there are 2 tooltips (one for text, one for remove button)
      final tooltipFinders = find.byType(Tooltip);
      expect(tooltipFinders, findsNWidgets(2));

      // Get the tooltip that contains currency names (not the "Remove favorite" one)
      Tooltip? currencyTooltip;
      for (final element in tooltipFinders.evaluate()) {
        final tooltip = element.widget as Tooltip;
        if (tooltip.message != 'Remove favorite') {
          currencyTooltip = tooltip;
          break;
        }
      }

      expect(currencyTooltip, isNotNull);
      expect(currencyTooltip!.message, isNot(contains('US Dollar')));
      expect(currencyTooltip.message, isNot(contains('Euro)')));
    });

    testWidgets('PresetCard shows currency names in tooltip for currency presets', (tester) async {
      const preset = QuickPreset.currency(
        label: 'USD to EUR',
        subtitle: 'Travel money',
        fromSymbol: 'USD',
        toSymbol: 'EUR',
        sampleValue: 1,
      );
      const currencyNames = {
        'USD': 'US Dollar',
        'EUR': 'Euro',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresetCard(
              preset: preset,
              onTap: () {},
              currencyNames: currencyNames,
            ),
          ),
        ),
      );

      // Find the tooltip widget
      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);

      // Verify tooltip message contains currency names
      final tooltip = tester.widget<Tooltip>(tooltipFinder);
      expect(tooltip.message, contains('USD (US Dollar)'));
      expect(tooltip.message, contains('EUR (Euro)'));
    });

    testWidgets('PresetCard does not show currency names in tooltip for non-currency presets', (tester) async {
      const preset = QuickPreset.standard(
        label: '°F to °C',
        subtitle: 'Weather checks',
        categoryName: 'Temperature',
        fromSymbol: '°F',
        toSymbol: '°C',
        sampleValue: 72,
      );
      const currencyNames = {
        'USD': 'US Dollar',
        'EUR': 'Euro',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PresetCard(
              preset: preset,
              onTap: () {},
              currencyNames: currencyNames,
            ),
          ),
        ),
      );

      // Find the tooltip widget
      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);

      // Verify tooltip message does not contain currency names
      final tooltip = tester.widget<Tooltip>(tooltipFinder);
      expect(tooltip.message, isNot(contains('US Dollar')));
      expect(tooltip.message, isNot(contains('Euro')));
    });

    testWidgets('RecentConversionCard handles unknown currency codes in tooltip', (tester) async {
      final conversion = RecentConversion(
        category: 'Currency',
        fromUnit: 'XXX',
        toUnit: 'YYY',
        inputValue: 100.0,
        outputValue: 92.0,
        timestamp: DateTime.now(),
      );
      const currencyNames = {
        'USD': 'US Dollar',
        'EUR': 'Euro',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentConversionCard(
              conversion: conversion,
              onDelete: () {},
              currencyNames: currencyNames,
            ),
          ),
        ),
      );

      // Find the tooltip widget
      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);

      // Verify tooltip message shows 'Unknown' for missing currencies
      final tooltip = tester.widget<Tooltip>(tooltipFinder);
      expect(tooltip.message, contains('XXX (Unknown)'));
      expect(tooltip.message, contains('YYY (Unknown)'));
    });
  });
}
