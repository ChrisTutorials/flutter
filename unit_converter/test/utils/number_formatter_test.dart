import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/utils/number_formatter.dart';

void main() {
  group('NumberFormatter', () {
    group('formatNumber', () {
      test('should format integer without decimal places', () {
        expect(NumberFormatter.formatNumber(100), '100');
        expect(NumberFormatter.formatNumber(0), '0');
        expect(NumberFormatter.formatNumber(-50), '-50');
      });

      test('should format decimal with up to 8 decimal places', () {
        expect(NumberFormatter.formatNumber(3.14159), '3.14159');
        expect(NumberFormatter.formatNumber(1.5), '1.5');
        expect(NumberFormatter.formatNumber(0.12345678), '0.12345678');
      });

      test('should handle very small decimals', () {
        final result = NumberFormatter.formatNumber(0.00000001);
        expect(result, '0.00000001');
      });

      test('should handle large numbers', () {
        expect(NumberFormatter.formatNumber(1000000), '1000000');
        expect(NumberFormatter.formatNumber(1234567.89), '1234567.89');
      });

      test('should handle negative decimals', () {
        expect(NumberFormatter.formatNumber(-3.14), '-3.14');
        expect(NumberFormatter.formatNumber(-0.5), '-0.5');
      });
    });

    group('formatCompact', () {
      test('should format small numbers without compact notation', () {
        expect(NumberFormatter.formatCompact(100), '100');
        expect(NumberFormatter.formatCompact(999), '999');
      });

      test('should format large numbers with compact notation', () {
        final result = NumberFormatter.formatCompact(1000);
        expect(result, isNot('1000')); // Should be '1K' or similar
      });

      test('should handle negative large numbers', () {
        final result = NumberFormatter.formatCompact(-1000);
        expect(result, isNot('-1000')); // Should be '-1K' or similar
      });
    });

    group('formatPrecise', () {
      test('should format integer without decimal places', () {
        expect(NumberFormatter.formatPrecise(100), '100');
        expect(NumberFormatter.formatPrecise(0), '0');
      });

      test('should format decimal with up to 8 decimal places', () {
        expect(NumberFormatter.formatPrecise(3.14159265), '3.14159265');
        expect(NumberFormatter.formatPrecise(1.5), '1.5');
      });
    });
  });
}
