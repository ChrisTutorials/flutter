import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/purchase_service.dart';
import '../services/premium_service.dart';

class PurchaseButton extends StatefulWidget {
  const PurchaseButton({super.key});

  @override
  State<PurchaseButton> createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<PurchaseButton> {
  final PurchaseService _purchaseService = PurchaseService();
  bool _isLoading = false;
  bool _isPremium = false;
  
  String get _purchaseButtonLabel {
    final price = _purchaseService.noAdsProduct?.price;
    if (price == null || price.isEmpty) {
      return 'Go Ad-Free';
    }
  
    return 'Go Ad-Free - $price';
  }

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final isPremium = await PremiumService.isPremium();
    if (mounted) {
      setState(() {
        _isPremium = isPremium;
      });
    }
  }

  Future<void> _handlePurchase() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _purchaseService.purchaseNoAds();
      
      if (success) {
        // Purchase initiated, wait for completion
        await Future.delayed(const Duration(seconds: 3));
        await _checkPremiumStatus();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _purchaseService.restorePurchases();
      await Future.delayed(const Duration(seconds: 2));
      await _checkPremiumStatus();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPremium) {
      return Card(
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Active',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Enjoy your ad-free experience!',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ad-free upgrade',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        'One-time purchase',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Remove banner and interstitial ads for a cleaner conversion experience.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (_purchaseService.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _purchaseService.errorMessage!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_purchaseButtonLabel),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _isLoading ? null : _restorePurchases,
                  child: const Text('Restore'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
