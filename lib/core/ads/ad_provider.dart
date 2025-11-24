abstract class AdProvider {
  Future<void> initialize();

  // Banner
  Future<void> loadBanner({required String placement});
  Future<void> showBanner();

  // Interstitial
  Future<void> loadInterstitial({required String placement});
  Future<bool> showInterstitial({required String placement});

  // Rewarded
  Future<void> loadRewarded({required String placement});
  Future<bool> showRewarded({
    required String placement,
    required void Function() onRewardEarned,
  });

  // Genel
  void dispose();
}


