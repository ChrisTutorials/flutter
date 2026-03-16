import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:store_screenshots/store_screenshots.dart';

/// Validates store screenshots for Google Play Store
/// 
/// This test ensures that all screenshots:
/// 1. Have the correct dimensions
/// 2. Have zero whitespace (no white bars)
/// 3. Show the full app screen without cropping
/// 
/// Usage:
/// `ash
/// flutter test test/integration/store_screenshots_validation_test.dart
/// `
void main() {
  group('Store Screenshot Validation', () {
    late ScreenshotWorkflowSpec workflowSpec;

    setUpAll(() {
      final specPath = path.normalize(
        path.join(
          Directory.current.path,
          '..',
          'marketing',
          'unit_converter',
          'screenshots',
          'store_screenshot_spec.json',
        ),
      );
      workflowSpec = ScreenshotWorkflowSpec.fromFile(specPath);
    });

    test('Raw screenshot directory exactly matches the spec', () {
      final expectedScreenshots = workflowSpec.images
          .map((spec) => spec.inputFileName)
          .toSet();
      final actualScreenshots = workflowSpec.rawDir
          .listSync()
          .whereType<File>()
          .map((file) => path.basename(file.path))
          .where((fileName) => fileName.toLowerCase().endsWith('.png'))
          .toSet();

      expect(actualScreenshots, equals(expectedScreenshots));
    });

    test('All required screenshots exist', () {
      for (final spec in workflowSpec.images) {
        final screenshotPath = workflowSpec.rawFileFor(spec).path;
        expect(
          File(screenshotPath).existsSync(),
          isTrue,
          reason: 'Screenshot not found: ${spec.inputFileName}',
        );
      }
    });

    test('Raw screenshots have the dimensions declared in the spec', () {
      for (final spec in workflowSpec.images) {
        final screenshotPath = workflowSpec.rawFileFor(spec).path;
        final image = img.decodePng(File(screenshotPath).readAsBytesSync());
        expect(image, isNotNull, reason: 'Could not decode ${spec.inputFileName}');
        expect(image!.width, equals(spec.targetWidth), reason: '${spec.inputFileName} has wrong width');
        expect(image.height, equals(spec.targetHeight), reason: '${spec.inputFileName} has wrong height');
      }
    });

    test('Screenshots have zero whitespace at bottom', () {
      for (final spec in workflowSpec.images) {
        final screenshotPath = workflowSpec.rawFileFor(spec).path;
        final image = img.decodePng(File(screenshotPath).readAsBytesSync());
        expect(image, isNotNull, reason: 'Could not decode ${spec.inputFileName}');
        
        // Check the last 5% of the image for whitespace
        final bottomStart = (image!.height * 0.95).floor();
        var hasNonWhitePixel = false;
        
        for (var y = bottomStart; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            // Check if pixel is not white (R, G, B not all >= 250)
            if (pixel.r < 250 || pixel.g < 250 || pixel.b < 250) {
              hasNonWhitePixel = true;
              break;
            }
          }
          if (hasNonWhitePixel) break;
        }
        
        expect(
          hasNonWhitePixel,
          isTrue,
          reason: '${spec.inputFileName} has whitespace at the bottom (last 5% of image is all white)',
        );
      }
    });

    test('Screenshots have zero whitespace at top', () {
      for (final spec in workflowSpec.images) {
        final screenshotPath = workflowSpec.rawFileFor(spec).path;
        final image = img.decodePng(File(screenshotPath).readAsBytesSync());
        expect(image, isNotNull, reason: 'Could not decode ${spec.inputFileName}');
        
        // Check the first 5% of the image for whitespace
        final topEnd = (image!.height * 0.05).ceil();
        var hasNonWhitePixel = false;
        
        for (var y = 0; y < topEnd; y++) {
          for (var x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            // Check if pixel is not white (R, G, B not all >= 250)
            if (pixel.r < 250 || pixel.g < 250 || pixel.b < 250) {
              hasNonWhitePixel = true;
              break;
            }
          }
          if (hasNonWhitePixel) break;
        }
        
        expect(
          hasNonWhitePixel,
          isTrue,
          reason: '${spec.inputFileName} has whitespace at the top (first 5% of image is all white)',
        );
      }
    });

    test('Screenshots contain visible UI content', () {
      for (final spec in workflowSpec.images) {
        final screenshotPath = workflowSpec.rawFileFor(spec).path;
        final image = img.decodePng(File(screenshotPath).readAsBytesSync());
        expect(image, isNotNull, reason: 'Could not decode ${spec.inputFileName}');

        const sampleStep = 16;
        var informativePixelCount = 0;
        var sampledPixelCount = 0;

        for (var y = 0; y < image!.height; y += sampleStep) {
          for (var x = 0; x < image.width; x += sampleStep) {
            final pixel = image.getPixel(x, y);
            sampledPixelCount++;
            if (pixel.r < 245 || pixel.g < 245 || pixel.b < 245) {
              informativePixelCount++;
            }
          }
        }

        final informativePixelRatio = informativePixelCount / sampledPixelCount;

        expect(
          informativePixelRatio,
          greaterThan(0.01),
          reason: '${spec.inputFileName} appears to be mostly blank',
        );
      }
    });

    test('Screenshots have no large whitespace chunks', () {
      // Check that there are no large horizontal or vertical bands of whitespace
      // which would indicate the screenshot was not captured at full screen size
      const chunkSize = 100; // pixels
      const whitespaceThreshold = 0.98; // 98% white pixels to consider a chunk whitespace (stricter)

      for (final spec in workflowSpec.images) {
        final screenshotPath = workflowSpec.rawFileFor(spec).path;
        final image = img.decodePng(File(screenshotPath).readAsBytesSync());
        expect(image, isNotNull, reason: 'Could not decode ${spec.inputFileName}');

        var consecutiveWhitespaceChunks = 0;
        var maxConsecutiveWhitespaceChunks = 0;

        // Check horizontal chunks
        for (var y = 0; y < image!.height; y += chunkSize) {
          var whitePixelCount = 0;
          var totalPixels = 0;

          for (var x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            totalPixels++;
            if (pixel.r >= 250 && pixel.g >= 250 && pixel.b >= 250) {
              whitePixelCount++;
            }
          }

          final whitePixelRatio = whitePixelCount / totalPixels;
          if (whitePixelRatio > whitespaceThreshold) {
            consecutiveWhitespaceChunks++;
            if (consecutiveWhitespaceChunks > maxConsecutiveWhitespaceChunks) {
              maxConsecutiveWhitespaceChunks = consecutiveWhitespaceChunks;
            }
          } else {
            consecutiveWhitespaceChunks = 0;
          }
        }

        // Check vertical chunks
        for (var x = 0; x < image.width; x += chunkSize) {
          var whitePixelCount = 0;
          var totalPixels = 0;

          for (var y = 0; y < image.height; y++) {
            final pixel = image.getPixel(x, y);
            totalPixels++;
            if (pixel.r >= 250 && pixel.g >= 250 && pixel.b >= 250) {
              whitePixelCount++;
            }
          }

          final whitePixelRatio = whitePixelCount / totalPixels;
          if (whitePixelRatio > whitespaceThreshold) {
            consecutiveWhitespaceChunks++;
            if (consecutiveWhitespaceChunks > maxConsecutiveWhitespaceChunks) {
              maxConsecutiveWhitespaceChunks = consecutiveWhitespaceChunks;
            }
          } else {
            consecutiveWhitespaceChunks = 0;
          }
        }

        expect(
          maxConsecutiveWhitespaceChunks,
          lessThanOrEqualTo(3),
          reason: '${spec.inputFileName} has $maxConsecutiveWhitespaceChunks consecutive whitespace chunks (max allowed: 3). '
              'This indicates the screenshot was not captured at full screen size.',
        );
      }
    });

    test('Screenshots fill the entire image area', () {
      // Verify that the screenshot uses the full image dimensions
      // by checking that content exists in all quadrants
      for (final spec in workflowSpec.images) {
        final screenshotPath = workflowSpec.rawFileFor(spec).path;
        final image = img.decodePng(File(screenshotPath).readAsBytesSync());
        expect(image, isNotNull, reason: 'Could not decode ${spec.inputFileName}');

        final quadrants = [
          {'x': 0, 'y': 0, 'w': image!.width ~/ 2, 'h': image.height ~/ 2},
          {'x': image.width ~/ 2, 'y': 0, 'w': image.width ~/ 2, 'h': image.height ~/ 2},
          {'x': 0, 'y': image.height ~/ 2, 'w': image.width ~/ 2, 'h': image.height ~/ 2},
          {'x': image.width ~/ 2, 'y': image.height ~/ 2, 'w': image.width ~/ 2, 'h': image.height ~/ 2},
        ];

        for (final quadrant in quadrants) {
          var nonWhitePixelCount = 0;
          var totalPixels = 0;

          for (var y = quadrant['y']!; y < quadrant['y']! + quadrant['h']!; y += 8) {
            for (var x = quadrant['x']!; x < quadrant['x']! + quadrant['w']!; x += 8) {
              final pixel = image.getPixel(x, y);
              totalPixels++;
              if (pixel.r < 250 || pixel.g < 250 || pixel.b < 250) {
                nonWhitePixelCount++;
              }
            }
          }

          final nonWhitePixelRatio = nonWhitePixelCount / totalPixels;

          expect(
            nonWhitePixelRatio,
            greaterThan(0.02),
            reason: '${spec.inputFileName} has a quadrant that is mostly empty (non-white ratio: ${nonWhitePixelRatio.toStringAsFixed(3)}). '
                'This indicates the screenshot was not captured at full screen size.',
          );
        }
      }
    });

    test('Screenshots contain legible text characters', () {
      // Verify that screenshots have actual text content, not just placeholder rectangles
      // This checks for the presence of character-like pixel patterns
      for (final spec in workflowSpec.images) {
        final screenshotPath = workflowSpec.rawFileFor(spec).path;
        final image = img.decodePng(File(screenshotPath).readAsBytesSync());
        expect(image, isNotNull, reason: 'Could not decode ${spec.inputFileName}');

        var textRegionCount = 0;
        var sampleRegions = 0;
        const sampleSize = 50; // pixels
        const sampleStep = 80; // pixels
        final contentRegionHeight = (image!.height * 0.45).round();

        for (var y = sampleSize; y < contentRegionHeight - sampleSize; y += sampleStep) {
          for (var x = sampleSize; x < image.width - sampleSize; x += sampleStep) {
            sampleRegions++;

            num colorVariance = 0;
            var pixelCount = 0;
            num avgR = 0, avgG = 0, avgB = 0;

            for (var dy = 0; dy < sampleSize; dy += 5) {
              for (var dx = 0; dx < sampleSize; dx += 5) {
                final pixel = image.getPixel(x + dx, y + dy);
                avgR += pixel.r;
                avgG += pixel.g;
                avgB += pixel.b;
                pixelCount++;
              }
            }

            avgR ~/= pixelCount;
            avgG ~/= pixelCount;
            avgB ~/= pixelCount;

            for (var dy = 0; dy < sampleSize; dy += 5) {
              for (var dx = 0; dx < sampleSize; dx += 5) {
                final pixel = image.getPixel(x + dx, y + dy);
                colorVariance += (pixel.r - avgR).abs() +
                                (pixel.g - avgG).abs() +
                                (pixel.b - avgB).abs();
              }
            }

            final variancePerPixel = colorVariance / pixelCount;
            if (variancePerPixel > 20) {
              textRegionCount++;
            }
          }
        }

        final textRegionRatio = textRegionCount / sampleRegions;

        expect(
          textRegionRatio,
          greaterThan(0.04),
          reason: '${spec.inputFileName} appears to have insufficient text detail in the primary content region '
              '(text region ratio: ${textRegionRatio.toStringAsFixed(3)}). '
              'This indicates text may not be rendering correctly. '
              'Check screenshot capture and font rendering configuration.',
        );
      }
    });
  });
}
