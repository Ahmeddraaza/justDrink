import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../data/preferences/preferences_service.dart';
import '../data/database/daos/user_profile_dao.dart';
import 'widget_service.dart';

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final _purchaseController = StreamController<PurchaseResult>.broadcast();

  bool _isInitialized = false;
  List<ProductDetails> _cachedProducts = [];

  // Product IDs — must match exactly in App Store Connect
  static const productWeekly = 'justdrink_pro_weekly';
  static const productAnnual = 'justdrink_pro_annual';
  static const productLifetime = 'justdrink_pro_lifetime';

  Stream<PurchaseResult> get purchaseResultStream => _purchaseController.stream;

  Future<List<ProductDetails>> initialize() async {
    // Only set initialized if we actually loaded products successfully
    if (_isInitialized && _cachedProducts.isNotEmpty) return _cachedProducts;

    final available = await _iap.isAvailable();
    if (!available) return [];

    // Ensure we don't listen multiple times
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (e) => _purchaseController.add(PurchaseResult.error(e.toString())),
    );

    final response = await _iap.queryProductDetails({productWeekly, productAnnual, productLifetime});
    _cachedProducts = response.productDetails;

    // Fix #9: Only mark initialized if products loaded — allows retry on empty/misconfigured
    if (_cachedProducts.isNotEmpty) {
      _isInitialized = true;
    }

    return _cachedProducts;
  }

  Future<void> purchase(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    // Subscriptions use buyNonConsumable for iOS StoreKit
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  bool _isCancellationError(IAPError? error) {
    if (error == null) return false;
    final msg = error.message.toLowerCase();
    final code = error.code.toLowerCase();

    if (code.contains('cancel') || code == 'e_user_cancelled' || code == 'user_cancelled') {
      return true;
    }
    if (msg.contains('cancel') || msg.contains('user cancelled')) {
      return true;
    }
    // SKErrorDomain code 2 = user cancelled
    if (code == '2' || msg.contains('skerror') || msg.contains('code 2') || msg.contains('cancelled')) {
      return true;
    }
    return false;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Apple REQUIRES completePurchase to be called, even on restore
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          await PreferencesService.instance.setBool('is_premium', true);
          await PreferencesService.instance.setString(
            'premium_product_id', purchase.productID,
          );
          await PreferencesService.instance.setInt(
            'premium_purchase_time', DateTime.now().millisecondsSinceEpoch,
          );
          _purchaseController.add(PurchaseResult.success(purchase.productID));
          break;

        case PurchaseStatus.error:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          if (_isCancellationError(purchase.error)) {
            _purchaseController.add(PurchaseResult.cancelled());
          } else {
            _purchaseController.add(
              PurchaseResult.error(purchase.error?.message ?? 'Purchase failed. Please try again.'),
            );
          }
          break;

        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _purchaseController.add(PurchaseResult.cancelled());
          break;

        // Fix #10: Handle Ask to Buy / Parental Controls pending state
        case PurchaseStatus.pending:
          _purchaseController.add(PurchaseResult.pending());
          break;
      }
    }
  }

  static const _envChannel = MethodChannel('com.hanotech.justdrink/environment');

  /// Asks the native iOS layer (StoreKit 2) whether any of our subscription
  /// product IDs have an active, non-revoked entitlement right now.
  /// StoreKit 2's Transaction.currentEntitlements is the ONLY reliable
  /// client-side way to check — StoreKit 1's restorePurchases returns expired
  /// transactions with 'restored' status, making it useless for expiry detection.
  Future<bool> _hasActiveSubscription() async {
    try {
      if (!Platform.isIOS) return true; // Android — skip for now
      final result = await _envChannel.invokeMethod<bool>(
        'hasActiveSubscription',
        [productWeekly, productAnnual, productLifetime],
      );
      return result ?? false;
    } catch (e) {
      debugPrint('StoreKit 2 entitlement check failed: $e');
      // If the native call fails (e.g. iOS < 15), don't expire — be safe
      return true;
    }
  }

  Future<bool> checkExistingPremium() async {
    final isPremium = PreferencesService.instance.getBool('is_premium') ?? false;
    if (!isPremium) return false;

    final productId = PreferencesService.instance.getString('premium_product_id');
    if (productId == null) return false;

    // Lifetime never expires
    if (productId == productLifetime) {
      return true;
    }

    // Ask StoreKit 2 directly: is there a genuinely active subscription?
    final isActive = await _hasActiveSubscription();
    if (!isActive) {
      await _expirePremium();
      return false;
    }

    return true;
  }

  Future<void> _expirePremium() async {
    await PreferencesService.instance.setBool('is_premium', false);
    await PreferencesService.instance.remove('premium_product_id');
    await PreferencesService.instance.remove('premium_purchase_time');

    try {
      final userProfileDao = GetIt.I<UserProfileDao>();
      await userProfileDao.updatePremiumStatus(isPremium: false);
      
      final widgetService = GetIt.I<WidgetService>();
      final profile = await userProfileDao.getProfile();
      if (profile != null) {
        await widgetService.updateWidget(
          currentMl: 0,
          goalMl: profile.dailyGoalMl,
          isPremium: false,
        );
      }
    } catch (e) {
      debugPrint('Error updating database/widget on premium expiration: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }
}

class PurchaseResult {
  final bool success;
  final bool cancelled;
  final bool isPending;
  final String? productId;
  final String? errorMessage;

  const PurchaseResult._({
    required this.success,
    required this.cancelled,
    this.isPending = false,
    this.productId,
    this.errorMessage,
  });

  factory PurchaseResult.success(String productId) =>
      PurchaseResult._(success: true, cancelled: false, productId: productId);
  factory PurchaseResult.error(String msg) =>
      PurchaseResult._(success: false, cancelled: false, errorMessage: msg);
  factory PurchaseResult.cancelled() =>
      PurchaseResult._(success: false, cancelled: true);
  factory PurchaseResult.pending() =>
      PurchaseResult._(success: false, cancelled: false, isPending: true);
}
