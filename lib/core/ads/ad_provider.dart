import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class AdProvider {
  Future<void> initialize();

  // Banner
  Future<void> loadBanner({required String placement, AdSize? size});
  Future<void> showBanner();

  // Interstitial
  Future<void> loadInterstitial({required String placement});
  Future<bool> showInterstitial({required String placement});
  bool get isInterstitialLoaded;

  // Rewarded
  Future<void> loadRewarded({required String placement});
  Future<bool> showRewarded({
    required String placement,
    required void Function() onRewardEarned,
  });

  // Genel
  void dispose();
}


