import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/screens/custom_units_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('custom units screen markets differentiator and empty state', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CustomUnitsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Make the converter yours'), findsOneWidget);
    expect(
      find.textContaining('desktop, web, and mobile layouts'),
      findsOneWidget,
    );
    expect(
      find.textContaining('competitors usually do not cover'),
      findsOneWidget,
    );
  });
}
