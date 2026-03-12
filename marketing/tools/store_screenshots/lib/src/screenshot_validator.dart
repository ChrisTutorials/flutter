import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

import 'screenshot_processor.dart';
import 'screenshot_spec.dart';

class ScreenshotValidationIssue {
  const ScreenshotValidationIssue(this.file, this.message);

  final File file;
  final String message;

  @override
  String toString() => '${file.path}: $message';
}

class ScreenshotValidator {
  ScreenshotValidator({ScreenshotProcessor? processor})
      : _processor = processor ?? ScreenshotProcessor();

  final ScreenshotProcessor _processor;

  List<ScreenshotValidationIssue> validateSpec(ScreenshotWorkflowSpec spec) {
    final issues = <ScreenshotValidationIssue>[];

    for (final imageSpec in spec.images) {
      final file = spec.outputFileFor(imageSpec);
      if (!file.existsSync()) {
        issues.add(ScreenshotValidationIssue(file, 'Missing output screenshot.'));
        continue;
      }

      if (file.lengthSync() > spec.sizeLimitBytes) {
        issues.add(
          ScreenshotValidationIssue(
            file,
            'File exceeds size limit of ${spec.sizeLimitBytes} bytes.',
          ),
        );
      }

      final decoded = img.decodeImage(file.readAsBytesSync());
      if (decoded == null) {
        issues.add(ScreenshotValidationIssue(file, 'Unable to decode image.'));
        continue;
      }

      if (decoded.width != imageSpec.targetWidth ||
          decoded.height != imageSpec.targetHeight) {
        issues.add(
          ScreenshotValidationIssue(
            file,
            'Expected ${imageSpec.targetWidth}x${imageSpec.targetHeight} but found ${decoded.width}x${decoded.height}.',
          ),
        );
      }

      final whitespace = measureWhitespace(
        decoded,
        backgroundTolerance: imageSpec.backgroundTolerance,
      );

      if (whitespace.bottomFraction > imageSpec.maxBottomWhitespaceFraction) {
        issues.add(
          ScreenshotValidationIssue(
            file,
            'Bottom whitespace fraction ${whitespace.bottomFraction.toStringAsFixed(3)} exceeds ${imageSpec.maxBottomWhitespaceFraction.toStringAsFixed(3)}.',
          ),
        );
      }

      if (whitespace.topFraction > imageSpec.maxTopWhitespaceFraction) {
        issues.add(
          ScreenshotValidationIssue(
            file,
            'Top whitespace fraction ${whitespace.topFraction.toStringAsFixed(3)} exceeds ${imageSpec.maxTopWhitespaceFraction.toStringAsFixed(3)}.',
          ),
        );
      }
    }

    return issues;
  }

  WhitespaceMetrics measureWhitespace(
    img.Image image, {
    required int backgroundTolerance,
  }) {
    final background = _processor.estimateBackgroundColor(image);
    final bottomRows = _countWhitespaceRows(
      image,
      fromTop: false,
      background: background,
      tolerance: backgroundTolerance,
    );
    final topRows = _countWhitespaceRows(
      image,
      fromTop: true,
      background: background,
      tolerance: backgroundTolerance,
    );

    return WhitespaceMetrics(
      topFraction: topRows / image.height,
      bottomFraction: bottomRows / image.height,
    );
  }

  int _countWhitespaceRows(
    img.Image image, {
    required bool fromTop,
    required img.Color background,
    required int tolerance,
  }) {
    final xStep = math.max(1, image.width ~/ 120);
    final activePixelThreshold = math.max(12, (image.width * 0.02).round());
    var count = 0;

    for (var index = 0; index < image.height; index++) {
      final y = fromTop ? index : image.height - 1 - index;
      var nonBackgroundPixels = 0;

      for (var x = 0; x < image.width; x += xStep) {
        final pixel = image.getPixel(x, y);
        final isBackground = (pixel.r - background.r).abs() <= tolerance &&
            (pixel.g - background.g).abs() <= tolerance &&
            (pixel.b - background.b).abs() <= tolerance;
        if (!isBackground) {
          nonBackgroundPixels += xStep;
        }
      }

      if (nonBackgroundPixels < activePixelThreshold) {
        count += 1;
        continue;
      }

      break;
    }

    return count;
  }
}

class WhitespaceMetrics {
  const WhitespaceMetrics({
    required this.topFraction,
    required this.bottomFraction,
  });

  final double topFraction;
  final double bottomFraction;
}
