import 'package:flutter/material.dart';
import 'package:breathe_flow/core/analytics/analytics_service.dart';
import 'package:breathe_flow/core/crashlytics/crashlytics_service.dart';

/// 🧪 Test Crash ve Analytics Event'leri
/// 
/// Bu widget, Analytics ve Crashlytics entegrasyonunu test etmek için kullanılır.
/// Debug modda çalıştırıldığında test event'leri gönderir.
class TestAnalyticsCrashlyticsWidget extends StatefulWidget {
  const TestAnalyticsCrashlyticsWidget({super.key});

  @override
  State<TestAnalyticsCrashlyticsWidget> createState() => _TestAnalyticsCrashlyticsWidgetState();
}

class _TestAnalyticsCrashlyticsWidgetState extends State<TestAnalyticsCrashlyticsWidget> {
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Analytics & Crashlytics Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Analytics ve Crashlytics Entegrasyonu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Analytics Test Butonları
            const Text('📊 Analytics Tests:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testAdImpression,
              child: const Text('Test Ad Impression'),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testExerciseStarted,
              child: const Text('Test Exercise Started'),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testSleepEntryAdded,
              child: const Text('Test Sleep Entry Added'),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testSoundPlayed,
              child: const Text('Test Sound Played'),
            ),
            const SizedBox(height: 20),
            
            // Crashlytics Test Butonları
            const Text('🚨 Crashlytics Tests:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testAdError,
              child: const Text('Test Ad Error'),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testMediaError,
              child: const Text('Test Media Error'),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testNetworkError,
              child: const Text('Test Network Error'),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testExerciseError,
              child: const Text('Test Exercise Error'),
            ),
            const SizedBox(height: 20),
            
            // Test Crash Butonu
            ElevatedButton(
              onPressed: _isTesting ? null : _testCrash,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('🚨 TEST CRASH (Dikkatli!)'),
            ),
            const SizedBox(height: 20),
            
            if (_isTesting)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testAdImpression() async {
    setState(() => _isTesting = true);
    try {
      await AnalyticsService.instance.logAdImpression(
        type: 'banner',
        placement: 'test_screen',
      );
      _showSnackBar('✅ Ad Impression event gönderildi!');
    } catch (e) {
      _showSnackBar('❌ Ad Impression hatası: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _testExerciseStarted() async {
    setState(() => _isTesting = true);
    try {
      await AnalyticsService.instance.logExerciseStarted(
        exerciseId: 'test_breathing',
        from: 'test_screen',
      );
      _showSnackBar('✅ Exercise Started event gönderildi!');
    } catch (e) {
      _showSnackBar('❌ Exercise Started hatası: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _testSleepEntryAdded() async {
    setState(() => _isTesting = true);
    try {
      await AnalyticsService.instance.logSleepEntryAdded();
      _showSnackBar('✅ Sleep Entry Added event gönderildi!');
    } catch (e) {
      _showSnackBar('❌ Sleep Entry Added hatası: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _testSoundPlayed() async {
    setState(() => _isTesting = true);
    try {
      await AnalyticsService.instance.logSoundPlayed(
        soundId: 'test_ocean_waves',
        durationSeconds: 120,
      );
      _showSnackBar('✅ Sound Played event gönderildi!');
    } catch (e) {
      _showSnackBar('❌ Sound Played hatası: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _testAdError() async {
    setState(() => _isTesting = true);
    try {
      await CrashlyticsService.instance.recordAdError(
        errorType: 'load_failed',
        placement: 'test_screen',
        errorMessage: 'Test ad load failed',
        originalError: Exception('Test ad error'),
        stackTrace: StackTrace.current,
      );
      _showSnackBar('✅ Ad Error Crashlytics\'e gönderildi!');
    } catch (e) {
      _showSnackBar('❌ Ad Error hatası: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _testMediaError() async {
    setState(() => _isTesting = true);
    try {
      await CrashlyticsService.instance.recordMediaError(
        errorType: 'audio_load_failed',
        mediaId: 'test_ocean_waves',
        errorMessage: 'Test audio load failed',
        originalError: Exception('Test media error'),
        stackTrace: StackTrace.current,
      );
      _showSnackBar('✅ Media Error Crashlytics\'e gönderildi!');
    } catch (e) {
      _showSnackBar('❌ Media Error hatası: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _testNetworkError() async {
    setState(() => _isTesting = true);
    try {
      await CrashlyticsService.instance.recordNetworkError(
        errorType: 'timeout',
        endpoint: '/api/test',
        errorMessage: 'Test network timeout',
        originalError: Exception('Test network error'),
        stackTrace: StackTrace.current,
      );
      _showSnackBar('✅ Network Error Crashlytics\'e gönderildi!');
    } catch (e) {
      _showSnackBar('❌ Network Error hatası: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _testExerciseError() async {
    setState(() => _isTesting = true);
    try {
      await CrashlyticsService.instance.recordExerciseError(
        errorType: 'initialization_failed',
        exerciseId: 'test_breathing',
        errorMessage: 'Test exercise initialization failed',
        originalError: Exception('Test exercise error'),
        stackTrace: StackTrace.current,
      );
      _showSnackBar('✅ Exercise Error Crashlytics\'e gönderildi!');
    } catch (e) {
      _showSnackBar('❌ Exercise Error hatası: $e');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _testCrash() async {
    setState(() => _isTesting = true);
    
    // Kullanıcıya onay sor
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 Test Crash'),
        content: const Text(
          'Bu işlem uygulamayı çökertecek! '
          'Crashlytics dashboard\'da crash\'i görebileceksiniz. '
          'Devam etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Çökert'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CrashlyticsService.instance.testCrash();
        _showSnackBar('🚨 Test crash gönderildi!');
      } catch (e) {
        _showSnackBar('❌ Test crash hatası: $e');
      }
    }
    
    setState(() => _isTesting = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
