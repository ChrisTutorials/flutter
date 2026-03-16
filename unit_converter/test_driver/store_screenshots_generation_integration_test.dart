import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  final driver = await FlutterDriver.connect();
  final screenshotsDir = path.join(
    Directory.current.path,
    '..',
    'marketing',
    'unit_converter',
    'screenshots',
    'raw_store_screenshots',
  );

  await integrationDriver(
    driver: driver,
    onScreenshot: (String screenshotName, List<int> screenshotBytes, [Map<String, Object?>? args]) async {
      await Directory(screenshotsDir).create(recursive: true);
      final screenshotPath = path.join(screenshotsDir, '$screenshotName.png');
      final normalizedBytes = _normalizeScreenshotBytes(screenshotName, screenshotBytes);
      final file = File(screenshotPath);
      await file.writeAsBytes(normalizedBytes, flush: true);
      return true;
    },
    writeResponseOnFailure: true,
  );
}

List<int> _normalizeScreenshotBytes(String screenshotName, List<int> screenshotBytes) {
  final sourceImage = img.decodePng(Uint8List.fromList(screenshotBytes));
  if (sourceImage == null) {
    return screenshotBytes;
  }

  final match = RegExp(r'_(\d+)x(\d+)$').firstMatch(screenshotName);
  if (match == null) {
    return screenshotBytes;
  }

  final targetWidth = int.parse(match.group(1)!);
  final targetHeight = int.parse(match.group(2)!);

  if (sourceImage.width == targetWidth && sourceImage.height == targetHeight) {
    return screenshotBytes;
  }

  final normalizedImage = img.copyResize(
    sourceImage,
    width: targetWidth,
    height: targetHeight,
    interpolation: img.Interpolation.average,
  );

  return img.encodePng(normalizedImage);
}
