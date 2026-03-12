import 'package:flutter_test/flutter_test.dart';
import 'package:common_flutter_ads/number_formatter.dart';

void main() {
  group('NumberFormatter Tests', () {
    test('formatCompact with small numbers', () {
      expect(NumberFormatter.formatCompact(5), equals('5'));
      expect(NumberFormatter.formatCompact(999), equals('999'));
    });

    test('formatCompact with thousands', () {
      expect(NumberFormatter.formatCompact(1000), equals('1K'));
      expect(NumberFormatter.formatCompact(1500), equals('1.5K'));
      expect(NumberFormatter.formatCompact(1500000), equals('1.5M'));
      expect(NumberFormatter.formatCompact(1500000000), equals('1.5B'));
    });

    test('formatNumber with integers', () {
      expect(NumberFormatter.formatNumber(42.0), equals('42'));
      expect(NumberFormatter.formatNumber(0), equals('0'));
      expect(NumberFormatter.formatNumber(-10), equals('-10'));
    });

    test('formatNumber with decimals', () {
      expect(NumberFormatter.formatNumber(42.5), equals('42.5'));
      expect(NumberFormatter.formatNumber(3.14159), equals('3.14159'));
      expect(NumberFormatter.formatNumber(0.123456789), equals('0.12345679'));
    });

    test('formatWithDecimals', () {
      expect(NumberFormatter.formatWithDecimals(3.14159, decimalPlaces: 2), equals('3.14'));
      expect(NumberFormatter.formatWithDecimals(3.14159, decimalPlaces: 0), equals('3'));
      expect(NumberFormatter.formatWithDecimals(3.14159, decimalPlaces: 4), equals('3.1416'));
    });

    test('formatCurrency', () {
      expect(NumberFormatter.formatCurrency(1234.56, symbol: '\$'), equals('\$1,234.56'));
      expect(NumberFormatter.formatCurrency(1234.56, currencyCode: 'EUR', symbol: '€'), equals('€1,234.56'));
      expect(NumberFormatter.formatCurrency(1234.56, symbol: '£'), equals('£1,234.56'));
    });

    test('formatPercentage', () {
      expect(NumberFormatter.formatPercentage(0.5), equals('50%'));
      expect(NumberFormatter.formatPercentage(0.1234), equals('12.3%'));
      expect(NumberFormatter.formatPercentage(1.0), equals('100%'));
    });

    test('formatWithThousands', () {
      expect(NumberFormatter.formatWithThousands(1000), equals('1,000'));
      expect(NumberFormatter.formatWithThousands(1234.56, decimalDigits: 2), equals('1,234.56'));
      expect(NumberFormatter.formatWithThousands(1234567), equals('1,234,567'));
    });

    test('formatScientific', () {
      expect(NumberFormatter.formatScientific(1000), equals('1E+3'));
      expect(NumberFormatter.formatScientific(0.001), equals('1E-3'));
      expect(NumberFormatter.formatScientific(12345), equals('1.23E+4'));
    });

    test('truncate', () {
      expect(NumberFormatter.truncate(3.14159, decimalPlaces: 2), equals('3.14'));
      expect(NumberFormatter.truncate(3.149, decimalPlaces: 2), equals('3.14'));
      expect(NumberFormatter.truncate(3.1, decimalPlaces: 2), equals('3.1'));
    });

    test('round', () {
      expect(NumberFormatter.round(3.14159, decimalPlaces: 2), equals('3.14'));
      expect(NumberFormatter.round(3.149, decimalPlaces: 2), equals('3.15'));
      expect(NumberFormatter.round(3.145, decimalPlaces: 2), equals('3.15'));
    });
  });
}