import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/unit_settings_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UnitSettingsService - Currency Visibility', () {
    test('getHiddenCurrencies returns defaults when no prefs set', () async {
      SharedPreferences.setMockInitialValues({});
      
      final hidden = await UnitSettingsService.getHiddenCurrencies();
      
      expect(hidden, contains('VND'));
      expect(hidden.length, 1);
    });

    test('getHiddenCurrencies returns saved preferences', () async {
      SharedPreferences.setMockInitialValues({
        'hidden_currencies': ['VND', 'THB'],
      });
      
      final hidden = await UnitSettingsService.getHiddenCurrencies();
      
      expect(hidden, contains('VND'));
      expect(hidden, contains('THB'));
      expect(hidden.length, 2);
    });

    test('toggleCurrencyVisibility adds currency to hidden', () async {
      SharedPreferences.setMockInitialValues({});
      
      await UnitSettingsService.toggleCurrencyVisibility('USD');
      
      final hidden = await UnitSettingsService.getHiddenCurrencies();
      expect(hidden, contains('USD'));
      expect(hidden, contains('VND'));
    });

    test('toggleCurrencyVisibility removes currency from hidden', () async {
      SharedPreferences.setMockInitialValues({
        'hidden_currencies': ['VND', 'USD'],
      });
      
      await UnitSettingsService.toggleCurrencyVisibility('VND');
      
      final hidden = await UnitSettingsService.getHiddenCurrencies();
      expect(hidden, isNot(contains('VND')));
      expect(hidden, contains('USD'));
    });

    test('setHiddenCurrencies saves correctly', () async {
      SharedPreferences.setMockInitialValues({});
      
      await UnitSettingsService.setHiddenCurrencies({'EUR', 'GBP'});
      
      final hidden = await UnitSettingsService.getHiddenCurrencies();
      expect(hidden, contains('EUR'));
      expect(hidden, contains('GBP'));
    });

    test('resetCurrencyDefaults resets to VND only', () async {
      SharedPreferences.setMockInitialValues({
        'hidden_currencies': ['EUR', 'GBP', 'JPY'],
      });
      
      await UnitSettingsService.resetCurrencyDefaults();
      
      final hidden = await UnitSettingsService.getHiddenCurrencies();
      expect(hidden, equals({'VND'}));
    });

    test('isCurrencyHidden returns true for hidden currencies', () async {
      SharedPreferences.setMockInitialValues({
        'hidden_currencies': ['VND'],
      });
      
      final isHidden = await UnitSettingsService.isCurrencyHidden('VND');
      expect(isHidden, isTrue);
    });

    test('isCurrencyHidden returns false for visible currencies', () async {
      SharedPreferences.setMockInitialValues({
        'hidden_currencies': ['VND'],
      });
      
      final isHidden = await UnitSettingsService.isCurrencyHidden('USD');
      expect(isHidden, isFalse);
    });

    test('filterCurrencies removes hidden currencies from map', () async {
      SharedPreferences.setMockInitialValues({
        'hidden_currencies': ['VND'],
      });
      
      final currencies = {
        'USD': 'United States Dollar',
        'EUR': 'Euro',
        'VND': 'Vietnamese Dong',
        'GBP': 'British Pound',
      };
      
      final filtered = await UnitSettingsService.filterCurrencies(currencies);
      
      expect(filtered.containsKey('USD'), isTrue);
      expect(filtered.containsKey('EUR'), isTrue);
      expect(filtered.containsKey('GBP'), isTrue);
      expect(filtered.containsKey('VND'), isFalse);
      expect(filtered.length, 3);
    });

    test('filterCurrencies returns all when none hidden', () async {
      SharedPreferences.setMockInitialValues({});
      
      final currencies = {
        'USD': 'United States Dollar',
        'EUR': 'Euro',
        'VND': 'Vietnamese Dong',
      };
      
      final filtered = await UnitSettingsService.filterCurrencies(currencies);
      
      expect(filtered.length, 2);
      expect(filtered.containsKey('VND'), isFalse);
    });
  });

  group('UnitSettingsService - Unit Visibility', () {
    test('getHiddenUnits returns defaults when no prefs set', () async {
      SharedPreferences.setMockInitialValues({});
      
      final hidden = await UnitSettingsService.getHiddenUnits();
      
      expect(hidden, contains('Micrometer'));
      expect(hidden, contains('Milligram'));
    });

    test('toggleUnitVisibility works correctly', () async {
      SharedPreferences.setMockInitialValues({});
      
      await UnitSettingsService.toggleUnitVisibility('Meter');
      
      final hidden = await UnitSettingsService.getHiddenUnits();
      expect(hidden, contains('Meter'));
      expect(hidden, contains('Micrometer'));
    });
  });
}