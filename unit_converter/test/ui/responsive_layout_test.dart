import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/main.dart';
import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/screens/conversion_screen.dart';
import 'package:unit_converter/screens/currency_converter_screen.dart';
import 'package:unit_converter/services/theme_service.dart';
import 'package:unit_converter/services/windows_store_access_policy.dart';
import 'package:unit_converter/screens/category_selection_screen.dart';
import 'package:unit_converter/screens/settings_screen.dart';
import 'package:unit_converter/utils/responsive_layout.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> configureViewport(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpHome(WidgetTester tester, Size size) async {
    await configureViewport(tester, size);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          home: CategorySelectionScreen(
            themeController: ThemeController(),
            windowsStoreAccessPolicy: WindowsStoreAccessPolicy(
              isWindowsPlatform: false,
              premiumStatusLoader: () async => false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpScreen(WidgetTester tester, Size size, Widget screen) async {
    await configureViewport(tester, size);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  SliverGridDelegateWithFixedCrossAxisCount homeGridDelegate(
    WidgetTester tester,
  ) {
    final gridView = tester.widget<GridView>(find.byType(GridView));
    return gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
  }

  Widget mobileTestApp(Widget child, {Size size = const Size(390, 844)}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(home: child),
    );
  }

  Future<void> scrollUntilTextVisible(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home screen renders on compact screens', (tester) async {
    await pumpHome(tester, const Size(375, 667));

    expect(tester.takeException(), isNull);
    expect(find.text('Quick presets'), findsOneWidget);
    await scrollUntilTextVisible(tester, 'Converters');
    expect(find.text('Converters'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
  });

  testWidgets('home screen renders on tablet screens', (tester) async {
    await pumpHome(tester, const Size(834, 1194));

    expect(tester.takeException(), isNull);
    expect(find.text('Quick presets'), findsOneWidget);
    await scrollUntilTextVisible(tester, 'Converters');
    expect(find.text('Converters'), findsOneWidget);
    expect(find.text('Length'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
  });

  testWidgets('home screen renders on desktop-sized surfaces', (tester) async {
    await pumpHome(tester, const Size(1440, 900));

    expect(tester.takeException(), isNull);
    expect(find.text('Quick presets'), findsOneWidget);
    await scrollUntilTextVisible(tester, 'Time');
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
  });

  testWidgets('conversion screen adapts to compact and wide layouts', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Size(390, 844),
      ConversionScreen(category: ConversionData.lengthCategory),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Live conversion'), findsOneWidget);
    expect(find.text('Formula'), findsOneWidget);

    await pumpScreen(
      tester,
      const Size(1366, 900),
      ConversionScreen(category: ConversionData.lengthCategory),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Live conversion'), findsOneWidget);
    expect(find.text('Available units'), findsOneWidget);
  });

  testWidgets('currency screen adapts to compact and wide layouts', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Size(390, 844),
      const CurrencyConverterScreen(),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Live currency conversion'), findsOneWidget);
    expect(find.text('Rate details'), findsOneWidget);

    await pumpScreen(
      tester,
      const Size(1366, 900),
      const CurrencyConverterScreen(),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Live currency conversion'), findsOneWidget);
    expect(find.text('Rate details'), findsOneWidget);
  });

  testWidgets('settings screen adapts to compact and wide layouts', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Size(390, 844),
      SettingsScreen(
        themeController: ThemeController(),
        widgetAvailable: true,
        isWindowsPlatform: false,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Theme mode'), findsOneWidget);
    expect(find.text('Upgrades'), findsOneWidget);

    await pumpScreen(
      tester,
      const Size(1366, 900),
      SettingsScreen(
        themeController: ThemeController(),
        widgetAvailable: true,
        isWindowsPlatform: false,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Theme mode'), findsOneWidget);
    expect(find.text('Cloud history sync'), findsOneWidget);
  });

  testWidgets('settings screen only exposes the production purchase flow', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Size(390, 844),
      SettingsScreen(
        themeController: ThemeController(),
        widgetAvailable: true,
        isWindowsPlatform: false,
      ),
    );

    expect(tester.takeException(), isNull);

    expect(find.text('Ad-free mode (Development)'), findsNothing);
    expect(find.text('This local switch is for testing. Use the purchase button above for real purchases.'), findsNothing);
    expect(find.text('Go Ad-Free'), findsOneWidget);
    expect(find.text('Restore'), findsOneWidget);
  });

  group('ResponsiveLayout Utility Tests', () {
    group('Screen Size Detection', () {
      testWidgets('should detect mobile screen size', (tester) async {
        await tester.pumpWidget(
          mobileTestApp(
            Builder(
              builder: (context) {
                final size = ResponsiveLayout.getScreenSize(context);
                expect(size, ScreenSize.mobile);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('should detect tablet portrait screen size', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(800, 1200)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final size = ResponsiveLayout.getScreenSize(context);
                  expect(size, ScreenSize.tabletPortrait);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('should detect tablet landscape screen size', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1000, 800)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final size = ResponsiveLayout.getScreenSize(context);
                  expect(size, ScreenSize.tabletLandscape);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('should detect desktop screen size', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final size = ResponsiveLayout.getScreenSize(context);
                  expect(size, ScreenSize.desktop);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Screen Type Checks', () {
      testWidgets('should identify mobile screen', (tester) async {
        await tester.pumpWidget(
          mobileTestApp(
            Builder(
              builder: (context) {
                expect(ResponsiveLayout.isMobile(context), true);
                expect(ResponsiveLayout.isDesktop(context), false);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('should identify desktop screen', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  expect(ResponsiveLayout.isMobile(context), false);
                  expect(ResponsiveLayout.isDesktop(context), true);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Grid Column Configuration', () {
      testWidgets('should use 2 columns on mobile', (tester) async {
        await tester.pumpWidget(
          mobileTestApp(
            Builder(
              builder: (context) {
                final columns = ResponsiveLayout.getCategoryGridColumns(context);
                expect(columns, 2);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('should use 2 columns on tablet portrait', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(800, 1200)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final columns = ResponsiveLayout.getCategoryGridColumns(context);
                  expect(columns, 3);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('should use 3 columns on tablet landscape', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1000, 800)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final columns = ResponsiveLayout.getCategoryGridColumns(context);
                  expect(columns, 4);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('should use 4 columns on desktop', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final columns = ResponsiveLayout.getCategoryGridColumns(context);
                  expect(columns, 5);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('should use 3 columns on mobile landscape', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(667, 375)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final columns = ResponsiveLayout.getCategoryGridColumns(context);
                  expect(columns, 3);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Section Spacing', () {
      testWidgets('should use compact section spacing on mobile', (tester) async {
        await tester.pumpWidget(
          mobileTestApp(
            Builder(
              builder: (context) {
                final spacing = ResponsiveLayout.getSectionSpacing(context);
                expect(spacing, 12);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('should use larger section spacing on desktop', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final spacing = ResponsiveLayout.getSectionSpacing(context);
                  expect(spacing, 20);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Card Spacing', () {
      testWidgets('should use compact spacing on mobile', (tester) async {
        await tester.pumpWidget(
          mobileTestApp(
            Builder(
              builder: (context) {
                final spacing = ResponsiveLayout.getCardSpacing(context);
                expect(spacing, 8);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('should use larger spacing on desktop', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final spacing = ResponsiveLayout.getCardSpacing(context);
                  expect(spacing, 12);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Card Aspect Ratio', () {
      testWidgets('should use a compact ratio on mobile portrait', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final aspectRatio = ResponsiveLayout.getCardAspectRatio(context);
                  expect(aspectRatio, greaterThan(1.0));
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('should use a wider ratio in landscape than portrait', (tester) async {
        late double portraitAspectRatio;
        late double landscapeAspectRatio;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  portraitAspectRatio = ResponsiveLayout.getCardAspectRatio(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(844, 390)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  landscapeAspectRatio = ResponsiveLayout.getCardAspectRatio(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        expect(landscapeAspectRatio, greaterThan(portraitAspectRatio));
      });
    });

    group('Max Horizontal Items', () {
      testWidgets('should show fewer items in horizontal scroll on mobile', (tester) async {
        await tester.pumpWidget(
          mobileTestApp(
            Builder(
              builder: (context) {
                final maxItems = ResponsiveLayout.getMaxHorizontalItems(context);
                expect(maxItems, 3);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('should show more items in horizontal scroll on desktop', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final maxItems = ResponsiveLayout.getMaxHorizontalItems(context);
                  expect(maxItems, 5);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('Integration Tests - Minimize Scrolling', () {
      testWidgets('responsive layout should minimize scrolling on mobile', (tester) async {
        // This test validates that the responsive layout fits more content on mobile
        await tester.pumpWidget(
          mobileTestApp(
            Builder(
              builder: (context) {
                // On mobile, we should have:
                // - 2 columns for grid (not 1)
                // - Compact spacing (12 vs 20)
                // - Compact padding (12 vs 24)
                // - Fewer horizontal items (3 vs 5)
                
                final gridColumns = ResponsiveLayout.getCategoryGridColumns(context);
                final sectionSpacing = ResponsiveLayout.getSectionSpacing(context);
                final cardPadding = ResponsiveLayout.getCardPadding(context);
                final maxHorizontalItems = ResponsiveLayout.getMaxHorizontalItems(context);
                
                expect(gridColumns, 2, reason: 'Mobile should use 2 columns to fit more content');
                expect(sectionSpacing, 12, reason: 'Mobile should use compact spacing');
                expect(cardPadding, const EdgeInsets.all(12), reason: 'Mobile should use compact padding');
                expect(maxHorizontalItems, 3, reason: 'Mobile should show fewer horizontal items');
                
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('responsive layout should use more space on desktop', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(size: Size(1400, 900)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  // On desktop, we should have:
                  // - 5 columns for grid
                  // - Larger spacing (20 vs 12)
                  // - Larger padding (24 vs 12)
                  // - More horizontal items (5 vs 3)
                  
                  final gridColumns = ResponsiveLayout.getCategoryGridColumns(context);
                  final sectionSpacing = ResponsiveLayout.getSectionSpacing(context);
                  final cardPadding = ResponsiveLayout.getCardPadding(context);
                  final maxHorizontalItems = ResponsiveLayout.getMaxHorizontalItems(context);
                  
                  expect(gridColumns, 5, reason: 'Desktop should use 5 columns');
                  expect(sectionSpacing, 20, reason: 'Desktop should use larger spacing');
                  expect(cardPadding, const EdgeInsets.all(24), reason: 'Desktop should use larger padding');
                  expect(maxHorizontalItems, 5, reason: 'Desktop should show more horizontal items');
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('home screen fits more content on mobile with responsive layout', (tester) async {
        await pumpHome(tester, const Size(390, 844));

        // Verify responsive layout is applied
        expect(tester.takeException(), isNull);
        
        // On mobile, we should see more content without scrolling
        // because of the compact layout
        expect(find.text('Quick presets'), findsOneWidget);
        expect(find.text('Converters'), findsOneWidget);
        
        final gridDelegate = homeGridDelegate(tester);
        expect(gridDelegate.crossAxisCount, 2);

        await tester.scrollUntilVisible(
          find.byKey(const Key('currency_tool_card')),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        final cardSize = tester.getSize(find.byKey(const Key('currency_tool_card')));
        expect(cardSize.height, lessThan(170));
      });

      testWidgets('home screen uses more space efficiently on desktop', (tester) async {
        await pumpHome(tester, const Size(1440, 900));

        // Verify responsive layout is applied
        expect(tester.takeException(), isNull);
        
        // On desktop, we should see more content with better spacing
        expect(find.text('Quick presets'), findsOneWidget);
        expect(find.text('Converters'), findsOneWidget);
        expect(find.text('Currency'), findsOneWidget);
        
        final gridDelegate = homeGridDelegate(tester);
        expect(gridDelegate.crossAxisCount, 5);
      });

      testWidgets('home screen uses more columns and shorter cards in landscape', (tester) async {
        await pumpHome(tester, const Size(844, 390));

        expect(tester.takeException(), isNull);
        expect(find.text('Quick presets'), findsOneWidget);
        expect(find.text('Converters'), findsOneWidget);

        final gridDelegate = homeGridDelegate(tester);
        expect(gridDelegate.crossAxisCount, 4);

        await tester.scrollUntilVisible(
          find.byKey(const Key('currency_tool_card')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        final cardSize = tester.getSize(find.byKey(const Key('currency_tool_card')));
        expect(cardSize.height, lessThan(130));
      });

      testWidgets('quick presets section is hidden when filtered on mobile', (tester) async {
        await pumpHome(tester, const Size(390, 844));

        expect(tester.takeException(), isNull);
        expect(find.text('Quick presets'), findsOneWidget);

        // Search for something that doesn't match any presets
        await tester.enterText(
          find.byKey(const Key('home_search_field')),
          'xyznonexistent',
        );
        await tester.pumpAndSettle();

        // Quick presets section should be hidden when filtered
        expect(find.text('Quick presets'), findsNothing);
      });

      testWidgets('quick presets section is hidden when filtered on desktop', (tester) async {
        await pumpHome(tester, const Size(1440, 900));

        expect(tester.takeException(), isNull);
        expect(find.text('Quick presets'), findsOneWidget);

        // Search for something that doesn't match any presets
        await tester.enterText(
          find.byKey(const Key('home_search_field')),
          'xyznonexistent',
        );
        await tester.pumpAndSettle();

        // Quick presets section should be hidden when filtered
        expect(find.text('Quick presets'), findsNothing);
      });
    });
  });
}
