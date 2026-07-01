import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Real AdMob IDs
  static const String bannerAdUnitId = 'ca-app-pub-9576636767696975/5296616757';
  static const String interstitialAdUnitId = 'ca-app-pub-9576636767696975/6972660509';

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Banner Ad
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
  }

  // Interstitial Ad
  static InterstitialAd? _interstitialAd;

  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Shows an interstitial ONLY at a natural transition point (e.g. leaving
  /// the remote screen) — never during live button presses, per AdMob's own
  /// guidance for utility-style apps. [onComplete] always fires exactly once:
  /// immediately if no ad is ready, or right after the ad is closed/fails to
  /// show, so navigation is never blocked or duplicated.
  static void showInterstitialOnTransition(VoidCallback onComplete) {
    final ad = _interstitialAd;
    if (ad == null) {
      onComplete();
      return;
    }
    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        loadInterstitialAd();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        a.dispose();
        loadInterstitialAd();
        onComplete();
      },
    );
    ad.show();
  }
}
