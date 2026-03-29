import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/models/favorite_conversion.dart';

void main() {
  group('FavoriteConversion', () {
    test('should create a FavoriteConversion with required fields', () {
      final favorite = FavoriteConversion(
        fromSymbol: 'm',
        toSymbol: 'ft',
        categoryName: 'Length',
        title: 'Meter to Foot',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(favorite.fromSymbol, 'm');
      expect(favorite.toSymbol, 'ft');
      expect(favorite.categoryName, 'Length');
      expect(favorite.title, 'Meter to Foot');
      expect(favorite.createdAt, DateTime(2024, 1, 1));
    });

    test('should generate correct id from components', () {
      final favorite = FavoriteConversion(
        fromSymbol: 'kg',
        toSymbol: 'lb',
        categoryName: 'Weight',
        title: 'Kilogram to Pound',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(favorite.id, 'Weight:kg:lb');
    });

    test('should convert to JSON', () {
      final favorite = FavoriteConversion(
        fromSymbol: '°C',
        toSymbol: '°F',
        categoryName: 'Temperature',
        title: 'Celsius to Fahrenheit',
        createdAt: DateTime(2024, 1, 15, 10, 30),
      );

      final json = favorite.toJson();

      expect(json['fromSymbol'], '°C');
      expect(json['toSymbol'], '°F');
      expect(json['categoryName'], 'Temperature');
      expect(json['title'], 'Celsius to Fahrenheit');
      expect(json['createdAt'], '2024-01-15T10:30:00.000');
    });

    test('should create from JSON', () {
      final json = {
        'categoryName': 'Volume',
        'fromSymbol': 'L',
        'toSymbol': 'gal',
        'title': 'Liter to Gallon',
        'createdAt': '2024-02-20T14:45:00.000Z',
      };

      final favorite = FavoriteConversion.fromJson(json);

      expect(favorite.fromSymbol, 'L');
      expect(favorite.toSymbol, 'gal');
      expect(favorite.categoryName, 'Volume');
      expect(favorite.title, 'Liter to Gallon');
      expect(favorite.createdAt.isUtc, true);
      expect(favorite.createdAt.year, 2024);
      expect(favorite.createdAt.month, 2);
      expect(favorite.createdAt.day, 20);
    });

    test('should have same id for same conversion', () {
      final favorite1 = FavoriteConversion(
        fromSymbol: 'km',
        toSymbol: 'mi',
        categoryName: 'Length',
        title: 'Kilometer to Mile',
        createdAt: DateTime(2024, 1, 1),
      );

      final favorite2 = FavoriteConversion(
        fromSymbol: 'km',
        toSymbol: 'mi',
        categoryName: 'Length',
        title: 'Kilometer to Mile',
        createdAt: DateTime(2024, 2, 1),
      );

      expect(favorite1.id, equals(favorite2.id));
    });

    test('should have different id for different conversions', () {
      final favorite1 = FavoriteConversion(
        fromSymbol: 'km',
        toSymbol: 'mi',
        categoryName: 'Length',
        title: 'Kilometer to Mile',
        createdAt: DateTime(2024, 1, 1),
      );

      final favorite2 = FavoriteConversion(
        fromSymbol: 'mi',
        toSymbol: 'km',
        categoryName: 'Length',
        title: 'Mile to Kilometer',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(favorite1.id, isNot(equals(favorite2.id)));
    });

    test('should handle special characters in symbols', () {
      final favorite = FavoriteConversion(
        fromSymbol: '°F',
        toSymbol: '°C',
        categoryName: 'Temperature',
        title: 'Fahrenheit to Celsius',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(favorite.fromSymbol, '°F');
      expect(favorite.toSymbol, '°C');
      expect(favorite.id, 'Temperature:°F:°C');
    });

    test('should handle empty strings in fields', () {
      final favorite = FavoriteConversion(
        fromSymbol: '',
        toSymbol: '',
        categoryName: '',
        title: '',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(favorite.fromSymbol, '');
      expect(favorite.toSymbol, '');
      expect(favorite.categoryName, '');
      expect(favorite.title, '');
      expect(favorite.id, '::');
    });
  });
}
