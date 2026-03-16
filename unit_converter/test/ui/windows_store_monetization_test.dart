import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/screens/category_selection_screen.dart';
import 'package:unit_converter/services/theme_service.dart';
import 'package:unit_converter/services/windows_store_access_policy.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Windows free tier shows locked premium messaging', (tester) async {
    final policy = WindowsStoreAccessPolicy(
      isWindowsPlatform: true,
      premiumStatusLoader: () async => false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CategorySelectionScreen(
          themeController: ThemeController(),
          windowsStoreAccessPolicy: policy,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Premium on Windows'), findsNothing);
    expect(find.byIcon(Icons.workspace_premium), findsWidgets);
    expect(find.text('Length'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
  });

  testWidgets('tapping locked Windows currency card opens upgrade dialog', (
    tester,
  ) async {
    final policy = WindowsStoreAccessPolicy(
      isWindowsPlatform: true,
      premiumStatusLoader: () async => false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CategorySelectionScreen(
          themeController: ThemeController(),
          windowsStoreAccessPolicy: policy,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('currency_tool_card')));
    await tester.pumpAndSettle();

    expect(find.text('Currency is part of Premium'), findsOneWidget);
    expect(find.text('Unlock Premium'), findsOneWidget);
    expect(find.text('Maybe later'), findsOneWidget);
  });

  testWidgets('non-Windows flow keeps currency tool unlocked', (tester) async {
    final policy = WindowsStoreAccessPolicy(
      isWindowsPlatform: false,
      premiumStatusLoader: () async => false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CategorySelectionScreen(
          themeController: ThemeController(),
          windowsStoreAccessPolicy: policy,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Premium on Windows'), findsNothing);
    expect(find.text('Live rates via Frankfurter'), findsOneWidget);
  });
}
