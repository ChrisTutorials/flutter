import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:store_screenshots/store_screenshots.dart';
import 'package:test/test.dart';

void main() {
  test('processor crops away large bottom whitespace while preserving target size', () {
    final source = img.Image(width: 1080, height: 1920);
    img.fill(source, color: img.ColorRgb8(255, 255, 255));
    img.fillRect(source, x1: 140, y1: 120, x2: 940, y2: 1480, color: img.ColorRgb8(0, 120, 110));
    img.fillRect(source, x1: 220, y1: 1530, x2: 860, y2: 1640, color: img.ColorRgb8(45, 45, 45));

    final processor = ScreenshotProcessor();
    final cropRect = processor.calculateCropRect(
      source,
      imageSpec: const ScreenshotImageSpec(
        id: 'synthetic',
        inputFileName: 'synthetic_raw.png',
        outputFileName: 'synthetic.png',
        targetWidth: 1080,
        targetHeight: 1920,
        backgroundTolerance: 12,
        contentPadding: 24,
        maxBottomWhitespaceFraction: 0.04,
        maxTopWhitespaceFraction: 0.10,
        minCropScale: 1.0,
        focusX: 0.5,
        focusY: 0.45,
      ),
    );

    final cropped = img.copyCrop(
      source,
      x: cropRect.x,
      y: cropRect.y,
      width: cropRect.width,
      height: cropRect.height,
    );
    final resized = img.copyResize(cropped, width: 1080, height: 1920);

    final validator = ScreenshotValidator(processor: processor);
    final whitespace = validator.measureWhitespace(
      resized,
      backgroundTolerance: 12,
    );

    expect(cropRect.height, lessThan(1920));
    expect(resized.width, 1080);
    expect(resized.height, 1920);
    expect(whitespace.bottomFraction, lessThanOrEqualTo(0.04));
  });
}
