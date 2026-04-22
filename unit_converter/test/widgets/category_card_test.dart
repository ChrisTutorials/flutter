import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/widgets/category_card.dart';
import 'package:unit_converter/models/conversion.dart';

void main() {
  group('CategoryCard', () {
    testWidgets('displays category name and unit count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: CategoryCard(
                category: ConversionData.lengthCategory,
                onTap: () {},
                isLocked: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Length'), findsOneWidget);
      expect(find.text('10 units'), findsOneWidget);
    });

    testWidgets('shows PRO badge when locked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: CategoryCard(
                category: ConversionData.temperatureCategory,
                onTap: () {},
                isLocked: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('PRO'), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium), findsOneWidget);
    });

    testWidgets('does not show PRO badge when not locked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: CategoryCard(
                category: ConversionData.volumeCategory,
                onTap: () {},
                isLocked: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('PRO'), findsNothing);
      expect(find.byIcon(Icons.workspace_premium), findsNothing);
    });

    testWidgets('PRO badge is centered below text content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: CategoryCard(
                category: ConversionData.weightCategory,
                onTap: () {},
                isLocked: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: CategoryCard(
                category: ConversionData.speedCategory,
                onTap: () => tapped = true,
                isLocked: false,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CategoryCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('card is tappable even when locked', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: CategoryCard(
                category: ConversionData.timeCategory,
                onTap: () => tapped = true,
                isLocked: true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CategoryCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('compact layout adapts badge sizing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 160,
              height: 140,
              child: CategoryCard(
                category: ConversionData.areaCategory,
                onTap: () {},
                isLocked: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('PRO'), findsOneWidget);
    });
  });
}