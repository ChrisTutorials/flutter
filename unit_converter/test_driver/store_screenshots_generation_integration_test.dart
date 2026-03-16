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

      // Verify debug ribbon is not present
      _verifyNoDebugRibbon(screenshotName, normalizedBytes);

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

void _verifyNoDebugRibbon(String screenshotName, List<int> screenshotBytes) {
  final image = img.decodePng(Uint8List.fromList(screenshotBytes));
  if (image == null) {
    throw Exception('Failed to decode screenshot: $screenshotName');
  }

  // Check top-right corner where debug ribbon appears
  // Debug ribbon is typically ~20-30px high and appears in the top-right
  final ribbonHeight = 30;
  final ribbonWidth = 100;

  // Get the top-right corner region
  final startX = image.width - ribbonWidth;
  final startY = 0;
  final region = img.copyCrop(
    image,
    x: startX,
    y: startY,
    width: ribbonWidth,
    height: ribbonHeight,
  );

  // Debug ribbon is typically yellow/orange (high red/green values, low blue)
  // Check if the region has debug ribbon colors
  bool hasDebugRibbon = false;
  int debugPixels = 0;

  for (final pixel in region) {
    final r = pixel.r;
    final g = pixel.g;
    final b = pixel.b;

    // Debug ribbon colors are typically yellow/orange:
    // High red and green values, low blue values
    // Typical values: R=255, G=200-255, B=0-50
    if (r > 200 && g > 180 && b < 100) {
      debugPixels++;
    }
  }

  // If more than 50% of pixels in the region match debug ribbon colors,
  // consider it a debug ribbon
  final totalPixels = region.length;
  final debugPixelRatio = debugPixels / totalPixels;

  if (debugPixelRatio > 0.5) {
    throw Exception(
      'Screenshot "$screenshotName" contains a debug ribbon in the top-right corner. '
      'Ensure debugShowCheckedModeBanner is set to false in MaterialApp.',
    );
  }

  print('✓ Verified no debug ribbon in screenshot: $screenshotName');
}
