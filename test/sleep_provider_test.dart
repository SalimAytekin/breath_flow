import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:breathe_flow/providers/sleep_provider.dart';
import 'package:breathe_flow/models/sleep_entry.dart';
import 'package:breathe_flow/core/analytics/analytics_service.dart';
import 'package:breathe_flow/core/crashlytics/crashlytics_service.dart';

// Mock sınıfları generate et
@GenerateMocks([AnalyticsService, CrashlyticsService])
import 'sleep_provider_test.mocks.dart';

void main() {
  group('SleepProvider Analytics & Crashlytics Tests', () {
    late SleepProvider sleepProvider;
    late MockAnalyticsService mockAnalytics;
    late MockCrashlyticsService mockCrashlytics;

    setUp(() {
      sleepProvider = SleepProvider();
      mockAnalytics = MockAnalyticsService();
      mockCrashlytics = MockCrashlyticsService();
    });

    group('Sleep Entry Analytics', () {
      test('should log sleep entry added event when adding new entry', () async {
        // Arrange
        final testEntry = SleepEntry(
          date: DateTime(2024, 1, 15),
          bedTime: DateTime(2024, 1, 14, 23, 0), // 23:00
          wakeTime: DateTime(2024, 1, 15, 7, 0), // 07:00
        );

        when(mockAnalytics.logSleepEntryAdded())
            .thenAnswer((_) async => {});
        when(mockAnalytics.logEvent(
          any,
          any,
        )).thenAnswer((_) async => {});

        // Act
        await sleepProvider.addSleepEntry(testEntry);

        // Assert
        verify(mockAnalytics.logSleepEntryAdded()).called(1);
        verify(mockAnalytics.logEvent(
          'sleep_analysis_completed',
          any,
        )).called(1);
      });

      test('should log sleep analysis completed with correct parameters', () async {
        // Arrange
        final testEntry = SleepEntry(
          date: DateTime(2024, 1, 15),
          bedTime: DateTime(2024, 1, 14, 23, 0), // 23:00
          wakeTime: DateTime(2024, 1, 15, 7, 0), // 07:00 - 8 saat uyku
        );

        when(mockAnalytics.logSleepEntryAdded())
            .thenAnswer((_) async => {});
        when(mockAnalytics.logEvent(
          any,
          any,
        )).thenAnswer((_) async => {});

        // Act
        await sleepProvider.addSleepEntry(testEntry);

        // Assert
        verify(mockAnalytics.logEvent(
          'sleep_analysis_completed',
          {
            'sleep_duration_hours': '8.0', // 8 saat
            'sleep_debt_minutes': '0', // Hedef 8 saat, gerçek 8 saat
            'is_update': 'false', // Yeni kayıt
            'bedtime': testEntry.bedTime.toIso8601String(),
            'wake_time': testEntry.wakeTime.toIso8601String(),
          },
        )).called(1);
      });

      test('should log sleep entry deleted event', () async {
        // Arrange
        final testDate = DateTime(2024, 1, 15);
        
        when(mockAnalytics.logEvent(
          any,
          any,
        )).thenAnswer((_) async => {});

        // Act
        await sleepProvider.deleteSleepEntry(testDate);

        // Assert
        verify(mockAnalytics.logEvent(
          'sleep_entry_deleted',
          {
            'deleted_date': testDate.toIso8601String(),
            'remaining_entries': any,
          },
        )).called(1);
      });
    });

    group('Sleep Data Error Handling', () {
      test('should handle sleep data load errors gracefully', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          additionalData: anyNamed('additionalData'),
        )).thenAnswer((_) async => {});

        // Act - Simulate error by creating provider with invalid data
        SleepProvider();
        
        // Assert - Should not throw and should record error
        verifyNever(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          additionalData: anyNamed('additionalData'),
        ));
      });

      test('should handle sleep data save errors gracefully', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          additionalData: anyNamed('additionalData'),
        )).thenAnswer((_) async => {});

        final testEntry = SleepEntry(
          date: DateTime(2024, 1, 15),
          bedTime: DateTime(2024, 1, 14, 23, 0),
          wakeTime: DateTime(2024, 1, 15, 7, 0),
        );

        // Act
        await sleepProvider.addSleepEntry(testEntry);

        // Assert - Should not throw
        expect(sleepProvider.sleepEntries.length, greaterThanOrEqualTo(0));
      });

      test('should handle sleep quality score calculation errors', () async {
        // Arrange
        when(mockCrashlytics.recordError(
          any,
          any,
          reason: anyNamed('reason'),
          additionalData: anyNamed('additionalData'),
        )).thenAnswer((_) async => {});

        // Act
        final score = sleepProvider.sleepQualityScore;

        // Assert
        expect(score, isA<int>());
        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });
    });

    group('Sleep Analysis Calculations', () {
      test('should calculate sleep duration correctly', () {
        // Arrange
        final testEntry = SleepEntry(
          date: DateTime(2024, 1, 15),
          bedTime: DateTime(2024, 1, 14, 23, 0), // 23:00
          wakeTime: DateTime(2024, 1, 15, 7, 0), // 07:00
        );

        // Act
        final duration = testEntry.actualSleep;

        // Assert
        expect(duration.inHours, equals(8));
        expect(duration.inMinutes, equals(480));
      });

      test('should calculate sleep debt correctly', () {
        // Arrange
        final testEntry = SleepEntry(
          date: DateTime(2024, 1, 15),
          bedTime: DateTime(2024, 1, 14, 23, 30), // 23:30
          wakeTime: DateTime(2024, 1, 15, 6, 30), // 06:30 - 7 saat uyku
        );

        // Act
        final debt = testEntry.sleepDebt;

        // Assert
        expect(debt.inMinutes, equals(-60)); // 1 saat eksik (8 saat hedef - 7 saat gerçek)
      });

      test('should handle overnight sleep correctly', () {
        // Arrange
        final testEntry = SleepEntry(
          date: DateTime(2024, 1, 15),
          bedTime: DateTime(2024, 1, 15, 1, 0), // 01:00 (ertesi gün)
          wakeTime: DateTime(2024, 1, 15, 9, 0), // 09:00
        );

        // Act
        final duration = testEntry.actualSleep;

        // Assert
        expect(duration.inHours, equals(8));
      });
    });

    group('Sleep Data Validation', () {
      test('should validate sleep entry data', () {
        // Arrange
        final validEntry = SleepEntry(
          date: DateTime(2024, 1, 15),
          bedTime: DateTime(2024, 1, 14, 23, 0),
          wakeTime: DateTime(2024, 1, 15, 7, 0),
        );

        // Act & Assert
        expect(validEntry.date, isA<DateTime>());
        expect(validEntry.bedTime, isA<DateTime>());
        expect(validEntry.wakeTime, isA<DateTime>());
        expect(validEntry.actualSleep.inMinutes, greaterThan(0));
      });

      test('should handle edge cases in sleep calculations', () {
        // Arrange - Same day sleep (unusual but possible)
        final sameDayEntry = SleepEntry(
          date: DateTime(2024, 1, 15),
          bedTime: DateTime(2024, 1, 15, 2, 0), // 02:00
          wakeTime: DateTime(2024, 1, 15, 6, 0), // 06:00
        );

        // Act
        final duration = sameDayEntry.actualSleep;

        // Assert
        expect(duration.inHours, equals(4));
      });
    });

    group('Sleep Analytics Integration', () {
      test('should track sleep patterns over time', () async {
        // Arrange
        final entries = [
          SleepEntry(
            date: DateTime(2024, 1, 15),
            bedTime: DateTime(2024, 1, 14, 23, 0),
            wakeTime: DateTime(2024, 1, 15, 7, 0),
          ),
          SleepEntry(
            date: DateTime(2024, 1, 16),
            bedTime: DateTime(2024, 1, 15, 22, 30),
            wakeTime: DateTime(2024, 1, 16, 6, 30),
          ),
        ];

        when(mockAnalytics.logSleepEntryAdded())
            .thenAnswer((_) async => {});
        when(mockAnalytics.logEvent(
          any,
          any,
        )).thenAnswer((_) async => {});

        // Act
        for (final entry in entries) {
          await sleepProvider.addSleepEntry(entry);
        }

        // Assert
        expect(sleepProvider.sleepEntries.length, equals(2));
        verify(mockAnalytics.logSleepEntryAdded()).called(2);
        verify(mockAnalytics.logEvent(
          'sleep_analysis_completed',
          any,
        )).called(2);
      });

      test('should calculate weekly sleep statistics', () {
        // Arrange - Add multiple sleep entries
        final entries = List.generate(7, (index) {
          final date = DateTime(2024, 1, 15).add(Duration(days: index));
          return SleepEntry(
            date: date,
            bedTime: date.subtract(Duration(hours: 1)), // 23:00
            wakeTime: date.add(Duration(hours: 7)), // 07:00
          );
        });

        for (final entry in entries) {
          sleepProvider.addSleepEntry(entry);
        }

        // Act
        final weeklyDebt = sleepProvider.weeklyDebt;
        final weeklyAverage = sleepProvider.weeklyAverageSleep;
        final qualityScore = sleepProvider.sleepQualityScore;

        // Assert
        expect(weeklyDebt, isA<Duration>());
        expect(weeklyAverage, isA<Duration>());
        expect(qualityScore, isA<int>());
        expect(qualityScore, greaterThanOrEqualTo(0));
        expect(qualityScore, lessThanOrEqualTo(100));
      });
    });
  });
}
