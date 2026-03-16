import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:unit_converter/services/purchase_service.dart';

import 'purchase_service_product_loading_regression_test.mocks.dart';

@GenerateMocks([InAppPurchase, ProductDetails])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PurchaseService product loading regression', () {
    late MockInAppPurchase inAppPurchase;
    late StreamController<List<PurchaseDetails>> purchaseStreamController;

    setUp(() {
      inAppPurchase = MockInAppPurchase();
      purchaseStreamController = StreamController<List<PurchaseDetails>>.broadcast();
      when(inAppPurchase.purchaseStream).thenAnswer((_) => purchaseStreamController.stream);
    });

    tearDown(() async {
      await purchaseStreamController.close();
    });

    PurchaseService createService() {
      return PurchaseService.test(
        inAppPurchase: inAppPurchase,
        platformSupported: true,
      );
    }

    test('loads the matching one-time product when returned by billing', () async {
      final matchingProduct = MockProductDetails();
      final otherProduct = MockProductDetails();

      when(otherProduct.id).thenReturn('different_product');
      when(matchingProduct.id).thenReturn('no_ads_premium');
      when(matchingProduct.price).thenReturn(r'$0.99');

      when(inAppPurchase.isAvailable()).thenAnswer((_) async => true);
      when(inAppPurchase.queryProductDetails(any)).thenAnswer(
        (_) async => ProductDetailsResponse(
          productDetails: [otherProduct, matchingProduct],
          notFoundIDs: const <String>[],
        ),
      );

      final service = createService();
      await service.initialize();

      expect(service.isAvailable, isTrue);
      expect(service.noAdsProduct, same(matchingProduct));
      expect(service.errorMessage, isNull);

      service.dispose();
    });

    test('surfaces a clear error when billing returns notFoundIDs', () async {
      when(inAppPurchase.isAvailable()).thenAnswer((_) async => true);
      when(inAppPurchase.queryProductDetails(any)).thenAnswer(
        (_) async => ProductDetailsResponse(
          productDetails: const <ProductDetails>[],
          notFoundIDs: const <String>['no_ads_premium'],
        ),
      );

      final service = createService();
      await service.initialize();

      expect(service.noAdsProduct, isNull);
      expect(service.errorMessage, contains('Products not found'));
      expect(service.errorMessage, contains('no_ads_premium'));

      service.dispose();
    });

    test('surfaces a clear error when billing returns no products', () async {
      when(inAppPurchase.isAvailable()).thenAnswer((_) async => true);
      when(inAppPurchase.queryProductDetails(any)).thenAnswer(
        (_) async => ProductDetailsResponse(
          productDetails: const <ProductDetails>[],
          notFoundIDs: const <String>[],
        ),
      );

      final service = createService();
      await service.initialize();

      expect(service.noAdsProduct, isNull);
      expect(service.errorMessage, contains('No products available'));

      service.dispose();
    });

    test('maps the subtype failure to a configuration-focused error', () async {
      when(inAppPurchase.isAvailable()).thenAnswer((_) async => true);
      when(inAppPurchase.queryProductDetails(any)).thenThrow(
        TypeError(),
      );

      final service = createService();
      await service.initialize();

      expect(service.noAdsProduct, isNull);
      expect(service.errorMessage, isNotNull);

      service.dispose();
    });

    test('does not touch billing on unsupported platforms', () async {
      final service = PurchaseService.test(
        inAppPurchase: inAppPurchase,
        platformSupported: false,
      );

      await service.initialize();

      expect(service.isAvailable, isFalse);
      verifyNever(inAppPurchase.isAvailable());
      verifyNever(inAppPurchase.queryProductDetails(any));
      service.dispose();
    });
  });
}
