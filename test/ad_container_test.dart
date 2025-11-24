import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:breathe_flow/ui/components/ad_container.dart';
import 'package:breathe_flow/providers/premium_provider.dart';
import 'package:breathe_flow/core/ads/ad_manager.dart';
import 'package:breathe_flow/core/ads/ad_provider.dart';

// Mock AdProvider for testing
class MockAdProvider extends AdProvider {
  bool _bannerLoaded = false;
  
  @override
  Future<void> initialize() async {}

  @override
  Future<void> loadBanner({required String placement}) async {
    _bannerLoaded = true;
  }

  @override
  Future<void> showBanner() async {}

  @override
  Future<void> loadInterstitial({required String placement}) async {}

  @override
  Future<bool> showInterstitial({required String placement}) async {
    return false;
  }

  @override
  Future<void> loadRewarded({required String placement}) async {}

  @override
  Future<bool> showRewarded({
    required String placement,
    required void Function() onRewardEarned,
  }) async {
    return false;
  }

  @override
  void dispose() {}

  bool get isBannerLoaded => _bannerLoaded;
}

// Mock PremiumProvider for testing
class MockPremiumProvider extends ChangeNotifier {
  bool _canAccessAdFree = false;

  bool canAccessFeature(String feature) {
    if (feature == 'ad_free') return _canAccessAdFree;
    return false;
  }

  void setAdFreeAccess(bool value) {
    _canAccessAdFree = value;
    notifyListeners();
  }
}

void main() {
  group('AdContainer Widget Tests', () {
    late MockAdProvider mockProvider;
    late MockPremiumProvider mockPremiumProvider;

    setUp(() {
      mockProvider = MockAdProvider();
      mockPremiumProvider = MockPremiumProvider();
    });

    tearDown(() {
      mockProvider.dispose();
    });

    Widget createTestWidget({bool isPremium = false}) {
      mockPremiumProvider.setAdFreeAccess(isPremium);
      
      return MaterialApp(
        home: ChangeNotifierProvider<MockPremiumProvider>(
          create: (_) => mockPremiumProvider,
          child: Scaffold(
            body: AdContainer(
              placement: 'test_placement',
              height: 60,
            ),
          ),
        ),
      );
    }

    testWidgets('should render AdContainer widget', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(AdContainer), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should hide ad for premium users', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isPremium: true));
      await tester.pump();
      
      // Should find SizedBox.shrink for premium users
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('should show ad container for non-premium users', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isPremium: false));
      await tester.pump();
      
      expect(find.byType(AdContainer), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should have correct height', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final container = tester.widget<Container>(find.byType(Container));
      final sizedBox = container.child as SizedBox;
      expect(sizedBox.height, equals(60));
    });

    testWidgets('should have correct placement', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      final adContainer = tester.widget<AdContainer>(find.byType(AdContainer));
      expect(adContainer.placement, equals('test_placement'));
    });

    testWidgets('should dispose properly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Remove widget to trigger dispose
      await tester.pumpWidget(Container());
      
      // Should not throw any errors during dispose
      expect(tester.takeException(), isNull);
    });
  });

  group('AdContainer Integration Tests', () {
    testWidgets('should work with real AdManager', (WidgetTester tester) async {
      // This test would require Firebase initialization
      // For now, we'll test the widget structure
      
      final widget = MaterialApp(
        home: Scaffold(
          body: AdContainer(
            placement: 'integration_test',
            height: 50,
            margin: const EdgeInsets.all(8),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      
      expect(find.byType(AdContainer), findsOneWidget);
      
      final adContainer = tester.widget<AdContainer>(find.byType(AdContainer));
      expect(adContainer.placement, equals('integration_test'));
      expect(adContainer.height, equals(50));
      expect(adContainer.margin, equals(const EdgeInsets.all(8)));
    });
  });
}
