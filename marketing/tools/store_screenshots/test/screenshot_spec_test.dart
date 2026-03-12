import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:store_screenshots/store_screenshots.dart';
import 'package:test/test.dart';

void main() {
  test('workflow spec resolves raw and output directories relative to spec file', () {
    final tempDir = Directory.systemTemp.createTempSync('store_spec_test');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final specFile = File(path.join(tempDir.path, 'workflow.json'));
    specFile.writeAsStringSync(
      jsonEncode({
        'name': 'sample',
        'rawDir': './raw',
        'outputDir': './out',
        'defaults': {'contentPadding': 12},
        'images': [
          {
            'id': 'phone_home',
            'input': 'home_raw.png',
            'output': 'home.png',
            'targetWidth': 1080,
            'targetHeight': 1920,
          },
        ],
      }),
    );

    final spec = ScreenshotWorkflowSpec.fromFile(specFile.path);

    expect(spec.rawDir.path, path.normalize(path.join(tempDir.path, 'raw')));
    expect(spec.outputDir.path, path.normalize(path.join(tempDir.path, 'out')));
    expect(spec.images.single.contentPadding, 12);
  });

  test('unit converter screenshot spec parses and declares twelve exports', () {
    final packageRoot = Directory.current.path;
    final specPath = path.normalize(
      path.join(packageRoot, '..', '..', 'unit_converter', 'screenshots', 'store_screenshot_spec.json'),
    );

    final spec = ScreenshotWorkflowSpec.fromFile(specPath);

    expect(spec.name, 'unit_converter_store_listing');
    expect(spec.images, hasLength(12));
    expect(spec.images.first.targetWidth, 1080);
    expect(spec.images.last.targetHeight, 2560);
  });
}
