import 'package:flutter_test/flutter_test.dart';
import 'package:breathe_flow/core/ads/ad_manager.dart';
import 'package:breathe_flow/core/ads/ad_provider.dart';
import 'package:breathe_flow/core/ads/admob_provider.dart';

// Mock AdProvider for testing
class MockAdProvider implements AdProvider {
  bool _initialized = false;
  bool _bannerLoaded = false;
  bool _interstitialLoaded = false;
  bool _rewardedLoaded = false;
  
  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> loadBanner({required String placement}) async {
    _bannerLoaded = true;
  }

  @override
  Future<void> showBanner() async {
    // Mock implementation
  }

  @override
  Future<void> loadInterstitial({required String placement}) async {
    _interstitialLoaded = true;
  }

  @override
  Future<bool> showInterstitial({required String placement}) async {
    return _interstitialLoaded;
  }

  @override
  Future<void> loadRewarded({required String placement}) async {
    _rewardedLoaded = true;
  }

  @override
  Future<bool> showRewarded({
    required String placement,
    required void Function() onRewardEarned,
  }) async {
    if (_rewardedLoaded) {
      onRewardEarned();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _initialized = false;
    _bannerLoaded = false;
    _interstitialLoaded = false;
    _rewardedLoaded = false;
  }

  // Getters for testing
  bool get isInitialized => _initialized;
  bool get isBannerLoaded => _bannerLoaded;
  bool get isInterstitialLoaded => _interstitialLoaded;
  bool get isRewardedLoaded => _rewardedLoaded;
}

void main() {
  group('AdManager Tests', () {
    late AdManager adManager;
    late MockAdProvider mockProvider;

    setUp(() {
      adManager = AdManager.instance;
      mockProvider = MockAdProvider();
    });

    tearDown(() {
      adManager.dispose();
    });

    test('should be singleton', () {
      final instance1 = AdManager.instance;
      final instance2 = AdManager.instance;
      expect(instance1, equals(instance2));
    });

    test('should initialize with provider', () async {
      await adManager.initialize(provider: mockProvider);
      expect(mockProvider.isInitialized, isTrue);
    });

    test('should not show banner for premium users', () async {
      await adManager.initialize(provider: mockProvider);
      adManager.updatePremium(true);
      
      await adManager.showBanner(placement: 'test');
      
      // Banner should not be loaded for premium users
      expect(mockProvider.isBannerLoaded, isFalse);
    });

    test('should show banner for non-premium users', () async {
      await adManager.initialize(provider: mockProvider);
      adManager.updatePremium(false);
      
      await adManager.showBanner(placement: 'test');
      
      // Banner should be loaded for non-premium users
      expect(mockProvider.isBannerLoaded, isTrue);
    });

    test('should respect interstitial rate limit', () async {
      await adManager.initialize(provider: mockProvider);
      adManager.updatePremium(false);
      
      // First interstitial should work
      final firstResult = await adManager.showInterstitial(placement: 'test');
      expect(firstResult, isTrue);
      
      // Second interstitial immediately should fail due to rate limit
      final secondResult = await adManager.showInterstitial(placement: 'test');
      expect(secondResult, isFalse);
    });

    test('should not show interstitial for premium users', () async {
      await adManager.initialize(provider: mockProvider);
      adManager.updatePremium(true);
      
      final result = await adManager.showInterstitial(placement: 'test');
      expect(result, isFalse);
    });

    test('should show rewarded ad and call reward callback', () async {
      await adManager.initialize(provider: mockProvider);
      adManager.updatePremium(false);
      
      bool rewardEarned = false;
      final result = await adManager.showRewarded(
        placement: 'test',
        onRewardEarned: () => rewardEarned = true,
      );
      
      expect(result, isTrue);
      expect(rewardEarned, isTrue);
    });

    test('should not show rewarded for premium users', () async {
      await adManager.initialize(provider: mockProvider);
      adManager.updatePremium(true);
      
      bool rewardEarned = false;
      final result = await adManager.showRewarded(
        placement: 'test',
        onRewardEarned: () => rewardEarned = true,
      );
      
      expect(result, isFalse);
      expect(rewardEarned, isFalse);
    });

    test('should get banner refresh seconds', () {
      final seconds = adManager.getBannerRefreshSeconds();
      expect(seconds, greaterThanOrEqualTo(30));
      expect(seconds, lessThanOrEqualTo(45));
    });
  });

  group('AdMobProvider Tests', () {
    late AdMobProvider provider;

    setUp(() {
      provider = AdMobProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('should initialize without errors', () async {
      expect(() => provider.initialize(), returnsNormally);
    });

    test('should load banner for placement', () async {
      await provider.loadBanner(placement: 'test_placement');
      // In real implementation, this would set up the BannerAd
      // For testing, we just verify no exceptions are thrown
      expect(() => provider.loadBanner(placement: 'test'), returnsNormally);
    });

    test('should load interstitial for placement', () async {
      await provider.loadInterstitial(placement: 'test_placement');
      // In real implementation, this would set up the InterstitialAd
      expect(() => provider.loadInterstitial(placement: 'test'), returnsNormally);
    });

    test('should load rewarded for placement', () async {
      await provider.loadRewarded(placement: 'test_placement');
      // In real implementation, this would set up the RewardedAd
      expect(() => provider.loadRewarded(placement: 'test'), returnsNormally);
    });

    test('should dispose without errors', () {
      expect(() => provider.dispose(), returnsNormally);
    });
  });
}
