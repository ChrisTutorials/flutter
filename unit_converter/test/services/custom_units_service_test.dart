import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/services/custom_units_service.dart';
import 'package:unit_converter/models/conversion.dart';

void main() {
  group('CustomUnitsService', () {
    late CustomUnitsService service;

    setUp(() {
      service = CustomUnitsService.instance;
    });

    test('generateId produces unique IDs', () {
      final ids = <String>{};
      
      // Generate 1000 IDs rapidly
      for (var i = 0; i < 1000; i++) {
        final id = service.generateId();
        expect(ids.contains(id), false, reason: 'Duplicate ID found: $id');
        ids.add(id);
      }
    });

    test('generateId uses microsecond precision', () {
      final id1 = service.generateId();
      final id2 = service.generateId();
      
      // IDs should be different even when called in quick succession
      expect(id1, isNot(equals(id2)));
    });

    test('CustomUnit JSON roundtrip preserves data', () {
      final original = CustomUnit(
        id: 'test_id_123',
        name: 'Test Unit',
        symbol: 'tu',
        conversionFactor: 1.5,
        categoryName: 'Test Category',
        createdAt: DateTime(2024, 1, 15, 10, 30, 0),
      );

      final json = original.toJson();
      final restored = CustomUnit.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.symbol, equals(original.symbol));
      expect(restored.conversionFactor, equals(original.conversionFactor));
      expect(restored.categoryName, equals(original.categoryName));
      expect(restored.createdAt, equals(original.createdAt));
    });

    test('CustomUnit copyWith creates modified copy', () {
      final original = CustomUnit(
        id: 'test_id',
        name: 'Original Name',
        symbol: 'on',
        conversionFactor: 1.0,
        categoryName: 'Category',
        createdAt: DateTime.now(),
      );

      final modified = original.copyWith(
        name: 'Modified Name',
        conversionFactor: 2.5,
      );

      expect(modified.id, equals(original.id));
      expect(modified.name, equals('Modified Name'));
      expect(modified.symbol, equals(original.symbol));
      expect(modified.conversionFactor, equals(2.5));
      expect(modified.categoryName, equals(original.categoryName));
    });
  });
}
