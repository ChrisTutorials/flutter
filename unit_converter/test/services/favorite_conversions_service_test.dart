import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unit_converter/services/favorite_conversions_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('toggleFavorite saves and removes the same pair', () async {
    final service = FavoriteConversionsService();

    final saved = await service.toggleFavorite(
      categoryName: 'Length',
      fromSymbol: 'm',
      toSymbol: 'ft',
      title: 'Length: m to ft',
    );
    expect(saved, isTrue);
    expect(
      await service.isFavorite(
        categoryName: 'Length',
        fromSymbol: 'm',
        toSymbol: 'ft',
      ),
      isTrue,
    );

    final removed = await service.toggleFavorite(
      categoryName: 'Length',
      fromSymbol: 'm',
      toSymbol: 'ft',
      title: 'Length: m to ft',
    );
    expect(removed, isFalse);
    expect(
      await service.isFavorite(
        categoryName: 'Length',
        fromSymbol: 'm',
        toSymbol: 'ft',
      ),
      isFalse,
    );
  });
}