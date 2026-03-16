import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unit_converter/widgets/bottom_banner_slot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String previousScreenshotsFolder;

  setUpAll(() {
    previousScreenshotsFolder = ScreenshotDevice.screenshotsFolder;
    ScreenshotDevice.screenshotsFolder = absoluteGoldenDirectory(
      projectAbsolutePath('test/golden_screenshots'),
    );
  });

  tearDownAll(() {
    ScreenshotDevice.screenshotsFolder = previousScreenshotsFolder;
  });

  group('Banner Ad Placement Screenshots', () {
    testGoldens('Banner ad above Android navigation bar', (tester) async {
      // Simulate Android device with system navigation bar
      const systemBottomPadding = 48.0;

      final device = ScreenshotDevice(
        platform: TargetPlatform.android,
        resolution: const Size(1080, 1920),
        pixelRatio: 1,
        goldenSubFolder: 'phoneScreenshots/',
        frameBuilder: ScreenshotFrame.androidPhone,
      );

      await tester.pumpWidget(
        ScreenshotApp(
          device: device,
          title: 'Banner Ad Placement Test',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: systemBottomPadding),
              viewPadding: EdgeInsets.only(bottom: systemBottomPadding),
            ),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Banner Ad Test'),
              ),
              body: Column(
                children: [
                  const Expanded(
                    child: Center(
                      child: Text('Content Area'),
                    ),
                  ),
                  BottomBannerSlot(
                    bannerSize: AdSize.banner,
                    bannerChild: Container(
                      color: Colors.amber,
                      child: const Center(
                        child: Text(
                          'BANNER AD',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.loadAssets();
      await tester.pumpAndSettle();

      await tester.expectScreenshot(
        device,
        'banner_ad_above_android_nav_bar',
      );
    });

    testGoldens('Banner ad placeholder with system padding', (tester) async {
      // Simulate Android device with system navigation bar
      const systemBottomPadding = 48.0;

      final device = ScreenshotDevice(
        platform: TargetPlatform.android,
        resolution: const Size(1080, 1920),
        pixelRatio: 1,
        goldenSubFolder: 'phoneScreenshots/',
        frameBuilder: ScreenshotFrame.androidPhone,
      );

      await tester.pumpWidget(
        ScreenshotApp(
          device: device,
          title: 'Banner Ad Placeholder Test',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: systemBottomPadding),
              viewPadding: EdgeInsets.only(bottom: systemBottomPadding),
            ),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Banner Ad Placeholder Test'),
              ),
              body: const Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text('Content Area'),
                    ),
                  ),
                  BottomBannerSlot(
                    showDebugPlaceholder: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.loadAssets();
      await tester.pumpAndSettle();

      await tester.expectScreenshot(
        device,
        'banner_ad_placeholder_with_system_padding',
      );
    });
  });
}

String absoluteGoldenDirectory(String rootPath) {
  final normalized = rootPath.replaceAll('\\', '/');
  return normalized.endsWith('/') ? normalized : '$normalized/';
}

String projectAbsolutePath(String relativePath) {
  return relativePath; // Already absolute in test context
}
