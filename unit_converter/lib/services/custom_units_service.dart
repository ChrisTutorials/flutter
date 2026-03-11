import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversion.dart';

/// Service for managing custom units
class CustomUnitsService {
  static const String _key = 'custom_units';

  /// Save a custom unit
  Future<void> saveCustomUnit(CustomUnit customUnit) async {
    final prefs = await SharedPreferences.getInstance();
    final customUnits = await getCustomUnits();

    // Check if unit with same symbol already exists in same category
    final existingIndex = customUnits.indexWhere(
      (u) =>
          u.symbol == customUnit.symbol &&
          u.categoryName == customUnit.categoryName,
    );

    if (existingIndex != -1) {
      // Update existing unit
      customUnits[existingIndex] = customUnit;
    } else {
      // Add new unit
      customUnits.add(customUnit);
    }

    // Save to preferences
    final jsonString = jsonEncode(customUnits.map((u) => u.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  /// Get all custom units
  Future<List<CustomUnit>> getCustomUnits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => CustomUnit.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get custom units for a specific category
  Future<List<CustomUnit>> getCustomUnitsForCategory(
    String categoryName,
  ) async {
    final allCustomUnits = await getCustomUnits();
    return allCustomUnits.where((u) => u.categoryName == categoryName).toList();
  }

  /// Delete a custom unit
  Future<void> deleteCustomUnit(String id) async {
    final customUnits = await getCustomUnits();
    customUnits.removeWhere((u) => u.id == id);

    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(customUnits.map((u) => u.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  /// Check if a custom unit with given symbol exists in category
  Future<bool> customUnitExists(String symbol, String categoryName) async {
    final customUnits = await getCustomUnitsForCategory(categoryName);
    return customUnits.any((u) => u.symbol == symbol);
  }

  /// Generate a unique ID for a custom unit
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Clear all custom units
  Future<void> clearAllCustomUnits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
