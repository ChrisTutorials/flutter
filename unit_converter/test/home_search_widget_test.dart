import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/screens/category_selection_screen.dart';
import 'package:unit_converter/services/recent_conversions_service.dart';
import 'package:unit_converter/services/theme_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('home search discovery', () {
    final scenarios = <({String query, String visibleText, String hiddenText})>[
      (query: 'travel', visibleText: 'USD to EUR', hiddenText: 'Pressure'),
      (query: 'psi', visibleText: 'Pressure', hiddenText: 'Length'),
      (query: 'fahrenheit', visibleText: 'Temperature', hiddenText: 'Volume'),
      (query: 'kilobyte', visibleText: 'Data', hiddenText: 'Time'),
      (query: 'ft to m', visibleText: 'Length', hiddenText: 'Pressure'),
    ];

    for (final scenario in scenarios) {
      testWidgets('finds results for ${scenario.query}', (tester) async {
        await _pumpHome(tester);

        await tester.enterText(
          find.byKey(const Key('home_search_field')),
          scenario.query,
        );
        await tester.pumpAndSettle();

        expect(find.text(scenario.visibleText), findsWidgets);
        expect(find.text(scenario.hiddenText), findsNothing);
      });
    }
  });

  group('home search instant conversions', () {
    final scenarios = <({String query, String resultText, String category})>[
      (
        query: '60g to lb',
        resultText: '60 g = 0.13227736 lb',
        category: 'Weight',
      ),
      (query: '32 F to C', resultText: '32 °F = 0 °C', category: 'Temperature'),
      (
        query: '2 liters to mL',
        resultText: '2 L = 2000 mL',
        category: 'Volume',
      ),
      (
        query: '20 gal l',
        resultText: '20 gal = 75.70823568 L',
        category: 'Volume',
      ),
    ];

    for (final scenario in scenarios) {
      testWidgets('shows instant conversion for ${scenario.query}', (
        tester,
      ) async {
        await _pumpHome(tester);

        await tester.enterText(
          find.byKey(const Key('home_search_field')),
          scenario.query,
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('instant_conversion_card')),
          findsOneWidget,
        );
        expect(find.text(scenario.resultText), findsOneWidget);
        expect(find.text(scenario.category), findsWidgets);
      });
    }

    testWidgets('submitting an instant conversion opens the converter', (
      tester,
    ) async {
      await _pumpHome(tester);

      await tester.enterText(
        find.byKey(const Key('home_search_field')),
        '20 gal l',
      );
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('20 gal to L'), findsOneWidget);
      expect(find.text('Live conversion'), findsOneWidget);
    });
  });

  testWidgets('home history section is reachable by scrolling', (tester) async {
    final recentConversionsService = RecentConversionsService();
    final recentConversions = <RecentConversion>[
      RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'ft',
        inputValue: 1,
        outputValue: 3.280839895,
        timestamp: DateTime(2026, 3, 11, 9, 0),
      ),
      RecentConversion(
        category: 'Weight',
        fromUnit: 'kg',
        toUnit: 'lb',
        inputValue: 5,
        outputValue: 11.02311311,
        timestamp: DateTime(2026, 3, 11, 9, 5),
      ),
      RecentConversion(
        category: 'Pressure',
        fromUnit: 'psi',
        toUnit: 'bar',
        inputValue: 30,
        outputValue: 2.068427188,
        timestamp: DateTime(2026, 3, 11, 9, 10),
      ),
    ];

    for (final conversion in recentConversions) {
      await recentConversionsService.saveConversion(conversion);
    }

    await _pumpHome(tester, size: const Size(390, 844));

    final historyFinder = find.byKey(const Key('home_history_section'));
    final beforeScrollDy = tester.getTopLeft(historyFinder).dy;

    await tester.scrollUntilVisible(
      historyFinder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final afterScrollDy = tester.getTopLeft(historyFinder).dy;

    expect(beforeScrollDy, greaterThan(700));
    expect(afterScrollDy, lessThan(700));
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Pressure • Mar 11, 9:10 AM'), findsOneWidget);
  });
}

Future<void> _pumpHome(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: CategorySelectionScreen(themeController: ThemeController()),
    ),
  );
  await tester.pumpAndSettle();
}
