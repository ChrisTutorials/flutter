import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/main.dart';
import 'package:unit_converter/services/theme_service.dart';
import 'package:unit_converter/screens/currency_converter_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      UnitConverterApp(themeController: ThemeController()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home screen shows currency card', (tester) async {
    await pumpApp(tester);

    expect(find.text('Currency'), findsOneWidget);
    expect(find.byIcon(Icons.currency_exchange_rounded), findsWidgets);
  });

  testWidgets('navigates to currency converter from home card', (tester) async {
    await pumpApp(tester);

    final card = tester.widget<InkWell>(find.byKey(const Key('currency_tool_card')));
    card.onTap?.call();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Rate details'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Live currency conversion'), findsOneWidget);
    expect(find.text('Rate details'), findsOneWidget);
    expect(find.text('USD to EUR'), findsOneWidget);
  });

  testWidgets('currency screen renders standalone', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CurrencyConverterScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Rate details'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Live currency conversion'), findsOneWidget);
    expect(find.text('Rate details'), findsOneWidget);
  });
}
