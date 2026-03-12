import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unit_converter/widgets/bottom_banner_slot.dart';

void main() {
  testWidgets('bottom banner slot constrains a live banner widget', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const Expanded(child: SizedBox.expand()),
              const BottomBannerSlot(
                bannerSize: AdSize.banner,
                bannerChild: Placeholder(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Placeholder), findsOneWidget);

    final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
    expect(
      sizedBoxes.any(
        (box) => box.height == AdSize.banner.height.toDouble(),
      ),
      isTrue,
    );
  });

  testWidgets('bottom banner slot shows a fixed-height debug placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BottomBannerSlot(showDebugPlaceholder: true),
        ),
      ),
    );

    expect(find.text('Banner Ad Placeholder'), findsOneWidget);

    final placeholderContainer = find.ancestor(
      of: find.text('Banner Ad Placeholder'),
      matching: find.byType(Container),
    ).first;
    expect(tester.getSize(placeholderContainer).height, greaterThanOrEqualTo(50));
  });
}