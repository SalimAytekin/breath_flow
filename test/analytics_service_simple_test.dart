import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:breathe_flow/core/analytics/analytics_service.dart';

// Mock sınıfları generate et
@GenerateMocks([FirebaseAnalytics])
import 'analytics_service_test.mocks.dart';

void main() {
  group('AnalyticsService Tests', () {
    late AnalyticsService analyticsService;
    late MockFirebaseAnalytics mockAnalytics;

    setUp(() {
      analyticsService = AnalyticsService();
      mockAnalytics = MockFirebaseAnalytics();
    });

    group('Event Logging', () {
      test('should log ad impression event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act - Mock analytics instance'ı set et
        analyticsService.analytics = mockAnalytics;
        analyticsService.isInitialized = true;

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

      test('should log exercise started event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act - Mock analytics instance'ı set et
        analyticsService.analytics = mockAnalytics;
        analyticsService.isInitialized = true;

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

      test('should log sleep entry added event', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act - Mock analytics instance'ı set et
        analyticsService.analytics = mockAnalytics;
        analyticsService.isInitialized = true;

        await analyticsService.logSleepEntryAdded();

        // Assert
        verify(mockAnalytics.logEvent(
          name: 'sleep_entry_added',
          parameters: {},
        )).called(1);
      });

      test('should log sound played event with correct parameters', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act - Mock analytics instance'ı set et
        analyticsService.analytics = mockAnalytics;
        analyticsService.isInitialized = true;

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

    group('Error Handling', () {
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

      test('should handle Firebase Analytics errors gracefully', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenThrow(Exception('Firebase error'));

        // Act - Mock analytics instance'ı set et
        analyticsService.analytics = mockAnalytics;
        analyticsService.isInitialized = true;

        // Act & Assert - Should not throw
        await analyticsService.logAdImpression(
          type: 'banner',
          placement: 'home_screen',
        );
      });
    });

    group('Parameter Validation', () {
      test('should convert all parameters to strings', () async {
        // Arrange
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async => {});

        // Act - Mock analytics instance'ı set et
        analyticsService.analytics = mockAnalytics;
        analyticsService.isInitialized = true;

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
