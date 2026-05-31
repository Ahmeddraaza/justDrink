import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'purchase_state.dart';
import '../../../services/purchase_service.dart';
import '../../../shared/cubits/ad/ad_cubit.dart';
import '../../../data/database/daos/user_profile_dao.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  final PurchaseService purchaseService;
  final AdCubit adCubit;
  final UserProfileDao userProfileDao;

  StreamSubscription? _purchaseSubscription;

  PurchaseCubit({
    required this.purchaseService,
    required this.adCubit,
    required this.userProfileDao,
  }) : super(const PurchaseState());

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true, errorMessage: null, feedbackMessage: null));
    final products = await purchaseService.initialize();

    // Cancel old listener if any to prevent duplicate events
    _purchaseSubscription?.cancel();
    _purchaseSubscription = purchaseService.purchaseResultStream.listen((result) async {
      if (result.success) {
        await userProfileDao.updatePremiumStatus(isPremium: true, productId: result.productId);
        adCubit.onPremiumUnlocked();
        // Fix #8: Only emit purchaseSuccess — don't also set feedbackMessage to avoid double SnackBar
        emit(state.copyWith(
          isPurchasing: false,
          purchaseSuccess: true,
        ));
      } else if (result.cancelled) {
        emit(state.copyWith(
          isPurchasing: false,
          feedbackMessage: 'Purchase cancelled.',
        ));
      } else if (result.isPending) {
        // Fix #10: Handle Ask to Buy (parental controls) pending state
        emit(state.copyWith(
          isPurchasing: false,
          feedbackMessage: 'Purchase is pending approval.',
        ));
      } else {
        emit(state.copyWith(
          isPurchasing: false,
          errorMessage: result.errorMessage,
        ));
      }
    });

    emit(state.copyWith(products: products, isLoading: false));
  }

  // Fix #3: Wrap purchase in try/catch so spinner never gets permanently stuck
  Future<void> buyProduct(ProductDetails product) async {
    emit(state.copyWith(isPurchasing: true, errorMessage: null, feedbackMessage: null));
    try {
      await purchaseService.purchase(product);
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      // Silently dismiss cancellation exceptions thrown by StoreKit
      if (errStr.contains('cancel') || errStr.contains('skerror') || errStr.contains('code 2')) {
        emit(state.copyWith(
          isPurchasing: false,
          feedbackMessage: 'Purchase cancelled.',
        ));
      } else {
        emit(state.copyWith(
          isPurchasing: false,
          errorMessage: 'Purchase failed. Please try again.',
        ));
      }
    }
  }

  // Fix #4: Use a local completer flag to avoid race condition on restore check
  Future<void> restore() async {
    emit(state.copyWith(isPurchasing: true, errorMessage: null, feedbackMessage: null));

    bool restoredAtLeastOne = false;

    // Temporarily listen to the stream to detect if a restore comes through
    final completer = Completer<void>();
    late StreamSubscription sub;

    sub = purchaseService.purchaseResultStream.listen((result) {
      if (result.success) {
        restoredAtLeastOne = true;
        if (!completer.isCompleted) completer.complete();
      }
    });

    try {
      await purchaseService.restorePurchases();
      // Wait up to 4 seconds for any restore callback to arrive
      await completer.future.timeout(const Duration(seconds: 4), onTimeout: () {});
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('cancelled') || errorStr.contains('cancel') ||
          errorStr.contains('skerror') || errorStr.contains('code 2')) {
        emit(state.copyWith(
          isPurchasing: false,
          feedbackMessage: 'Restore cancelled.',
        ));
        await sub.cancel();
        return;
      } else {
        emit(state.copyWith(
          isPurchasing: false,
          errorMessage: 'Restore failed. Please try again.',
        ));
        await sub.cancel();
        return;
      }
    }

    await sub.cancel();

    if (!restoredAtLeastOne) {
      emit(state.copyWith(
        isPurchasing: false,
        feedbackMessage: 'No active purchases found to restore.',
      ));
    }
    // If restored, the stream listener above already emitted purchaseSuccess via the main subscription
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    return super.close();
  }
}
