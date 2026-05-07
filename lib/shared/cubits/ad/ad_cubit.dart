import 'package:flutter_bloc/flutter_bloc.dart';
import 'ad_state.dart';
import '../../../services/ad_service.dart';

class AdCubit extends Cubit<AdState> {
  final AdService adService;

  AdCubit({required this.adService}) : super(const AdState());

  void initialize(bool isPremium) {
    emit(state.copyWith(isPremium: isPremium));
    if (!isPremium) {
      adService.onBannerLoaded = () => emit(state.copyWith(isBannerLoaded: true));
      adService.onInterstitialLoaded = () => emit(state.copyWith(isInterstitialLoaded: true));
      adService.onInterstitialClosed = () => emit(state.copyWith(isInterstitialShowing: false));
      
      adService.loadBanner();
      adService.loadInterstitial();
    }
  }

  void showInterstitial() {
    if (!state.isPremium && state.isInterstitialLoaded) {
      emit(state.copyWith(isInterstitialShowing: true));
      adService.showInterstitial();
    }
  }

  void onPremiumUnlocked() {
    adService.disposeAll();
    emit(state.copyWith(isPremium: true, isBannerLoaded: false, isInterstitialLoaded: false));
  }

  @override
  Future<void> close() {
    adService.disposeAll();
    return super.close();
  }
}
