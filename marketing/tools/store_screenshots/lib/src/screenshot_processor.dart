import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

import 'screenshot_spec.dart';

class ProcessedScreenshotResult {
  const ProcessedScreenshotResult({
    required this.imageSpec,
    required this.sourceFile,
    required this.outputFile,
    required this.cropRect,
  });

  final ScreenshotImageSpec imageSpec;
  final File sourceFile;
  final File outputFile;
  final CropRect cropRect;
}

class CropRect {
  const CropRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int x;
  final int y;
  final int width;
  final int height;

  @override
  String toString() => 'x=$x, y=$y, width=$width, height=$height';
}

class ScreenshotProcessor {
  List<ProcessedScreenshotResult> processSpec(ScreenshotWorkflowSpec spec) {
    spec.outputDir.createSync(recursive: true);
    final results = <ProcessedScreenshotResult>[];

    for (final imageSpec in spec.images) {
      final sourceFile = spec.rawFileFor(imageSpec);
      if (!sourceFile.existsSync()) {
        throw FileSystemException('Raw screenshot not found', sourceFile.path);
      }

      final sourceImage = img.decodeImage(sourceFile.readAsBytesSync());
      if (sourceImage == null) {
        throw StateError('Unable to decode ${sourceFile.path}');
      }

      final cropRect = calculateCropRect(
        sourceImage,
        imageSpec: imageSpec,
      );

      final cropped = img.copyCrop(
        sourceImage,
        x: cropRect.x,
        y: cropRect.y,
        width: cropRect.width,
        height: cropRect.height,
      );
      final resized = img.copyResize(
        cropped,
        width: imageSpec.targetWidth,
        height: imageSpec.targetHeight,
        interpolation: img.Interpolation.cubic,
      );

      final outputFile = spec.outputFileFor(imageSpec);
      outputFile.parent.createSync(recursive: true);
      outputFile.writeAsBytesSync(img.encodePng(resized, level: 6));

      results.add(
        ProcessedScreenshotResult(
          imageSpec: imageSpec,
          sourceFile: sourceFile,
          outputFile: outputFile,
          cropRect: cropRect,
        ),
      );
    }

    return results;
  }

  CropRect calculateCropRect(
    img.Image image, {
    required ScreenshotImageSpec imageSpec,
  }) {
    final bounds = detectContentBounds(
          image,
          backgroundTolerance: imageSpec.backgroundTolerance,
        ) ??
        CropRect(x: 0, y: 0, width: image.width, height: image.height);
    final padded = _expandBounds(bounds, image, imageSpec.contentPadding);
    final fitted = _fitToAspectRatio(
      padded,
      imageWidth: image.width,
      imageHeight: image.height,
      targetAspectRatio: imageSpec.targetWidth / imageSpec.targetHeight,
    );
    return _applyFocusZoom(
      fitted,
      imageWidth: image.width,
      imageHeight: image.height,
      minCropScale: imageSpec.minCropScale,
      focusX: imageSpec.focusX,
      focusY: imageSpec.focusY,
    );
  }

  CropRect? detectContentBounds(
    img.Image image, {
    required int backgroundTolerance,
  }) {
    final background = estimateBackgroundColor(image);

    final activeRows = <int>[];
    final activeColumns = <int>[];
    final rowThreshold = math.max(12, (image.width * 0.02).round());
    final columnThreshold = math.max(12, (image.height * 0.02).round());

    for (var y = 0; y < image.height; y++) {
      var nonBackgroundPixels = 0;
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        if (!_isBackground(pixel, background, backgroundTolerance)) {
          nonBackgroundPixels += 1;
        }
      }
      if (nonBackgroundPixels >= rowThreshold) {
        activeRows.add(y);
      }
    }

    for (var x = 0; x < image.width; x++) {
      var nonBackgroundPixels = 0;
      for (var y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        if (!_isBackground(pixel, background, backgroundTolerance)) {
          nonBackgroundPixels += 1;
        }
      }
      if (nonBackgroundPixels >= columnThreshold) {
        activeColumns.add(x);
      }
    }

    if (activeRows.isEmpty || activeColumns.isEmpty) {
      return null;
    }

    return CropRect(
      x: activeColumns.first,
      y: activeRows.first,
      width: (activeColumns.last - activeColumns.first) + 1,
      height: (activeRows.last - activeRows.first) + 1,
    );
  }

  img.Color estimateBackgroundColor(img.Image image) {
    final samples = <int, int>{};
    final xStep = math.max(1, image.width ~/ 32);
    final yStep = math.max(1, image.height ~/ 32);

    for (var x = 0; x < image.width; x += xStep) {
      _addSample(samples, image.getPixel(x, 0));
      _addSample(samples, image.getPixel(x, image.height - 1));
    }

    for (var y = 0; y < image.height; y += yStep) {
      _addSample(samples, image.getPixel(0, y));
      _addSample(samples, image.getPixel(image.width - 1, y));
    }

    final dominant = samples.entries.reduce(
      (best, next) => next.value > best.value ? next : best,
    );

    final value = dominant.key;
    return img.ColorRgb8(
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    );
  }

  void _addSample(Map<int, int> samples, img.Pixel pixel) {
    final r = (pixel.r.toInt() ~/ 8) * 8;
    final g = (pixel.g.toInt() ~/ 8) * 8;
    final b = (pixel.b.toInt() ~/ 8) * 8;
    final key = (r << 16) | (g << 8) | b;
    samples.update(key, (count) => count + 1, ifAbsent: () => 1);
  }

  bool _isBackground(img.Pixel pixel, img.Color background, int tolerance) {
    return (pixel.r - background.r).abs() <= tolerance &&
        (pixel.g - background.g).abs() <= tolerance &&
        (pixel.b - background.b).abs() <= tolerance;
  }

  CropRect _expandBounds(CropRect rect, img.Image image, int padding) {
    final x = math.max(0, rect.x - padding);
    final y = math.max(0, rect.y - padding);
    final right = math.min(image.width, rect.x + rect.width + padding);
    final bottom = math.min(image.height, rect.y + rect.height + padding);
    return CropRect(
      x: x,
      y: y,
      width: right - x,
      height: bottom - y,
    );
  }

  CropRect _fitToAspectRatio(
    CropRect rect, {
    required int imageWidth,
    required int imageHeight,
    required double targetAspectRatio,
  }) {
    var cropWidth = rect.width.toDouble();
    var cropHeight = rect.height.toDouble();
    final sourceAspectRatio = imageWidth / imageHeight;

    if (cropWidth / cropHeight > targetAspectRatio) {
      cropHeight = cropWidth / targetAspectRatio;
    } else {
      cropWidth = cropHeight * targetAspectRatio;
    }

    if (cropWidth > imageWidth || cropHeight > imageHeight) {
      if (sourceAspectRatio > targetAspectRatio) {
        cropHeight = imageHeight.toDouble();
        cropWidth = cropHeight * targetAspectRatio;
      } else {
        cropWidth = imageWidth.toDouble();
        cropHeight = cropWidth / targetAspectRatio;
      }
    }

    final centerX = rect.x + (rect.width / 2);
    final centerY = rect.y + (rect.height / 2);
    var x = (centerX - (cropWidth / 2)).round();
    var y = (centerY - (cropHeight / 2)).round();

    final width = cropWidth.round().clamp(1, imageWidth);
    final height = cropHeight.round().clamp(1, imageHeight);
    x = x.clamp(0, imageWidth - width);
    y = y.clamp(0, imageHeight - height);

    return CropRect(x: x, y: y, width: width, height: height);
  }

  CropRect _applyFocusZoom(
    CropRect rect, {
    required int imageWidth,
    required int imageHeight,
    required double minCropScale,
    required double focusX,
    required double focusY,
  }) {
    final scale = minCropScale.clamp(0.5, 1.0);
    if (scale == 1.0) {
      return rect;
    }

    final width = (rect.width * scale).round().clamp(1, imageWidth);
    final height = (rect.height * scale).round().clamp(1, imageHeight);
    final centerX = rect.x + (rect.width * focusX);
    final centerY = rect.y + (rect.height * focusY);
    var x = (centerX - (width / 2)).round();
    var y = (centerY - (height / 2)).round();
    x = x.clamp(0, imageWidth - width);
    y = y.clamp(0, imageHeight - height);

    return CropRect(x: x, y: y, width: width, height: height);
  }
}
