import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/services/recent_conversions_service.dart';

void main() {
  group('RecentConversionsService', () {
    late SharedPreferences prefs;
    late RecentConversionsService service;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = RecentConversionsService();
    });

    test('should save and retrieve a conversion', () async {
      final conversion = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 1000.0,
        outputValue: 1.0,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      await service.saveConversion(conversion);
      final conversions = await service.getRecentConversions();

      expect(conversions.length, 1);
      expect(conversions[0].category, 'Length');
      expect(conversions[0].fromUnit, 'm');
      expect(conversions[0].toUnit, 'km');
      expect(conversions[0].inputValue, 1000.0);
      expect(conversions[0].outputValue, 1.0);
    });

    test('should maintain order with most recent first', () async {
      final conversion1 = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 1000.0,
        outputValue: 1.0,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      final conversion2 = RecentConversion(
        category: 'Weight',
        fromUnit: 'kg',
        toUnit: 'lb',
        inputValue: 1.0,
        outputValue: 2.20462,
        timestamp: DateTime(2024, 1, 15, 11, 30),
      );

      await service.saveConversion(conversion1);
      await service.saveConversion(conversion2);

      final conversions = await service.getRecentConversions();

      expect(conversions.length, 2);
      expect(conversions[0].category, 'Weight'); // Most recent
      expect(conversions[1].category, 'Length'); // Oldest
    });

    test('should remove duplicates when saving same conversion', () async {
      final conversion = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 1000.0,
        outputValue: 1.0,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      await service.saveConversion(conversion);
      await service.saveConversion(conversion);

      final conversions = await service.getRecentConversions();

      expect(conversions.length, 1);
    });

    test('should limit to 10 recent conversions', () async {
      // Add 11 conversions
      for (int i = 0; i < 11; i++) {
        final conversion = RecentConversion(
          category: 'Length',
          fromUnit: 'm',
          toUnit: 'km',
          inputValue: i.toDouble(),
          outputValue: i / 1000.0,
          timestamp: DateTime(2024, 1, 15, 10, i),
        );
        await service.saveConversion(conversion);
      }

      final conversions = await service.getRecentConversions();

      expect(conversions.length, 10);
      // Should have the most recent 10 (10 down to 1)
      expect(conversions[0].inputValue, 10.0);
      expect(conversions[9].inputValue, 1.0);
    });

    test('should clear all recent conversions', () async {
      final conversion = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 1000.0,
        outputValue: 1.0,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      await service.saveConversion(conversion);
      await service.clearRecentConversions();

      final conversions = await service.getRecentConversions();

      expect(conversions.length, 0);
    });

    test('should delete a specific conversion', () async {
      final conversion1 = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 1000.0,
        outputValue: 1.0,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      final conversion2 = RecentConversion(
        category: 'Weight',
        fromUnit: 'kg',
        toUnit: 'lb',
        inputValue: 1.0,
        outputValue: 2.20462,
        timestamp: DateTime(2024, 1, 15, 11, 30),
      );

      await service.saveConversion(conversion1);
      await service.saveConversion(conversion2);
      await service.deleteConversion(conversion1);

      final conversions = await service.getRecentConversions();

      expect(conversions.length, 1);
      expect(conversions[0].category, 'Weight');
    });

    test('should handle empty storage gracefully', () async {
      final conversions = await service.getRecentConversions();
      expect(conversions.length, 0);
    });

    test('should handle corrupted data gracefully', () async {
      // Manually set corrupted data
      await prefs.setString('recent_conversions', 'invalid json');

      final conversions = await service.getRecentConversions();

      // Should return empty list instead of crashing
      expect(conversions.length, 0);
    });

    test('should distinguish conversions with different values', () async {
      final conversion1 = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 1000.0,
        outputValue: 1.0,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      final conversion2 = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 2000.0,
        outputValue: 2.0,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      await service.saveConversion(conversion1);
      await service.saveConversion(conversion2);

      final conversions = await service.getRecentConversions();

      expect(conversions.length, 2);
    });

    test('should distinguish conversions with different units', () async {
      final conversion1 = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 1000.0,
        outputValue: 1.0,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      final conversion2 = RecentConversion(
        category: 'Length',
        fromUnit: 'km',
        toUnit: 'm',
        inputValue: 1.0,
        outputValue: 1000.0,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      await service.saveConversion(conversion1);
      await service.saveConversion(conversion2);

      final conversions = await service.getRecentConversions();

      expect(conversions.length, 2);
    });

    test('should preserve timestamp correctly', () async {
      final timestamp = DateTime(2024, 1, 15, 10, 30, 45, 123);
      final conversion = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 1000.0,
        outputValue: 1.0,
        timestamp: timestamp,
      );

      await service.saveConversion(conversion);
      final conversions = await service.getRecentConversions();

      expect(conversions[0].timestamp, timestamp);
    });

    test('should handle multiple categories', () async {
      final conversions = [
        RecentConversion(
          category: 'Length',
          fromUnit: 'm',
          toUnit: 'km',
          inputValue: 1000.0,
          outputValue: 1.0,
          timestamp: DateTime(2024, 1, 15, 10, 30),
        ),
        RecentConversion(
          category: 'Weight',
          fromUnit: 'kg',
          toUnit: 'lb',
          inputValue: 1.0,
          outputValue: 2.20462,
          timestamp: DateTime(2024, 1, 15, 11, 30),
        ),
        RecentConversion(
          category: 'Temperature',
          fromUnit: '°C',
          toUnit: '°F',
          inputValue: 0.0,
          outputValue: 32.0,
          timestamp: DateTime(2024, 1, 15, 12, 30),
        ),
      ];

      for (final conversion in conversions) {
        await service.saveConversion(conversion);
      }

      final retrieved = await service.getRecentConversions();

      expect(retrieved.length, 3);
      expect(retrieved[0].category, 'Temperature');
      expect(retrieved[1].category, 'Weight');
      expect(retrieved[2].category, 'Length');
    });

    test('should handle deletion when conversion does not exist', () async {
      final conversion = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 1000.0,
        outputValue: 1.0,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      // Should not throw even if conversion doesn't exist
      await service.deleteConversion(conversion);

      final conversions = await service.getRecentConversions();
      expect(conversions.length, 0);
    });

    test('should handle floating point precision', () async {
      final conversion = RecentConversion(
        category: 'Length',
        fromUnit: 'm',
        toUnit: 'km',
        inputValue: 1234.56789012345,
        outputValue: 1.23456789012345,
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      await service.saveConversion(conversion);
      final conversions = await service.getRecentConversions();

      expect(conversions[0].inputValue, closeTo(1234.56789012345, 0.0001));
      expect(conversions[0].outputValue, closeTo(1.23456789012345, 0.0001));
    });
  });
}
