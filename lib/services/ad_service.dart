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