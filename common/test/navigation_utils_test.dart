import 'package:flutter_test/flutter_test.dart';
import 'package:common_flutter_ads/navigation_utils.dart';

void main() {
  group('NavigationUtils', () {
    test('has pushScreen method', () {
      expect(NavigationUtils.pushScreen, isNotNull);
    });

    test('has pop method', () {
      expect(NavigationUtils.pop, isNotNull);
    });

    test('has pushAndAwait method', () {
      expect(NavigationUtils.pushAndAwait, isNotNull);
    });

    test('has pushWithCallback method', () {
      expect(NavigationUtils.pushWithCallback, isNotNull);
    });

    test('has pushReplacement method', () {
      expect(NavigationUtils.pushReplacement, isNotNull);
    });

    test('has pushAndRemoveUntil method', () {
      expect(NavigationUtils.pushAndRemoveUntil, isNotNull);
    });
  });
}
