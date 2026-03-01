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

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockCrashlytics.setCrashlyticsCollectionEnabled(true))
            .thenAnswer((_) async => {});

        // Act
        await crashlyticsService.initialize();

        // Assert
        expect(crashlyticsService.isInitialized, true);
      });

      test('should handle initialization failure gracefully', () async {
        // Arrange
        when(mockCrashlytics.setCrashlyticsCollectionEnabled(true))
            .thenThrow(Exception('Firebase error'));

        // Act
        await crashlyticsService.initialize();

        // Assert
        expect(crashlyticsService.isInitialized, false);
      });
    });

    group('General Error Recording', () {
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

        // Act
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

      test('should handle Firebase Crashlytics errors gracefully', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        )).thenThrow(Exception('Firebase error'));

        // Act & Assert - Should not throw
        await crashlyticsService.recordError(
          Exception('Test error'),
          StackTrace.current,
        );
      });
    });

    group('Ad Error Recording', () {
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

        // Act
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

      test('should create exception when original error is null', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        )).thenAnswer((_) async => {});

        // Act
        await crashlyticsService.recordAdError(
          errorType: 'show_failed',
          placement: 'interstitial_screen',
          errorMessage: 'Ad show failed',
          originalError: null,
          stackTrace: null,
        );

        // Assert
        verify(mockCrashlytics.recordError(
          any,
          any,
          reason: 'AdManager Error',
          fatal: false,
          information: anyNamed('information'),
        )).called(1);
      });
    });

    group('Media Error Recording', () {
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

        // Act
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

    group('Network Error Recording', () {
      test('should record network error with correct parameters', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        )).thenAnswer((_) async => {});

        final exception = Exception('Network timeout');
        final stackTrace = StackTrace.current;

        // Act
        await crashlyticsService.recordNetworkError(
          errorType: 'timeout',
          endpoint: '/api/user',
          errorMessage: 'Network timeout',
          originalError: exception,
          stackTrace: stackTrace,
        );

        // Assert
        verify(mockCrashlytics.recordError(
          exception,
          stackTrace,
          reason: 'Network Error',
          fatal: false,
          information: anyNamed('information'),
        )).called(1);
      });
    });

    group('Exercise Error Recording', () {
      test('should record exercise error with correct parameters', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        )).thenAnswer((_) async => {});

        final exception = Exception('Exercise initialization failed');
        final stackTrace = StackTrace.current;

        // Act
        await crashlyticsService.recordExerciseError(
          errorType: 'initialization_failed',
          exerciseId: 'breathing_4_7_8',
          errorMessage: 'Exercise initialization failed',
          originalError: exception,
          stackTrace: stackTrace,
        );

        // Assert
        verify(mockCrashlytics.recordError(
          exception,
          stackTrace,
          reason: 'Exercise Error',
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

        // Act
        await crashlyticsService.setUserId('user_123');

        // Assert
        verify(mockCrashlytics.setUserIdentifier('user_123')).called(1);
      });

      test('should set custom key correctly', () async {
        // Arrange
        when(mockCrashlytics.setCustomKey(any, any))
            .thenAnswer((_) async => {});

        // Act
        await crashlyticsService.setCustomKey('premium_status', 'true');

        // Assert
        verify(mockCrashlytics.setCustomKey('premium_status', 'true')).called(1);
      });
    });

    group('Logging', () {
      test('should log message correctly', () async {
        // Arrange
        when(mockCrashlytics.log(any))
            .thenAnswer((_) async => {});

        // Act
        await crashlyticsService.log('Test log message');

        // Assert
        verify(mockCrashlytics.log('Test log message')).called(1);
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

      test('should handle Firebase Crashlytics errors in user management', () async {
        // Arrange
        when(mockCrashlytics.setUserIdentifier(any))
            .thenThrow(Exception('Firebase error'));

        // Act & Assert - Should not throw
        await crashlyticsService.setUserId('user_123');
      });

      test('should handle Firebase Crashlytics errors in logging', () async {
        // Arrange
        when(mockCrashlytics.log(any))
            .thenThrow(Exception('Firebase error'));

        // Act & Assert - Should not throw
        await crashlyticsService.log('Test message');
      });
    });

    group('Parameter Conversion', () {
      test('should convert additional data to strings', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        )).thenAnswer((_) async => {});

        // Act
        await crashlyticsService.recordError(
          Exception('Test error'),
          StackTrace.current,
          additionalData: {
            'int_value': 123,
            'bool_value': true,
            'string_value': 'test',
          },
        );

        // Assert - Parameters should be converted to strings
        verify(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          fatal: anyNamed('fatal'),
          information: anyNamed('information'),
        )).called(1);
      });
    });
  });
}
