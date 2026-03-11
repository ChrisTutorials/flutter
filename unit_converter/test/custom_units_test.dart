import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/models/conversion.dart';
import 'package:unit_converter/services/custom_units_service.dart';

void main() {
  group('CustomUnit Model', () {
    test('should create CustomUnit with all fields', () {
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      expect(customUnit.id, '1');
      expect(customUnit.name, 'Furlong');
      expect(customUnit.symbol, 'fur');
      expect(customUnit.conversionFactor, 201.168);
      expect(customUnit.categoryName, 'Length');
      expect(customUnit.createdAt, DateTime(2026, 3, 11));
    });

    test('should serialize to JSON correctly', () {
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11, 12, 30),
      );

      final json = customUnit.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Furlong');
      expect(json['symbol'], 'fur');
      expect(json['conversionFactor'], 201.168);
      expect(json['categoryName'], 'Length');
      expect(json['createdAt'], '2026-03-11T12:30:00.000');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': '1',
        'name': 'Furlong',
        'symbol': 'fur',
        'conversionFactor': 201.168,
        'categoryName': 'Length',
        'createdAt': '2026-03-11T12:30:00.000',
      };

      final customUnit = CustomUnit.fromJson(json);

      expect(customUnit.id, '1');
      expect(customUnit.name, 'Furlong');
      expect(customUnit.symbol, 'fur');
      expect(customUnit.conversionFactor, 201.168);
      expect(customUnit.categoryName, 'Length');
      expect(customUnit.createdAt, DateTime(2026, 3, 11, 12, 30));
    });

    test('should copy with updated values', () {
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      final updated = customUnit.copyWith(
        name: 'Mile',
        conversionFactor: 1609.344,
      );

      expect(updated.id, '1'); // unchanged
      expect(updated.name, 'Mile'); // updated
      expect(updated.symbol, 'fur'); // unchanged
      expect(updated.conversionFactor, 1609.344); // updated
      expect(updated.categoryName, 'Length'); // unchanged
      expect(updated.createdAt, DateTime(2026, 3, 11)); // unchanged
    });
  });

  group('Unit.fromCustomUnit', () {
    test('should create Unit from CustomUnit', () {
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      final unit = Unit.fromCustomUnit(customUnit);

      expect(unit.name, 'Furlong');
      expect(unit.symbol, 'fur');
      expect(unit.conversionFactor, 201.168);
    });
  });

  group('CustomUnitsService', () {
    late CustomUnitsService service;

    setUp(() async {
      // Clear any existing data
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_units');
      service = CustomUnitsService();
    });

    test('should generate unique ID', () async {
      final id1 = service.generateId();
      // Small delay to ensure different timestamp
      await Future.delayed(const Duration(milliseconds: 1));
      final id2 = service.generateId();

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
    });

    test('should save and retrieve custom unit', () async {
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(customUnit);
      final retrieved = await service.getCustomUnits();

      expect(retrieved.length, 1);
      expect(retrieved[0].id, '1');
      expect(retrieved[0].name, 'Furlong');
      expect(retrieved[0].symbol, 'fur');
      expect(retrieved[0].conversionFactor, 201.168);
      expect(retrieved[0].categoryName, 'Length');
    });

    test('should update existing custom unit', () async {
      final customUnit1 = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      final customUnit2 = CustomUnit(
        id: '1', // same ID
        name: 'Furlong Updated',
        symbol: 'fur',
        conversionFactor: 201.169,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(customUnit1);
      await service.saveCustomUnit(customUnit2);
      final retrieved = await service.getCustomUnits();

      expect(retrieved.length, 1); // Should only have one
      expect(retrieved[0].name, 'Furlong Updated');
      expect(retrieved[0].conversionFactor, 201.169);
    });

    test('should save multiple custom units', () async {
      final unit1 = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      final unit2 = CustomUnit(
        id: '2',
        name: 'Stone',
        symbol: 'st',
        conversionFactor: 6.35029318,
        categoryName: 'Weight',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(unit1);
      await service.saveCustomUnit(unit2);
      final retrieved = await service.getCustomUnits();

      expect(retrieved.length, 2);
      expect(retrieved.any((u) => u.name == 'Furlong'), true);
      expect(retrieved.any((u) => u.name == 'Stone'), true);
    });

    test('should delete custom unit', () async {
      final unit1 = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      final unit2 = CustomUnit(
        id: '2',
        name: 'Stone',
        symbol: 'st',
        conversionFactor: 6.35029318,
        categoryName: 'Weight',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(unit1);
      await service.saveCustomUnit(unit2);
      await service.deleteCustomUnit('1');
      final retrieved = await service.getCustomUnits();

      expect(retrieved.length, 1);
      expect(retrieved[0].id, '2');
      expect(retrieved[0].name, 'Stone');
    });

    test('should get custom units for specific category', () async {
      final unit1 = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      final unit2 = CustomUnit(
        id: '2',
        name: 'Stone',
        symbol: 'st',
        conversionFactor: 6.35029318,
        categoryName: 'Weight',
        createdAt: DateTime(2026, 3, 11),
      );

      final unit3 = CustomUnit(
        id: '3',
        name: 'Yard',
        symbol: 'yd',
        conversionFactor: 0.9144,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(unit1);
      await service.saveCustomUnit(unit2);
      await service.saveCustomUnit(unit3);
      final lengthUnits = await service.getCustomUnitsForCategory('Length');
      final weightUnits = await service.getCustomUnitsForCategory('Weight');

      expect(lengthUnits.length, 2);
      expect(weightUnits.length, 1);
      expect(lengthUnits.every((u) => u.categoryName == 'Length'), true);
      expect(weightUnits.every((u) => u.categoryName == 'Weight'), true);
    });

    test('should check if custom unit exists', () async {
      final unit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(unit);
      final exists = await service.customUnitExists('fur', 'Length');
      final notExists = await service.customUnitExists('xyz', 'Length');

      expect(exists, true);
      expect(notExists, false);
    });

    test(
      'should not conflict with same symbol in different categories',
      () async {
        final unit1 = CustomUnit(
          id: '1',
          name: 'Pound',
          symbol: 'lb',
          conversionFactor: 0.45359237,
          categoryName: 'Weight',
          createdAt: DateTime(2026, 3, 11),
        );

        final unit2 = CustomUnit(
          id: '2',
          name: 'Pound Force',
          symbol: 'lb',
          conversionFactor: 4.448221615,
          categoryName: 'Force',
          createdAt: DateTime(2026, 3, 11),
        );

        await service.saveCustomUnit(unit1);
        await service.saveCustomUnit(unit2);

        final weightExists = await service.customUnitExists('lb', 'Weight');
        final forceExists = await service.customUnitExists('lb', 'Force');

        expect(weightExists, true);
        expect(forceExists, true);
      },
    );

    test('should clear all custom units', () async {
      final unit1 = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      final unit2 = CustomUnit(
        id: '2',
        name: 'Stone',
        symbol: 'st',
        conversionFactor: 6.35029318,
        categoryName: 'Weight',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(unit1);
      await service.saveCustomUnit(unit2);
      await service.clearAllCustomUnits();
      final retrieved = await service.getCustomUnits();

      expect(retrieved.length, 0);
    });

    test('should handle corrupted data gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_units', 'invalid json');

      final retrieved = await service.getCustomUnits();

      expect(retrieved, isEmpty);
    });

    test('should handle empty storage', () async {
      final retrieved = await service.getCustomUnits();

      expect(retrieved, isEmpty);
    });
  });

  group('ConversionData with Custom Units', () {
    late CustomUnitsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_units');
      service = CustomUnitsService();
    });

    test('should merge custom units into categories', () async {
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(customUnit);
      final categories = await ConversionData.getCategoriesWithCustomUnits();

      final lengthCategory = categories.firstWhere((c) => c.name == 'Length');
      expect(lengthCategory.units.any((u) => u.symbol == 'fur'), true);
      expect(lengthCategory.units.any((u) => u.name == 'Furlong'), true);
    });

    test('should get specific category with custom units', () async {
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(customUnit);
      final lengthCategory = await ConversionData.getCategoryWithCustomUnits(
        'Length',
      );

      expect(lengthCategory, isNotNull);
      expect(lengthCategory!.name, 'Length');
      expect(lengthCategory.units.any((u) => u.symbol == 'fur'), true);
    });

    test('should convert using custom units', () async {
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(customUnit);
      final categories = await ConversionData.getCategoriesWithCustomUnits();
      final lengthCategory = categories.firstWhere((c) => c.name == 'Length');

      final furlongUnit = lengthCategory.units.firstWhere(
        (u) => u.symbol == 'fur',
      );
      final meterUnit = lengthCategory.units.firstWhere((u) => u.symbol == 'm');

      // 1 furlong = 201.168 meters
      final result = ConversionData.convert(
        1,
        furlongUnit,
        meterUnit,
        'Length',
      );

      expect(result, closeTo(201.168, 0.001));
    });

    test('should handle multiple custom units in same category', () async {
      final unit1 = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      final unit2 = CustomUnit(
        id: '2',
        name: 'Chain',
        symbol: 'ch',
        conversionFactor: 20.1168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(unit1);
      await service.saveCustomUnit(unit2);
      final categories = await ConversionData.getCategoriesWithCustomUnits();
      final lengthCategory = categories.firstWhere((c) => c.name == 'Length');

      expect(lengthCategory.units.any((u) => u.symbol == 'fur'), true);
      expect(lengthCategory.units.any((u) => u.symbol == 'ch'), true);
    });

    test('should not affect other categories', () async {
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(customUnit);
      final categories = await ConversionData.getCategoriesWithCustomUnits();
      final weightCategory = categories.firstWhere((c) => c.name == 'Weight');

      // Weight category should not have the custom length unit
      expect(weightCategory.units.any((u) => u.symbol == 'fur'), false);
    });
  });

  group('Conversion with Custom Units - Integration', () {
    late CustomUnitsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_units');
      service = CustomUnitsService();
    });

    test('should convert from custom unit to standard unit', () async {
      // Add furlong: 1 furlong = 201.168 meters
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(customUnit);
      final categories = await ConversionData.getCategoriesWithCustomUnits();
      final lengthCategory = categories.firstWhere((c) => c.name == 'Length');

      final furlong = lengthCategory.units.firstWhere((u) => u.symbol == 'fur');
      final meter = lengthCategory.units.firstWhere((u) => u.symbol == 'm');

      // 10 furlongs to meters
      final result = ConversionData.convert(10, furlong, meter, 'Length');
      expect(result, closeTo(2011.68, 0.01));
    });

    test('should convert from standard unit to custom unit', () async {
      // Add furlong: 1 furlong = 201.168 meters
      final customUnit = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(customUnit);
      final categories = await ConversionData.getCategoriesWithCustomUnits();
      final lengthCategory = categories.firstWhere((c) => c.name == 'Length');

      final furlong = lengthCategory.units.firstWhere((u) => u.symbol == 'fur');
      final meter = lengthCategory.units.firstWhere((u) => u.symbol == 'm');

      // 1000 meters to furlongs
      final result = ConversionData.convert(1000, meter, furlong, 'Length');
      expect(result, closeTo(4.97097, 0.001));
    });

    test('should convert between two custom units', () async {
      // Add furlong: 1 furlong = 201.168 meters
      final furlong = CustomUnit(
        id: '1',
        name: 'Furlong',
        symbol: 'fur',
        conversionFactor: 201.168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      // Add chain: 1 chain = 20.1168 meters
      final chain = CustomUnit(
        id: '2',
        name: 'Chain',
        symbol: 'ch',
        conversionFactor: 20.1168,
        categoryName: 'Length',
        createdAt: DateTime(2026, 3, 11),
      );

      await service.saveCustomUnit(furlong);
      await service.saveCustomUnit(chain);
      final categories = await ConversionData.getCategoriesWithCustomUnits();
      final lengthCategory = categories.firstWhere((c) => c.name == 'Length');

      final furlongUnit = lengthCategory.units.firstWhere(
        (u) => u.symbol == 'fur',
      );
      final chainUnit = lengthCategory.units.firstWhere(
        (u) => u.symbol == 'ch',
      );

      // 10 furlongs to chains
      final result = ConversionData.convert(
        10,
        furlongUnit,
        chainUnit,
        'Length',
      );
      // 10 furlongs = 2011.68 meters
      // 2011.68 / 20.1168 = 100 chains
      expect(result, closeTo(100.0, 0.01));
    });
  });
}
