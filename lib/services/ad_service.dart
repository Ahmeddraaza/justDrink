import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/app_constants.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  int _retryAttempt = 0;
  static const _maxRetries = 3;

  // Callbacks
  Function()? onInterstitialLoaded;
  Function()? onInterstitialClosed;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('[AdService] MobileAds SDK initialized');
  }

  // ── Interstitial Ad ───────────────────────────────────────────────
  void loadInterstitial() {
    debugPrint('[AdService] Loading interstitial ad (attempt ${_retryAttempt + 1})...');
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] ✅ Interstitial loaded successfully');
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          _retryAttempt = 0; // reset on success
          onInterstitialLoaded?.call();

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('[AdService] Interstitial shown');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('[AdService] Interstitial dismissed — preloading next');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              onInterstitialClosed?.call();
              loadInterstitial(); // preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('[AdService] ❌ Interstitial failed to SHOW: ${error.message}');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialLoaded = false;
              loadInterstitial(); // try loading a fresh one
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] ❌ Interstitial failed to LOAD: ${error.message} (code: ${error.code})');
          _isInterstitialLoaded = false;
          _interstitialAd = null;

          // Retry with exponential backoff (10s, 20s, 40s) up to 3 times
          if (_retryAttempt < _maxRetries) {
            _retryAttempt++;
            final delay = Duration(seconds: 10 * _retryAttempt);
            debugPrint('[AdService] Retrying in ${delay.inSeconds}s (attempt $_retryAttempt/$_maxRetries)');
            Timer(delay, loadInterstitial);
          } else {
            debugPrint('[AdService] Max retries reached — will try again next session');
          }
        },
      ),
    );
  }

  bool get isInterstitialReady => _isInterstitialLoaded;

  Future<void> showInterstitial() async {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      debugPrint('[AdService] Showing interstitial...');
      await _interstitialAd!.show();
    } else {
      debugPrint('[AdService] Interstitial not ready — skipping show');
      // Try to load one for next time
      if (!_isInterstitialLoaded) {
        _retryAttempt = 0;
        loadInterstitial();
      }
    }
  }

  void disposeAll() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
  }
}
