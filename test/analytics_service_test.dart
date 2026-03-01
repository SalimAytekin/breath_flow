import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:breathe_flow/core/analytics/analytics_service.dart';

// Mock sınıfları generate et
@GenerateMocks([FirebaseAnalytics])
import 'analytics_service_test.mocks.dart';

void main() {
  group('AnalyticsService Tests', () {
    late AnalyticsService analyticsService;
    late MockFirebaseAnalytics mockAnalytics;

    setUpAll(() async {
      // Firebase'i test için initialize et
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
    });

    setUp(() {
      analyticsService = AnalyticsService();
      mockAnalytics = MockFirebaseAnalytics();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockAnalytics.setAnalyticsCollectionEnabled(true))
            .thenAnswer((_) async => {});

        // Act
        await analyticsService.initialize();

        // Assert
        expect(analyticsService.isInitialized, true);
      });

      test('should handle initialization failure gracefully', () async {
        // Arrange
        when(mockAnalytics.setAnalyticsCollectionEnabled(true))
            .thenThrow(Exception('Firebase error'));

        // Act
        await analyticsService.initialize();

        // Assert
        expect(analyticsService.isInitialized, false);
      });
    });

    group('Ad Events', () {
      test('should log ad impression event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.logAdImpression(
          type: 'banner',
          placement: 'home_screen',
        );

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'ad_impression',
          parameters: {
            'type': 'banner',
            'placement': 'home_screen',
          },
        )).called(1);
      });

      test('should log ad error event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.logAdError(
          errorCode: 'LOAD_FAILED',
          placement: 'interstitial_screen',
        );

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'ad_error',
          parameters: {
            'error_code': 'LOAD_FAILED',
            'placement': 'interstitial_screen',
          },
        )).called(1);
      });
    });

    group('Exercise Events', () {
      test('should log exercise started event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.logExerciseStarted(
          exerciseId: 'breathing_4_7_8',
          from: 'home_screen',
        );

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'exercise_started',
          parameters: {
            'id': 'breathing_4_7_8',
            'from': 'home_screen',
          },
        )).called(1);
      });

      test('should log exercise completed event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.logExerciseCompleted(
          exerciseId: 'breathing_4_7_8',
          durationSeconds: 300,
        );

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'exercise_completed',
          parameters: {
            'id': 'breathing_4_7_8',
            'duration': '300',
          },
        )).called(1);
      });
    });

    group('Sound Events', () {
      test('should log sound played event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.logSoundPlayed(
          soundId: 'ocean_waves',
          durationSeconds: 180,
        );

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'sound_played',
          parameters: {
            'id': 'ocean_waves',
            'duration': '180',
          },
        )).called(1);
      });
    });

    group('Sleep Events', () {
      test('should log sleep entry added event', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.logSleepEntryAdded();

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'sleep_entry_added',
          parameters: {},
        )).called(1);
      });
    });

    group('Favorite Events', () {
      test('should log favorite toggled event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.logFavoriteToggled(
          itemId: 'breathing_4_7_8',
          type: 'exercise',
        );

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'favorite_toggled',
          parameters: {
            'id': 'breathing_4_7_8',
            'type': 'exercise',
          },
        )).called(1);
      });
    });

    group('Premium Events', () {
      test('should log premium purchase event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.logPremiumPurchase(
          plan: 'monthly_premium',
        );

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'premium_purchase',
          parameters: {
            'plan': 'monthly_premium',
          },
        )).called(1);
      });
    });

    group('Screen Events', () {
      test('should log screen view event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.logScreenView('home_screen');

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'screen_view',
          parameters: {
            'screen_name': 'home_screen',
          },
        )).called(1);
      });
    });

    group('User Management', () {
      test('should set user ID correctly', () async {
        // Arrange
        when(mockAnalytics.setUserId(id: anyNamed('id')))
            .thenAnswer((_) async => {});

        // Act
        await analyticsService.setUserId('user_123');

        // Assert
        verify(mockAnalytics.setUserId(id: 'user_123')).called(1);
      });

      test('should set user property correctly', () async {
        // Arrange
        when(mockAnalytics.setUserProperty(
          name: anyNamed('name'),
          value: anyNamed('value'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.setUserProperty('premium_status', 'true');

        // Assert
        verify(mockAnalytics.setUserProperty(
          name: 'premium_status',
          value: 'true',
        )).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle Firebase Analytics errors gracefully', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenThrow(Exception('Firebase error'));

        // Act & Assert - Should not throw
        await analyticsService.logAdImpression(
          type: 'banner',
          placement: 'home_screen',
        );
      });

      test('should skip events when not initialized', () async {
        // Arrange - Service not initialized
        analyticsService = AnalyticsService();

        // Act & Assert - Should not throw and not call Firebase
        await analyticsService.logAdImpression(
          type: 'banner',
          placement: 'home_screen',
        );

        verifyNever(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        ));
      });
    });

    group('Parameter Validation', () {
      test('should convert all parameters to strings', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act
        await analyticsService.logExerciseCompleted(
          exerciseId: 'test_exercise',
          durationSeconds: 300,
        );

        // Assert - Parameters should be strings
        verify(mockAnalytics.logEvent(
          name: 'exercise_completed',
          parameters: {
            'id': 'test_exercise',
            'duration': '300', // Should be string
          },
        )).called(1);
      });
    });
  });
}
