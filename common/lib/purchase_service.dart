import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling in-app purchases
/// 
/// This service manages one-time purchases for premium features (e.g., ad removal).
/// It integrates with Google Play Billing on Android and handles purchase verification.
class PurchaseService {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product ID for ad removal (configure this in Google Play Console)
  static String _adRemovalProductId = 'ad_removal_one_time';
  
  // Storage keys
  static const String _hasPurchasedAdRemovalKey = 'has_purchased_ad_removal';
  static const String _adRemovalPurchaseTokenKey = 'ad_removal_purchase_token';
  
  // State
  static bool _isInitialized = false;
  static bool _isAvailable = false;
  static List<ProductDetails> _products = [];
  static PurchaseDetails? _pendingPurchase;
  
  // Callbacks
  static Function(String)? _onPurchaseSuccess;
  static Function(String)? _onPurchaseError;
  static Function()? _onPurchasePending;
  
  /// Initialize the purchase service
  /// 
  /// Must be called before using any other methods.
  /// Call this in your app's main() function before runApp().
  static Future<void> initialize({
    String? adRemovalProductId,
    Function(String)? onPurchaseSuccess,
    Function(String)? onPurchaseError,
    Function()? onPurchasePending,
  }) async {
    if (_isInitialized) return;
    
    // Set product ID if provided
    if (adRemovalProductId != null) {
      _adRemovalProductId = adRemovalProductId;
    }
    
    // Set callbacks
    _onPurchaseSuccess = onPurchaseSuccess;
    _onPurchaseError = onPurchaseError;
    _onPurchasePending = onPurchasePending;
    
    // Check if in-app purchases are available
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      debugPrint('PurchaseService: In-app purchases not available on this device');
      _isInitialized = true;
      return;
    }
    
    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );
    
    // Load products
    await loadProducts();
    
    // Restore previous purchases
    await restorePurchases();
    
    _isInitialized = true;
    debugPrint('PurchaseService: Initialized successfully');
  }
  
  /// Load available products from the store
  static Future<void> loadProducts() async {
    if (!_isAvailable) return;
    
    final Set<String> productIds = {_adRemovalProductId};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);
    
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('PurchaseService: Products not found: ${response.notFoundIDs}');
    }
    
    if (response.error != null) {
      debugPrint('PurchaseService: Error loading products: ${response.error}');
      return;
    }
    
    _products = response.productDetails;
    debugPrint('PurchaseService: Loaded ${_products.length} products');
  }
  
  /// Get the ad removal product details
  static ProductDetails? get adRemovalProduct {
    try {
      return _products.firstWhere(
        (product) => product.id == _adRemovalProductId,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Get the price of the ad removal product
  static String? get adRemovalPrice {
    return adRemovalProduct?.price;
  }
  
  /// Check if ad removal is available for purchase
  static bool get isAdRemovalAvailable => adRemovalProduct != null;
  
  /// Purchase ad removal
  /// 
  /// Returns true if the purchase was initiated successfully
  static Future<bool> purchaseAdRemoval() async {
    if (!_isAvailable || !_isInitialized) {
      debugPrint('PurchaseService: Cannot purchase - service not available or initialized');
      return false;
    }
    
    final product = adRemovalProduct;
    if (product == null) {
      debugPrint('PurchaseService: Ad removal product not found');
      return false;
    }
    
    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (success) {
        debugPrint('PurchaseService: Purchase initiated successfully');
      } else {
        debugPrint('PurchaseService: Purchase initiation failed');
      }
      
      return success;
    } catch (e) {
      debugPrint('PurchaseService: Error initiating purchase: $e');
      return false;
    }
  }
  
  /// Handle purchase updates from the store
  static void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }
  
  /// Handle a single purchase
  static Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        debugPrint('PurchaseService: Purchase pending');
        _pendingPurchase = purchaseDetails;
        _onPurchasePending?.call();
        break;
        
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        debugPrint('PurchaseService: Purchase successful: ${purchaseDetails.productID}');
        await _verifyAndDeliverPurchase(purchaseDetails);
        break;
        
      case PurchaseStatus.error:
        debugPrint('PurchaseService: Purchase error: ${purchaseDetails.error}');
        _onPurchaseError?.call(purchaseDetails.error?.message ?? 'Unknown error');
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        break;
        
      case PurchaseStatus.canceled:
        debugPrint('PurchaseService: Purchase canceled');
        _onPurchaseError?.call('Purchase canceled');
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        break;
    }
  }
  
  /// Verify and deliver a purchase
  static Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchaseDetails) async {
    // In a production app, you should verify the purchase with your backend server
    // For now, we'll verify locally
    
    // Check if this is the ad removal product
    if (purchaseDetails.productID == _adRemovalProductId) {
      // Store the purchase
      await _storeAdRemovalPurchase(purchaseDetails);
      
      // Notify success
      _onPurchaseSuccess?.call('Ad removal purchased successfully');
      
      debugPrint('PurchaseService: Ad removal delivered');
    }
    
    // Complete the purchase
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }
  
  /// Store ad removal purchase locally
  static Future<void> _storeAdRemovalPurchase(PurchaseDetails purchaseDetails) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Mark as purchased
    await prefs.setBool(_hasPurchasedAdRemovalKey, true);
    
    // Store purchase token for verification (Android only)
    if (Platform.isAndroid) {
      final androidPurchase = purchaseDetails as GooglePlayPurchaseDetails;
      final purchaseToken = androidPurchase.billingClientPurchase.purchaseToken;
      await prefs.setString(_adRemovalPurchaseTokenKey, purchaseToken);
      debugPrint('PurchaseService: Stored purchase token');
    }
  }
  
  /// Check if user has purchased ad removal
  /// 
  /// This checks both local storage and attempts to restore from the store
  static Future<bool> hasPurchasedAdRemoval() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPurchased = prefs.getBool(_hasPurchasedAdRemovalKey) ?? false;
    
    if (hasPurchased) {
      return true;
    }
    
    // If not found locally, try to restore from store
    if (_isAvailable && _isInitialized) {
      await restorePurchases();
      return prefs.getBool(_hasPurchasedAdRemovalKey) ?? false;
    }
    
    return false;
  }
  
  /// Restore previous purchases
  /// 
  /// Call this when the app starts or when user signs in
  static Future<void> restorePurchases() async {
    if (!_isAvailable || !_isInitialized) {
      debugPrint('PurchaseService: Cannot restore purchases - service not available');
      return;
    }
    
    try {
      debugPrint('PurchaseService: Restoring purchases...');
      await _inAppPurchase.restorePurchases();
      debugPrint('PurchaseService: Restore purchases initiated');
    } catch (e) {
      debugPrint('PurchaseService: Error restoring purchases: $e');
    }
  }
  
  /// Clear ad removal purchase (for testing only)
  static Future<void> clearAdRemovalPurchase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasPurchasedAdRemovalKey);
    await prefs.remove(_adRemovalPurchaseTokenKey);
    debugPrint('PurchaseService: Ad removal purchase cleared (testing only)');
  }
  
  /// Update stream on done
  static void _updateStreamOnDone() {
    _subscription?.cancel();
    debugPrint('PurchaseService: Purchase stream closed');
  }
  
  /// Update stream on error
  static void _updateStreamOnError(dynamic error) {
    debugPrint('PurchaseService: Purchase stream error: $error');
  }
  
  /// Dispose of the purchase service
  static void dispose() {
    _subscription?.cancel();
    _isInitialized = false;
    debugPrint('PurchaseService: Disposed');
  }
  
  // Getters
  static bool get isInitialized => _isInitialized;
  static bool get isAvailable => _isAvailable;
  static String get adRemovalProductId => _adRemovalProductId;
}
