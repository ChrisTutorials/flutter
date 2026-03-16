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
      projectAbsolutePath('../marketing/unit_converter/screenshots'),
    );
  });

  tearDownAll(() {
    ScreenshotDevice.screenshotsFolder = previousScreenshotsFolder;
  });

  group('Store Screenshot Generation', () {
    for (final device in storeScreenshotDevices) {
      for (final surface in storeScreenshotSurfaces) {
        testGoldens(
          '${device.testLabel} ${surface.testLabel} raw screenshot',
          (tester) async {
            final harness = await createStoreScreenshotHarness(surface);

            await pumpStoreScreenshotApp(
              tester,
              device: device.rawDevice,
              harness: harness,
            );

            await tester.expectScreenshot(
              device.rawDevice,
              device.rawGoldenName(surface),
            );
          },
        );
      }
    }
  });
}