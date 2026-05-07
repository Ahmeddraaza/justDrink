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
    emit(state.copyWith(isLoading: true));
    final products = await purchaseService.initialize();
    
    _purchaseSubscription = purchaseService.purchaseResultStream.listen((result) async {
      if (result.success) {
        await userProfileDao.updatePremiumStatus(isPremium: true, productId: result.productId);
        adCubit.onPremiumUnlocked();
        emit(state.copyWith(isPurchasing: false, purchaseSuccess: true));
      } else if (result.cancelled) {
        emit(state.copyWith(isPurchasing: false));
      } else {
        emit(state.copyWith(isPurchasing: false, errorMessage: result.errorMessage));
      }
    });

    emit(state.copyWith(products: products, isLoading: false));
  }

  Future<void> buyProduct(ProductDetails product) async {
    emit(state.copyWith(isPurchasing: true, errorMessage: null));
    await purchaseService.purchase(product);
  }

  Future<void> restore() async {
    emit(state.copyWith(isPurchasing: true, errorMessage: null));
    await purchaseService.restorePurchases();
  }

  @override
  Future<void> close() {
    _purchaseSubscription?.cancel();
    return super.close();
  }
}
