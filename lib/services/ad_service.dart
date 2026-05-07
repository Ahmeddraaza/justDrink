import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/app_constants.dart';

class AdService {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;

  // Callbacks
  Function()? onBannerLoaded;
  Function()? onInterstitialLoaded;
  Function()? onInterstitialClosed;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ── Banner Ad ─────────────────────────────────────────────────────
  void loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerLoaded = true;
          onBannerLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerLoaded = false;
        },
      ),
    )..load();
  }

  BannerAd? get bannerAd => _isBannerLoaded ? _bannerAd : null;

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  // ── Interstitial Ad ───────────────────────────────────────────────
  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          onInterstitialLoaded?.call();
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              onInterstitialClosed?.call();
              loadInterstitial(); // preload next
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  bool get isInterstitialReady => _isInterstitialLoaded;

  Future<void> showInterstitial() async {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
    }
  }

  void disposeInterstitial() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
  }

  void disposeAll() {
    disposeBanner();
    disposeInterstitial();
  }
}
