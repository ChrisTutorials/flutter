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

  testWidgets('bottom banner slot respects Android system navigation bar', (
    tester,
  ) async {
    // Simulate Android device with system navigation bar
    const systemBottomPadding = 48.0; // Typical Android navigation bar height

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(bottom: systemBottomPadding),
        ),
        child: MaterialApp(
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
      ),
    );

    await tester.pumpAndSettle();

    // Find the banner ad container
    final bannerContainer = find.byKey(const Key('banner_ad_container'));
    expect(bannerContainer, findsOneWidget);

    // Get the position of the banner ad
    final bannerPosition = tester.getTopLeft(bannerContainer);
    final bannerSize = tester.getSize(bannerContainer);
    final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;

    // The banner should be positioned above the system navigation bar
    // Calculate expected bottom position: screenHeight - systemBottomPadding - 8 (extra padding)
    final expectedBannerBottom = screenHeight - systemBottomPadding - 8;
    final actualBannerBottom = bannerPosition.dy + bannerSize.height;

    // The banner should not overlap with the system navigation bar
    expect(actualBannerBottom, lessThanOrEqualTo(expectedBannerBottom),
      reason: 'Banner ad should be positioned above the Android system navigation bar. '
               'Expected bottom: $expectedBannerBottom, Actual bottom: $actualBannerBottom',
    );
  });

  testWidgets('bottom banner slot with system padding adds safe bottom margin', (
    tester,
  ) async {
    // Simulate Android device with system navigation bar
    const systemBottomPadding = 48.0;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(bottom: systemBottomPadding),
        ),
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: SizedBox.expand()),
                BottomBannerSlot(
                  bannerSize: AdSize.banner,
                  bannerChild: Container(
                    color: Colors.red,
                    child: const Text('Ad'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find the banner ad container
    final bannerContainer = find.byKey(const Key('banner_ad_container'));
    expect(bannerContainer, findsOneWidget);

    // Get the bottom padding widget (Padding widget wrapping the banner)
    final paddingWidget = tester.widget<Padding>(find.ancestor(
      of: bannerContainer,
      matching: find.byType(Padding),
    ).first);

    // The padding should include system bottom padding
    // Current implementation only adds 8 pixels (the bug)
    // After fix, it should be 8 + systemBottomPadding
    final expectedBottomPadding = 8.0 + systemBottomPadding;
    final actualBottomPadding = (paddingWidget.padding as EdgeInsets).bottom;

    // This test will fail initially, demonstrating the bug
    expect(actualBottomPadding, equals(expectedBottomPadding),
      reason: 'Banner slot should add padding for system navigation bar',
    );
  });
}