import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:store_screenshots/store_screenshots.dart';
import 'package:test/test.dart';

void main() {
  test('unit_converter committed screenshot outputs validate against the spec', () {
    final packageRoot = Directory.current.path;
    final specPath = path.normalize(
      path.join(packageRoot, '..', '..', 'unit_converter', 'screenshots', 'store_screenshot_spec.json'),
    );

    final spec = ScreenshotWorkflowSpec.fromFile(specPath);
    final issues = ScreenshotValidator().validateSpec(spec);

    expect(issues, isEmpty, reason: issues.join('\n'));
  });
}
