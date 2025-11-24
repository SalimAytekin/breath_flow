import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:breathe_flow/core/crashlytics/crashlytics_service.dart';

// Mock sınıfları generate et
@GenerateMocks([FirebaseCrashlytics])
import 'crashlytics_service_test.mocks.dart';

void main() {
  group('CrashlyticsService Tests', () {
    late CrashlyticsService crashlyticsService;
    late MockFirebaseCrashlytics mockCrashlytics;

    setUp(() {
      crashlyticsService = CrashlyticsService();
      mockCrashlytics = MockFirebaseCrashlytics();
    });

    group('Error Recording', () {
      test('should record error with correct parameters', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        )).thenAnswer((_) async => {});

        final exception = Exception('Test error');
        final stackTrace = StackTrace.current;

        // Act - Mock crashlytics instance'ı set et
        crashlyticsService.crashlytics = mockCrashlytics;
        crashlyticsService.isInitialized = true;

        await crashlyticsService.recordError(
          exception,
          stackTrace,
          reason: 'Test reason',
          fatal: true,
          additionalData: {'key': 'value'},
        );

        // Assert
        verify(mockCrashlytics.recordError(
          exception,
          stackTrace,
          reason: 'Test reason',
          fatal: true,
          information: anyNamed('information'),
        )).called(1);
      });

      test('should record ad error with correct parameters', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        )).thenAnswer((_) async => {});

        final exception = Exception('Ad load failed');
        final stackTrace = StackTrace.current;

        // Act - Mock crashlytics instance'ı set et
        crashlyticsService.crashlytics = mockCrashlytics;
        crashlyticsService.isInitialized = true;

        await crashlyticsService.recordAdError(
          errorType: 'load_failed',
          placement: 'home_screen',
          errorMessage: 'Ad load failed',
          originalError: exception,
          stackTrace: stackTrace,
        );

        // Assert
        verify(mockCrashlytics.recordError(
          exception,
          stackTrace,
          reason: 'AdManager Error',
          fatal: false,
          information: anyNamed('information'),
        )).called(1);
      });

      test('should record media error with correct parameters', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        )).thenAnswer((_) async => {});

        final exception = Exception('Audio load failed');
        final stackTrace = StackTrace.current;

        // Act - Mock crashlytics instance'ı set et
        crashlyticsService.crashlytics = mockCrashlytics;
        crashlyticsService.isInitialized = true;

        await crashlyticsService.recordMediaError(
          errorType: 'audio_load_failed',
          mediaId: 'ocean_waves',
          errorMessage: 'Audio load failed',
          originalError: exception,
          stackTrace: stackTrace,
        );

        // Assert
        verify(mockCrashlytics.recordError(
          exception,
          stackTrace,
          reason: 'MediaPlayer Error',
          fatal: false,
          information: anyNamed('information'),
        )).called(1);
      });
    });

    group('User Management', () {
      test('should set user ID correctly', () async {
        // Arrange
        when(mockCrashlytics.setUserIdentifier(any))
            .thenAnswer((_) async => {});

        // Act - Mock crashlytics instance'ı set et
        crashlyticsService.crashlytics = mockCrashlytics;
        crashlyticsService.isInitialized = true;

        await crashlyticsService.setUserId('user_123');

        // Assert
        verify(mockCrashlytics.setUserIdentifier('user_123')).called(1);
      });

      test('should set custom key correctly', () async {
        // Arrange
        when(mockCrashlytics.setCustomKey(any, any))
            .thenAnswer((_) async => {});

        // Act - Mock crashlytics instance'ı set et
        crashlyticsService.crashlytics = mockCrashlytics;
        crashlyticsService.isInitialized = true;

        await crashlyticsService.setCustomKey('premium_status', 'true');

        // Assert
        verify(mockCrashlytics.setCustomKey('premium_status', 'true')).called(1);
      });
    });

    group('Error Handling', () {
      test('should skip operations when not initialized', () async {
        // Arrange - Service not initialized
        crashlyticsService = CrashlyticsService();

        // Act & Assert - Should not throw and not call Firebase
        await crashlyticsService.recordError(
          Exception('Test error'),
          StackTrace.current,
        );

        verifyNever(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        ));
      });

      test('should handle Firebase Crashlytics errors gracefully', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        )).thenThrow(Exception('Firebase error'));

        // Act - Mock crashlytics instance'ı set et
        crashlyticsService.crashlytics = mockCrashlytics;
        crashlyticsService.isInitialized = true;

        // Act & Assert - Should not throw
        await crashlyticsService.recordError(
          Exception('Test error'),
          StackTrace.current,
        );
      });
    });
  });
}
