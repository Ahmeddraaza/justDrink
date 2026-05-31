import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../data/preferences/preferences_service.dart';

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final _purchaseController = StreamController<PurchaseResult>.broadcast();

  // Product IDs — must match exactly in Play Console and App Store Connect
  static const productMonthly = 'justdrink_pro_monthly';  // $3.49/mo
  static const productAnnual  = 'justdrink_pro_annual';   // $19.99/yr

  Stream<PurchaseResult> get purchaseResultStream => _purchaseController.stream;

  Future<List<ProductDetails>> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return [];

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (e) => _purchaseController.add(PurchaseResult.error(e.toString())),
    );

    final response = await _iap.queryProductDetails({productMonthly, productAnnual});
    return response.productDetails;
  }

  Future<void> purchase(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    // Subscriptions always use buyNonConsumable for iOS
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        await PreferencesService.instance.setBool('is_premium', true);
        await PreferencesService.instance.setString(
          'premium_product_id', purchase.productID,
        );
        _purchaseController.add(PurchaseResult.success(purchase.productID));
      } else if (purchase.status == PurchaseStatus.error) {
        _purchaseController.add(
          PurchaseResult.error(purchase.error?.message ?? 'Purchase failed'),
        );
      } else if (purchase.status == PurchaseStatus.canceled) {
        _purchaseController.add(PurchaseResult.cancelled());
      }
    }
  }

  Future<bool> checkExistingPremium() async {
    return PreferencesService.instance.getBool('is_premium') ?? false;
  }

  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}

class PurchaseResult {
  final bool success;
  final bool cancelled;
  final String? productId;
  final String? errorMessage;

  const PurchaseResult._({
    required this.success,
    required this.cancelled,
    this.productId,
    this.errorMessage,
  });

  factory PurchaseResult.success(String productId) =>
      PurchaseResult._(success: true, cancelled: false, productId: productId);
  factory PurchaseResult.error(String msg) =>
      PurchaseResult._(success: false, cancelled: false, errorMessage: msg);
  factory PurchaseResult.cancelled() =>
      PurchaseResult._(success: false, cancelled: true);
}
