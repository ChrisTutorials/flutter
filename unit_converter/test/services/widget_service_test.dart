import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/services/widget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WidgetService', () {
    test('androidProviderName should be defined', () {
      expect(WidgetService.androidProviderName, 'UnitConverterWidgetProvider');
    });

    test('non-Android calls return safely', () async {
      await expectLater(WidgetService.isAvailable(), completion(isFalse));
      await expectLater(
        WidgetService.saveLatestConversion(
          title: 'Length',
          result: '1 m = 100 cm',
          preset: '1 in = 2.54 cm',
        ),
        completes,
      );
      await expectLater(WidgetService.requestPin(), completes);
    });
  });
}
