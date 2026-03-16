import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';

import '../support/store_screenshot_catalog.dart';
import '../support/store_screenshot_test_harness.dart';

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

  group('Framed Store Screenshots', () {
    for (final device in storeScreenshotDevices) {
      for (final surface in storeScreenshotSurfaces) {
        testGoldens('${device.testLabel} ${surface.testLabel} framed', (
          tester,
        ) async {
          final harness = await createStoreScreenshotHarness(surface);

          await pumpStoreScreenshotApp(
            tester,
            device: device.framedDevice,
            harness: harness,
          );

          await tester.expectScreenshot(
            device.framedDevice,
            device.framedGoldenName(surface),
          );
        });
      }
    }
  });
}
