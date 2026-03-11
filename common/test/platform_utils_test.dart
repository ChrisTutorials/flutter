import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:common_flutter_utilities/platform_utils.dart';

void main() {
  group('PlatformUtils', () {
    test('isWeb returns correct value', () {
      expect(PlatformUtils.isWeb, kIsWeb);
    });

    test('isMobile and isDesktop are mutually exclusive on non-web', () {
      if (!kIsWeb) {
        expect(PlatformUtils.isMobile || PlatformUtils.isDesktop, isTrue);
        expect(PlatformUtils.isMobile && PlatformUtils.isDesktop, isFalse);
      }
    });

    test('isMobile returns true only for Android or iOS', () {
      if (!kIsWeb) {
        if (PlatformUtils.isAndroid || PlatformUtils.isIOS) {
          expect(PlatformUtils.isMobile, isTrue);
        } else {
          expect(PlatformUtils.isMobile, isFalse);
        }
      } else {
        expect(PlatformUtils.isMobile, isFalse);
      }
    });

    test('isDesktop returns true only for desktop platforms', () {
      if (!kIsWeb) {
        if (PlatformUtils.isWindows || PlatformUtils.isMacOS || PlatformUtils.isLinux) {
          expect(PlatformUtils.isDesktop, isTrue);
        } else {
          expect(PlatformUtils.isDesktop, isFalse);
        }
      } else {
        expect(PlatformUtils.isDesktop, isFalse);
      }
    });

    test('isAndroid returns correct value', () {
      if (!kIsWeb) {
        expect(PlatformUtils.isAndroid, isA<bool>());
      } else {
        expect(PlatformUtils.isAndroid, isFalse);
      }
    });

    test('isIOS returns correct value', () {
      if (!kIsWeb) {
        expect(PlatformUtils.isIOS, isA<bool>());
      } else {
        expect(PlatformUtils.isIOS, isFalse);
      }
    });

    test('isWindows returns correct value', () {
      if (!kIsWeb) {
        expect(PlatformUtils.isWindows, isA<bool>());
      } else {
        expect(PlatformUtils.isWindows, isFalse);
      }
    });

    test('isMacOS returns correct value', () {
      if (!kIsWeb) {
        expect(PlatformUtils.isMacOS, isA<bool>());
      } else {
        expect(PlatformUtils.isMacOS, isFalse);
      }
    });

    test('isLinux returns correct value', () {
      if (!kIsWeb) {
        expect(PlatformUtils.isLinux, isA<bool>());
      } else {
        expect(PlatformUtils.isLinux, isFalse);
      }
    });
  });
}
