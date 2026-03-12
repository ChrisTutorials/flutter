import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'premium_service.dart';
import 'admob_service.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  static const String _noAdsProductId = 'no_ads_premium';
  static const Set<String> _productIds = {_noAdsProductId};
  
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  ProductDetails? _noAdsProduct;
  bool _isAvailable = false;
  bool _isPurchasePending = false;
  String? _errorMessage;

  // Getters
  bool get isAvailable => _isAvailable;
  bool get isPurchasePending => _isPurchasePending;
  String? get errorMessage => _errorMessage;
  ProductDetails? get noAdsProduct => _noAdsProduct;

  InAppPurchase get _inAppPurchase => InAppPurchase.instance;

  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
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
      
      // Load products
      await _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        _errorMessage = 'Products not found: ${response.notFoundIDs}';
        return;
      }

      if (response.productDetails.isEmpty) {
        _errorMessage = 'No products available';
        return;
      }

      _noAdsProduct = response.productDetails.firstWhere(
        (product) => product.id == _noAdsProductId,
        orElse: () => response.productDetails.first,
      );
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading products: $e';
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
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
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
    _subscription.cancel();
  }
}
