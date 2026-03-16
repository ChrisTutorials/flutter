import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'premium_service.dart';
import 'admob_service.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal({InAppPurchase? inAppPurchase, bool? platformSupported})
    : _inAppPurchaseOverride = inAppPurchase,
      _platformSupportedOverride = platformSupported;

  @visibleForTesting
  factory PurchaseService.test({
    required InAppPurchase inAppPurchase,
    required bool platformSupported,
  }) {
    return PurchaseService._internal(
      inAppPurchase: inAppPurchase,
      platformSupported: platformSupported,
    );
  }

  static const String _noAdsProductId = 'no_ads_premium';
  static const Set<String> _productIds = {_noAdsProductId};
  
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final InAppPurchase? _inAppPurchaseOverride;
  final bool? _platformSupportedOverride;
  
  ProductDetails? _noAdsProduct;
  bool _isAvailable = false;
  bool _isPurchasePending = false;
  String? _errorMessage;
  bool _hasActiveSubscription = false;

  // Getters
  bool get isAvailable => _isAvailable;
  bool get isPurchasePending => _isPurchasePending;
  String? get errorMessage => _errorMessage;
  ProductDetails? get noAdsProduct => _noAdsProduct;

  InAppPurchase get _inAppPurchase => _inAppPurchaseOverride ?? InAppPurchase.instance;
  bool get _supportsStore =>
      _platformSupportedOverride ?? (kIsWeb ? false : (Platform.isAndroid || Platform.isIOS));

  Future<void> initialize() async {
    if (!_supportsStore) {
      _isAvailable = false;
      _errorMessage = null;
      return;
    }

    // Check if billing is available
    _isAvailable = await _inAppPurchase.isAvailable();

    if (_isAvailable) {
      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _listenToPurchaseUpdated,
        onDone: () => _subscription.cancel(),
        onError: (error) {
          _errorMessage = 'Purchase stream error: $error';
        },
      );
      _hasActiveSubscription = true;

      // Load products
      await _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        _errorMessage = 'Products not found: ${response.notFoundIDs.join(', ')}. '
            'Please verify the product is registered and activated in Google Play Console.';
        return;
      }

      if (response.productDetails.isEmpty) {
        _errorMessage = 'No products available. '
            'Please verify the product is activated in Google Play Console (not in Draft state).';
        return;
      }

      _noAdsProduct = response.productDetails.firstWhere(
        (product) => product.id == _noAdsProductId,
      );

      _errorMessage = null;
    } catch (e) {
      // Provide more helpful error messages for common issues
      String errorMsg = 'Error loading products: $e';

      if (e.toString().contains('subtype') || e.toString().contains('GooglePlayProductDetails')) {
        errorMsg = 'Product configuration error: The product may not be properly registered in Google Play Console. '
            'Please verify that "no_ads_premium" is registered as an In-app product (not subscription) '
            'and is in Active state (not Draft).';
      } else if (e.toString().contains('Billing')) {
        errorMsg = 'Google Play Billing error: Please ensure Google Play Services is up to date and the app is signed correctly.';
      }

      _errorMessage = errorMsg;
    }
  }

  Future<bool> purchaseNoAds() async {
    if (!_isAvailable || _noAdsProduct == null) {
      _errorMessage = 'Purchase not available';
      return false;
    }

    try {
      _isPurchasePending = true;
      _errorMessage = null;

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: _noAdsProduct!,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } catch (e) {
      _errorMessage = 'Purchase failed: $e';
      _isPurchasePending = false;
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_supportsStore) {
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Restore failed: $e';
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _isPurchasePending = true;
        return;
      }

      if (purchaseDetails.status == PurchaseStatus.error) {
        _errorMessage = purchaseDetails.error?.message ?? 'Unknown purchase error';
        _isPurchasePending = false;
        return;
      }

      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        
        // Verify this is our product
        if (purchaseDetails.productID == _noAdsProductId) {
          // Grant premium access
          await PremiumService.setPremium(true);
          
          // Update ad service
          await AdMobService.setPremiumStatus(true);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }

      _isPurchasePending = false;
    } catch (e) {
      _errorMessage = 'Error handling purchase: $e';
      _isPurchasePending = false;
    }
  }

  void dispose() {
    if (_hasActiveSubscription) {
      _subscription.cancel();
      _hasActiveSubscription = false;
    }
  }
}
