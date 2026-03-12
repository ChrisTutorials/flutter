import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/utils/platform_utils.dart';

void main() {
  group('PlatformUtils', () {
    test('isMobile should be a getter', () {
      // Just verify the property exists and is accessible
      // Actual value depends on the platform running the tests
      expect(PlatformUtils.isMobile, isA<bool>());
    });

    test('isAndroid should be a getter', () {
      expect(PlatformUtils.isAndroid, isA<bool>());
    });

    test('isIOS should be a getter', () {
      expect(PlatformUtils.isIOS, isA<bool>());
    });

    test('isWindows should be a getter', () {
      expect(PlatformUtils.isWindows, isA<bool>());
    });

    test('isMacOS should be a getter', () {
      expect(PlatformUtils.isMacOS, isA<bool>());
    });

    test('isLinux should be a getter', () {
      expect(PlatformUtils.isLinux, isA<bool>());
    });

    test('isDesktop should be a getter', () {
      expect(PlatformUtils.isDesktop, isA<bool>());
    });

    test('isWeb should be a getter', () {
      expect(PlatformUtils.isWeb, isA<bool>());
    });

    test('isDesktop should be true if Windows, MacOS, or Linux', () {
      // This test verifies the logic is sound
      // On Windows, isDesktop should be true
      // On other platforms, it depends
      final isDesktop = PlatformUtils.isDesktop;
      final isWindows = PlatformUtils.isWindows;
      final isMacOS = PlatformUtils.isMacOS;
      final isLinux = PlatformUtils.isLinux;
      
      // If any desktop platform is true, isDesktop should be true
      if (isWindows || isMacOS || isLinux) {
        expect(isDesktop, isTrue);
      }
    });

    test('isMobile should be false on desktop platforms', () {
      // If running on desktop, isMobile should be false
      if (PlatformUtils.isDesktop) {
        expect(PlatformUtils.isMobile, isFalse);
      }
    });
  });
}
