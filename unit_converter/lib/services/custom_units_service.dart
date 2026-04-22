import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversion.dart';

/// Service for managing custom units
class CustomUnitsService {
  static CustomUnitsService? _instance;
  static const String _key = 'custom_units';
  static const String _backupKey = 'custom_units_backup';

  CustomUnitsService._();

  /// Get singleton instance
  static CustomUnitsService get instance {
    _instance ??= CustomUnitsService._();
    return _instance!;
  }

  /// Save a custom unit with backup before overwrite
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

    // Create backup before saving
    await _createBackup(customUnits);

    // Save to preferences
    final jsonString = jsonEncode(customUnits.map((u) => u.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  /// Get all custom units with fallback to backup
  Future<List<CustomUnit>> getCustomUnits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      // Try to recover from backup
      return await _tryRecoverFromBackup();
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final units = jsonList.map((json) => CustomUnit.fromJson(json)).toList();
      
      // Validate units
      if (!_validateUnits(units)) {
        // Recovery needed
        return await _tryRecoverFromBackup();
      }
      
      return units;
    } catch (e) {
      // Log error for debugging
      print('Error loading custom units: $e');
      
      // Try to recover from backup
      return await _tryRecoverFromBackup();
    }
  }

  /// Validate unit data integrity
  bool _validateUnits(List<CustomUnit> units) {
    for (final unit in units) {
      // Check required fields are valid
      if (unit.id.isEmpty || 
          unit.name.isEmpty || 
          unit.symbol.isEmpty || 
          unit.categoryName.isEmpty) {
        return false;
      }
      // Check conversion factor is valid
      if (!unit.conversionFactor.isFinite || unit.conversionFactor <= 0) {
        return false;
      }
    }
    return true;
  }

  /// Create backup of current units
  Future<void> _createBackup(List<CustomUnit> units) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(units.map((u) => u.toJson()).toList());
      await prefs.setString(_backupKey, jsonString);
    } catch (e) {
      print('Failed to create backup: $e');
    }
  }

  /// Try to recover from backup
  Future<List<CustomUnit>> _tryRecoverFromBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString(_backupKey);
      
      if (backupJson != null) {
        final List<dynamic> jsonList = jsonDecode(backupJson);
        final units = jsonList.map((json) => CustomUnit.fromJson(json)).toList();
        
        if (_validateUnits(units)) {
          // Restore from backup
          await prefs.setString(_key, backupJson);
          print('Recovered ${units.length} custom units from backup');
          return units;
        }
      }
    } catch (e) {
      print('Failed to recover from backup: $e');
    }
    
    return [];
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
    
    // Create backup before deletion
    await _createBackup(customUnits);
    
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

  /// Generate a unique ID using microseconds for uniqueness
  String generateId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = timestamp % 10000;
    return '${timestamp}_$random';
  }

  /// Clear all custom units
  Future<void> clearAllCustomUnits() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear both main and backup
    await prefs.remove(_key);
    await prefs.remove(_backupKey);
  }
}

/// JSON encoding helper extension
extension CustomUnitJson on List<CustomUnit> {
  String toJsonString() {
    return jsonEncode(map((u) => u.toJson()).toList());
  }
}
