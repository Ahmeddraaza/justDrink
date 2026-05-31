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

    // Cancel old listener to prevent duplicate events
    _purchaseSubscription?.cancel();
    _purchaseSubscription = purchaseService.purchaseResultStream.listen((result) async {
      if (result.success) {
        await userProfileDao.updatePremiumStatus(isPremium: true, productId: result.productId);
        adCubit.onPremiumUnlocked();
        // Navigate away — no SnackBar needed (navigation IS the success signal)
        emit(state.copyWith(
          isPurchasing: false,
          purchaseSuccess: true,
          feedbackMessage: null,  // clear any stale message
          errorMessage: null,
        ));
      } else if (result.cancelled) {
        emit(state.copyWith(
          isPurchasing: false,
          feedbackMessage: 'Purchase cancelled.',
          errorMessage: null,
        ));
      } else if (result.isPending) {
        // StoreKit emits .pending before showing the payment sheet in Sandbox.
        // Do NOT reset isPurchasing here — keep the spinner going silently.
        // Do NOT show any toast — it's not a real Ask-to-Buy pending state.
        // The payment sheet will appear momentarily on its own.
        return;
      } else {
        emit(state.copyWith(
          isPurchasing: false,
          errorMessage: result.errorMessage,
          feedbackMessage: null,
        ));
      }
    });

    emit(state.copyWith(products: products, isLoading: false));
  }

  /// Clears one-time feedback/error messages after the UI has consumed them.
  /// Call this from the BlocListener after showing a SnackBar.
  void clearMessages() {
    emit(state.copyWith(
      errorMessage: null,
      feedbackMessage: null,
    ));
  }

  Future<void> buyProduct(ProductDetails product) async {
    // Fully clear stale messages — sentinel pattern in copyWith ensures null actually clears
    emit(state.copyWith(
      isPurchasing: true,
      errorMessage: null,
      feedbackMessage: null,
    ));
    try {
      await purchaseService.purchase(product);
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('cancel') || errStr.contains('skerror') || errStr.contains('code 2')) {
        emit(state.copyWith(
          isPurchasing: false,
          feedbackMessage: 'Purchase cancelled.',
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          isPurchasing: false,
          errorMessage: 'Purchase failed. Please try again.',
          feedbackMessage: null,
        ));
      }
    }
  }

  Future<void> restore() async {
    emit(state.copyWith(isPurchasing: true, errorMessage: null, feedbackMessage: null));

    bool restoredAtLeastOne = false;
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
      // Wait up to 4 seconds for a restore callback to arrive
      await completer.future.timeout(const Duration(seconds: 4), onTimeout: () {});
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('cancel') || errorStr.contains('skerror') || errorStr.contains('code 2')) {
        emit(state.copyWith(
          isPurchasing: false,
          feedbackMessage: 'Restore cancelled.',
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          isPurchasing: false,
          errorMessage: 'Restore failed. Please try again.',
          feedbackMessage: null,
        ));
      }
      await sub.cancel();
      return;
    }

    await sub.cancel();

    if (!restoredAtLeastOne) {
      emit(state.copyWith(
        isPurchasing: false,
        feedbackMessage: 'No active purchases found to restore.',
        errorMessage: null,
      ));
    }
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    return super.close();
  }
}
