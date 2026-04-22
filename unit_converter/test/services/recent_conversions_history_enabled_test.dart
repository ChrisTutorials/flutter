import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/services/recent_conversions_service.dart';
import 'package:unit_converter/models/conversion.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RecentConversionsService - History Enabled Behavior', () {
    test('history enabled by default', () async {
      SharedPreferences.setMockInitialValues({});
      
      final enabled = await RecentConversionsService.isHistoryEnabled();
      expect(enabled, isTrue);
    });

    test('getRecentConversions returns data when history enabled', () async {
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
      expect(recent.first.fromUnit, 'm');
    });

    test('getRecentConversions returns empty when history disabled', () async {
      SharedPreferences.setMockInitialValues({
        'history_enabled': false,
      });
      final service = RecentConversionsService();
      
      // Add data directly to prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('recent_conversions', '[{"category":"Length","fromUnit":"m","toUnit":"ft","inputValue":10,"outputValue":32.8}]');
      
      final recent = await service.getRecentConversions();
      expect(recent, isEmpty);
    });

    test('setHistoryEnabled to false clears recent conversions', () async {
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
      
      expect((await service.getRecentConversions()).length, 1);
      
      await RecentConversionsService.setHistoryEnabled(false);
      
      final recent = await service.getRecentConversions();
      expect(recent, isEmpty);
    });

    test('setHistoryEnabled to true preserves existing data', () async {
      SharedPreferences.setMockInitialValues({});
      final service = RecentConversionsService();
      
      // Save data first while history is enabled
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
      
      // Verify data was saved
      var recent = await service.getRecentConversions();
      expect(recent.length, 1);
      
      // Now disable and re-enable
      await RecentConversionsService.setHistoryEnabled(false);
      await RecentConversionsService.setHistoryEnabled(true);
      
      // Data should still be there since we only cleared when disabling
      recent = await service.getRecentConversions();
      expect(recent.length, 1);
    });

    test('service state reflects isHistoryEnabled correctly', () async {
      SharedPreferences.setMockInitialValues({
        'history_enabled': false,
      });
      
      var enabled = await RecentConversionsService.isHistoryEnabled();
      expect(enabled, isFalse);
      
      await RecentConversionsService.setHistoryEnabled(true);
      enabled = await RecentConversionsService.isHistoryEnabled();
      expect(enabled, isTrue);
    });
  });
}