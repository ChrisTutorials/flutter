import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:store_screenshots/store_screenshots.dart';
import 'package:test/test.dart';

void main() {
  test('validator rejects screenshots with excessive bottom whitespace', () {
    final tempDir = Directory.systemTemp.createTempSync('validator_test');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final rawDir = Directory(path.join(tempDir.path, 'raw'))..createSync();
    final outDir = Directory(path.join(tempDir.path, 'out'))..createSync();
    final imageFile = File(path.join(outDir.path, 'home.png'));

    final image = img.Image(width: 1080, height: 1920);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    img.fillRect(image, x1: 180, y1: 100, x2: 900, y2: 600, color: img.ColorRgb8(0, 110, 100));
    imageFile.writeAsBytesSync(img.encodePng(image));

    final specFile = File(path.join(tempDir.path, 'workflow.json'));
    specFile.writeAsStringSync(
      jsonEncode({
        'name': 'sample',
        'rawDir': rawDir.path,
        'outputDir': outDir.path,
        'defaults': {
          'backgroundTolerance': 12,
          'maxBottomWhitespaceFraction': 0.04,
        },
        'images': [
          {
            'id': 'home',
            'input': 'home.png',
            'output': 'home.png',
            'targetWidth': 1080,
            'targetHeight': 1920,
          },
        ],
      }),
    );

    final spec = ScreenshotWorkflowSpec.fromFile(specFile.path);
    final issues = ScreenshotValidator().validateSpec(spec);

    expect(issues, isNotEmpty);
    expect(issues.single.message, contains('Bottom whitespace fraction'));
  });
}
