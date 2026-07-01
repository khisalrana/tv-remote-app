import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Test IDs - Replace with real AdMob IDs before publishing to Play Store
  static const String _bannerTestId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialTestId = 'ca-app-pub-3940256099942544/1033173712';

  // TODO: Replace these with your real AdMob IDs
  static const String bannerAdUnitId = _bannerTestId;
  static const String interstitialAdUnitId = _interstitialTestId;

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
  static int _buttonPressCount = 0;

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

  // Show interstitial every 20 button presses
  static void trackButtonPress() {
    _buttonPressCount++;
    if (_buttonPressCount % 20 == 0) {
      showInterstitialAd();
    }
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      loadInterstitialAd();
    }
  }
}
