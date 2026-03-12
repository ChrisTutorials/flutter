import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

class ScreenshotWorkflowSpec {
  ScreenshotWorkflowSpec({
    required this.name,
    required this.specFile,
    required this.rawDir,
    required this.outputDir,
    required this.sizeLimitBytes,
    required this.defaults,
    required this.images,
  });

  factory ScreenshotWorkflowSpec.fromFile(String specPath) {
    final specFile = File(specPath).absolute;
    final jsonMap = jsonDecode(specFile.readAsStringSync()) as Map<String, dynamic>;
    final specDir = specFile.parent.path;
    final defaultsJson = jsonMap['defaults'] as Map<String, dynamic>? ?? const {};

    return ScreenshotWorkflowSpec(
      name: jsonMap['name'] as String,
      specFile: specFile,
      rawDir: Directory(path.normalize(path.join(specDir, jsonMap['rawDir'] as String))),
      outputDir: Directory(path.normalize(path.join(specDir, jsonMap['outputDir'] as String))),
      sizeLimitBytes: jsonMap['sizeLimitBytes'] as int? ?? 8 * 1024 * 1024,
      defaults: ScreenshotDefaults.fromJson(defaultsJson),
      images: (jsonMap['images'] as List<dynamic>)
          .map(
            (entry) => ScreenshotImageSpec.fromJson(
              entry as Map<String, dynamic>,
              defaults: ScreenshotDefaults.fromJson(defaultsJson),
            ),
          )
          .toList(growable: false),
    );
  }

  final String name;
  final File specFile;
  final Directory rawDir;
  final Directory outputDir;
  final int sizeLimitBytes;
  final ScreenshotDefaults defaults;
  final List<ScreenshotImageSpec> images;

  File rawFileFor(ScreenshotImageSpec spec) =>
      File(path.join(rawDir.path, spec.inputFileName));

  File outputFileFor(ScreenshotImageSpec spec) =>
      File(path.join(outputDir.path, spec.outputFileName));
}

class ScreenshotDefaults {
  const ScreenshotDefaults({
    this.backgroundTolerance = 18,
    this.contentPadding = 24,
    this.maxBottomWhitespaceFraction = 0.04,
    this.maxTopWhitespaceFraction = 0.10,
  });

  factory ScreenshotDefaults.fromJson(Map<String, dynamic> json) {
    return ScreenshotDefaults(
      backgroundTolerance: json['backgroundTolerance'] as int? ?? 18,
      contentPadding: json['contentPadding'] as int? ?? 24,
      maxBottomWhitespaceFraction:
          (json['maxBottomWhitespaceFraction'] as num?)?.toDouble() ?? 0.04,
      maxTopWhitespaceFraction:
          (json['maxTopWhitespaceFraction'] as num?)?.toDouble() ?? 0.10,
    );
  }

  final int backgroundTolerance;
  final int contentPadding;
  final double maxBottomWhitespaceFraction;
  final double maxTopWhitespaceFraction;
}

class ScreenshotImageSpec {
  const ScreenshotImageSpec({
    required this.id,
    required this.inputFileName,
    required this.outputFileName,
    required this.targetWidth,
    required this.targetHeight,
    required this.backgroundTolerance,
    required this.contentPadding,
    required this.maxBottomWhitespaceFraction,
    required this.maxTopWhitespaceFraction,
    required this.minCropScale,
    required this.focusX,
    required this.focusY,
  });

  factory ScreenshotImageSpec.fromJson(
    Map<String, dynamic> json, {
    required ScreenshotDefaults defaults,
  }) {
    return ScreenshotImageSpec(
      id: json['id'] as String,
      inputFileName: json['input'] as String,
      outputFileName: json['output'] as String,
      targetWidth: json['targetWidth'] as int,
      targetHeight: json['targetHeight'] as int,
      backgroundTolerance:
          json['backgroundTolerance'] as int? ?? defaults.backgroundTolerance,
      contentPadding: json['contentPadding'] as int? ?? defaults.contentPadding,
      maxBottomWhitespaceFraction:
          (json['maxBottomWhitespaceFraction'] as num?)?.toDouble() ??
              defaults.maxBottomWhitespaceFraction,
      maxTopWhitespaceFraction:
          (json['maxTopWhitespaceFraction'] as num?)?.toDouble() ??
              defaults.maxTopWhitespaceFraction,
        minCropScale: (json['minCropScale'] as num?)?.toDouble() ?? 1.0,
        focusX: (json['focusX'] as num?)?.toDouble() ?? 0.5,
        focusY: (json['focusY'] as num?)?.toDouble() ?? 0.5,
    );
  }

  final String id;
  final String inputFileName;
  final String outputFileName;
  final int targetWidth;
  final int targetHeight;
  final int backgroundTolerance;
  final int contentPadding;
  final double maxBottomWhitespaceFraction;
  final double maxTopWhitespaceFraction;
  final double minCropScale;
  final double focusX;
  final double focusY;
}
