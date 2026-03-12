import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/unit_settings_service.dart';
import '../../lib/models/conversion.dart';

void main() {
  group('UnitSettingsService', () {
    setUp(() async {
      // Reset to defaults before each test
      await UnitSettingsService.resetToDefaults();
    });

    test('should hide low-value units by default', () async {
      final hiddenUnits = await UnitSettingsService.getHiddenUnits();
      final lowValueUnits = UnitSettingsService.getLowValueUnits();
      
      expect(hiddenUnits.isNotEmpty, true);
      for (final unit in lowValueUnits) {
        expect(hiddenUnits.contains(unit), true, reason: '$unit should be hidden by default');
      }
    });

    test('should toggle unit visibility', () async {
      const testUnit = 'Micrometer';
      
      // Initially hidden
      expect(await UnitSettingsService.isUnitHidden(testUnit), true);
      
      // Toggle to visible
      await UnitSettingsService.toggleUnitVisibility(testUnit);
      expect(await UnitSettingsService.isUnitHidden(testUnit), false);
      
      // Toggle back to hidden
      await UnitSettingsService.toggleUnitVisibility(testUnit);
      expect(await UnitSettingsService.isUnitHidden(testUnit), true);
    });

    test('should filter units correctly', () async {
      final lengthUnits = ConversionData.lengthCategory.units;
      final filteredUnits = await UnitSettingsService.filterUnits(lengthUnits);
      
      // Should have fewer units after filtering
      expect(filteredUnits.length, lessThan(lengthUnits.length));
      
      // Micrometer should not be in filtered units
      final hasMicrometer = filteredUnits.any((unit) => unit.name == 'Micrometer');
      expect(hasMicrometer, false);
    });

    test('should reset to defaults', () async {
      // First, show all units
      await UnitSettingsService.setHiddenUnits(<String>{});
      expect(await UnitSettingsService.isUnitHidden('Micrometer'), false);
      
      // Reset to defaults
      await UnitSettingsService.resetToDefaults();
      expect(await UnitSettingsService.isUnitHidden('Micrometer'), true);
    });
  });
}

