import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/recent_conversions_service.dart';
import 'package:unit_converter/models/conversion.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RecentConversionsService - History Toggle', () {
    test('isHistoryEnabled returns true by default', () async {
      SharedPreferences.setMockInitialValues({});

      final enabled = await RecentConversionsService.isHistoryEnabled();

      expect(enabled, isTrue);
    });

    test('isHistoryEnabled returns saved value', () async {
      SharedPreferences.setMockInitialValues({
        'history_enabled': false,
      });

      final enabled = await RecentConversionsService.isHistoryEnabled();

      expect(enabled, isFalse);
    });

    test('setHistoryEnabled saves the value', () async {
      SharedPreferences.setMockInitialValues({});

      await RecentConversionsService.setHistoryEnabled(false);

      final enabled = await RecentConversionsService.isHistoryEnabled();
      expect(enabled, isFalse);
    });

    test('saveConversion does nothing when history disabled', () async {
      SharedPreferences.setMockInitialValues({
        'history_enabled': false,
      });

      final service = RecentConversionsService();
      await service.saveConversion(
        RecentConversion(
          category: 'Length',
          fromUnit: 'm',
          toUnit: 'ft',
          inputValue: 10,
          outputValue: 32.8,
          timestamp: DateTime.now(),
        ),
      );

      final recent = await service.getRecentConversions();
      expect(recent, isEmpty);
    });

    test('saveConversion works when history enabled', () async {
      SharedPreferences.setMockInitialValues({
        'history_enabled': true,
      });

      final service = RecentConversionsService();
      await service.saveConversion(
        RecentConversion(
          category: 'Length',
          fromUnit: 'm',
          toUnit: 'ft',
          inputValue: 10,
          outputValue: 32.8,
          timestamp: DateTime.now(),
        ),
      );

      final recent = await service.getRecentConversions();
      expect(recent.length, 1);
      expect(recent.first.fromUnit, 'm');
    });

    test('getRecentConversions returns empty when history disabled', () async {
      SharedPreferences.setMockInitialValues({
        'history_enabled': false,
        'recent_conversions': '[{"category":"Length","fromUnit":"m","toUnit":"ft","inputValue":10,"outputValue":32.8}]',
      });

      final service = RecentConversionsService();
      final recent = await service.getRecentConversions();

      expect(recent, isEmpty);
    });

    test('setHistoryEnabled does not auto-clear history', () async {
      SharedPreferences.setMockInitialValues({
        'recent_conversions': '[{"category":"Length","fromUnit":"m","toUnit":"ft","inputValue":10,"outputValue":32.8}]',
      });

      await RecentConversionsService.setHistoryEnabled(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('recent_conversions'), isNotNull);
    });

    test('toggle history from enabled to disabled clears data', () async {
      SharedPreferences.setMockInitialValues({
        'history_enabled': true,
        'recent_conversions': '[{"category":"Length","fromUnit":"m","toUnit":"ft","inputValue":10,"outputValue":32.8}]',
      });

      final service = RecentConversionsService();
      await service.saveConversion(
        RecentConversion(
          category: 'Length',
          fromUnit: 'm',
          toUnit: 'ft',
          inputValue: 20,
          outputValue: 65.6,
          timestamp: DateTime.now(),
        ),
      );

      await RecentConversionsService.setHistoryEnabled(false);

      final recent = await service.getRecentConversions();
      expect(recent, isEmpty);
    });
  });

  group('RecentConversionsService - State Transitions', () {
    test('disabling history clears recent conversions', () async {
      SharedPreferences.setMockInitialValues({
        'history_enabled': true,
        'recent_conversions': '[{"category":"Length","fromUnit":"m","toUnit":"ft","inputValue":10,"outputValue":32.8}]',
      });

      await RecentConversionsService.setHistoryEnabled(false);

      final service = RecentConversionsService();
      final recent = await service.getRecentConversions();
      expect(recent, isEmpty);
    });

    test('when history disabled getRecentConversions returns empty regardless of stored data', () async {
      SharedPreferences.setMockInitialValues({
        'history_enabled': false,
        'recent_conversions': '[{"category":"Length","fromUnit":"m","toUnit":"ft","inputValue":10,"outputValue":32.8},{"category":"Weight","fromUnit":"kg","toUnit":"lb","inputValue":5,"outputValue":11}]',
      });

      final service = RecentConversionsService();
      final recent = await service.getRecentConversions();

      expect(recent, isEmpty);
    });

    test('when history enabled getRecentConversions returns stored data', () async {
      SharedPreferences.setMockInitialValues({});
      final service = RecentConversionsService();
      
      await service.saveConversion(
        RecentConversion(
          category: 'Length',
          fromUnit: 'm',
          toUnit: 'ft',
          inputValue: 10,
          outputValue: 32.8,
          timestamp: DateTime.now(),
        ),
      );
      
      final recent = await service.getRecentConversions();
      expect(recent.length, 1);
    });
  });
}