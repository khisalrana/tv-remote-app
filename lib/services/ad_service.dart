import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Test IDs - Replace with real AdMob IDs before publishing
  static String get bannerAdUnitId =>
      'ca-app-pub-3940256099942544/6300978111';

  static String get interstitialAdUnitId =>
      'ca-app-pub-3940256099942544/1033173712';

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
  }

  static InterstitialAd? _interstitialAd;

  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      loadInterstitialAd();
    }
  }
}