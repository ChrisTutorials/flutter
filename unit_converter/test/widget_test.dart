import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/main.dart';
import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/services/favorite_conversions_service.dart';
import 'package:unit_converter/services/theme_service.dart';
import 'package:unit_converter/screens/conversion_screen.dart';
import 'package:unit_converter/screens/category_selection_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('length conversion covers imperial to metric', () {
    final milesToKm = ConversionData.convert(
      1,
      ConversionData.lengthCategory.units.firstWhere(
        (unit) => unit.symbol == 'mi',
      ),
      ConversionData.lengthCategory.units.firstWhere(
        (unit) => unit.symbol == 'km',
      ),
      ConversionData.lengthCategory.name,
    );

    expect(milesToKm, closeTo(1.609344, 0.000001));
  });

  test('volume conversion covers imperial gallon to liters', () {
    final gallonsToLiters = ConversionData.convert(
      1,
      ConversionData.volumeCategory.units.firstWhere(
        (unit) => unit.symbol == 'gal',
      ),
      ConversionData.volumeCategory.units.firstWhere(
        (unit) => unit.symbol == 'L',
      ),
      ConversionData.volumeCategory.name,
    );

    expect(gallonsToLiters, closeTo(3.785411784, 0.000001));
  });

  test('temperature conversion handles fahrenheit to celsius', () {
    final fahrenheitToCelsius = ConversionData.convert(
      212,
      ConversionData.temperatureCategory.units.firstWhere(
        (unit) => unit.symbol == '°F',
      ),
      ConversionData.temperatureCategory.units.firstWhere(
        (unit) => unit.symbol == '°C',
      ),
      ConversionData.temperatureCategory.name,
    );

    expect(fahrenheitToCelsius, closeTo(100, 0.000001));
  });

  testWidgets('converter screen updates result as user types', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConversionScreen(category: ConversionData.lengthCategory),
      ),
    );

    expect(find.text('Live conversion'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Available units'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Available units'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '10');
    await tester.pump();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 300));
    await tester.pumpAndSettle();

    final outputField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) => widget is TextField && widget.readOnly,
      ),
    );
    expect(outputField.controller?.text, '0.01');
  });

  testWidgets('app home shows presets and currency tool', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategorySelectionScreen(themeController: ThemeController()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quick presets'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
  });

  testWidgets('home search filters converters and presets', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategorySelectionScreen(themeController: ThemeController()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pressure'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('home_search_field')),
      'travel',
    );
    await tester.pumpAndSettle();

    expect(find.text('USD to EUR'), findsOneWidget);
    expect(find.text('Length'), findsNothing);
    expect(find.text('Pressure'), findsNothing);
  });

  testWidgets('home shows favorites section when saved favorites exist', (
    tester,
  ) async {
    final service = FavoriteConversionsService();
    await service.toggleFavorite(
      categoryName: 'Length',
      fromSymbol: 'm',
      toSymbol: 'ft',
      title: 'Length: m to ft',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CategorySelectionScreen(themeController: ThemeController()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Length: m to ft'), findsOneWidget);
  });
}
