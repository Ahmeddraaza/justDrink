import 'package:equatable/equatable.dart';

class AdState extends Equatable {
  final bool isPremium;
  final bool isBannerLoaded;
  final bool isInterstitialLoaded;
  final bool isInterstitialShowing;

  const AdState({
    this.isPremium = false,
    this.isBannerLoaded = false,
    this.isInterstitialLoaded = false,
    this.isInterstitialShowing = false,
  });

  AdState copyWith({
    bool? isPremium,
    bool? isBannerLoaded,
    bool? isInterstitialLoaded,
    bool? isInterstitialShowing,
  }) {
    return AdState(
      isPremium: isPremium ?? this.isPremium,
      isBannerLoaded: isBannerLoaded ?? this.isBannerLoaded,
      isInterstitialLoaded: isInterstitialLoaded ?? this.isInterstitialLoaded,
      isInterstitialShowing: isInterstitialShowing ?? this.isInterstitialShowing,
    );
  }

  @override
  List<Object?> get props => [
        isPremium,
        isBannerLoaded,
        isInterstitialLoaded,
        isInterstitialShowing,
      ];
}
