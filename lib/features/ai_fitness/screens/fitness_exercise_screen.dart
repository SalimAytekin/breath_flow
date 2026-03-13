import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../constants/app_colors.dart';
import '../models/landmark_point.dart';
import '../models/exercise_phase.dart';
import '../models/exercise_config.dart';
import '../models/rep_result.dart';
import '../models/exercise_phase.dart'; // SessionResult için gerekebilir
import '../services/native_pose_bridge.dart';
import '../services/feedback_engine.dart';
import 'fitness_session_summary.dart';

/// AI Fitness Egzersiz Ekranı — MLKit Native Activity.
///
/// Kamera, poz algılama ve iskelet çizimi tamamen native tarafta çalışır.
/// Bu ekran sadece native Activity'yi başlatır ve bekleme/loading gösterir.
/// Sonuçlar native Activity kapandığında EventChannel ile gelir.
class FitnessExerciseScreen extends StatefulWidget {
  final ExerciseConfig exerciseConfig;

  const FitnessExerciseScreen({
    super.key,
    required this.exerciseConfig,
  });

  @override
  State<FitnessExerciseScreen> createState() => _FitnessExerciseScreenState();
}

class _FitnessExerciseScreenState extends State<FitnessExerciseScreen>
    with WidgetsBindingObserver {

  bool _hasPermission = false;
  bool _isLaunching = true;
  String _errorMessage = '';
  Timer? _uiRefreshTimer;
  final Stopwatch _elapsedStopwatch = Stopwatch();

  late NativePoseBridge _poseBridge;
  late FeedbackEngine _feedbackEngine;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _feedbackEngine = FeedbackEngine();
    _feedbackEngine.initialize();

    _poseBridge = NativePoseBridge(
      onError: (e) {
        if (kDebugMode) debugPrint('⚠️ MLKit error: $e');
      },
      onRepetition: (count) {
        _feedbackEngine.onRepCompleted(
          repCount: count,
          targetReps: widget.exerciseConfig.targetReps,
        );
        // Milestone kontrolleri
        if (count % 5 == 0 && count > 0) {
          _feedbackEngine.onMilestone(count);
        }
      },
      onFeedback: (message) {
        _feedbackEngine.onBadForm(warningMessage: message);
      },
      onExerciseStarted: () {
        _feedbackEngine.onExerciseStart(widget.exerciseConfig.displayName);
        _elapsedStopwatch.start();
      },
      onAccuracy: (value) {
        // UI accuracy güncellemeleri zaten _poseBridge.accuracy üzerinden yapılıyor
      },
    );

    _requestPermissionAndLaunch();
  }

  Future<void> _requestPermissionAndLaunch() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        setState(() {
          _errorMessage = status == PermissionStatus.permanentlyDenied
              ? 'Kamera izni kalıcı olarak reddedildi. Lütfen ayarlardan izin verin.'
              : 'Formunu analiz edebilmemiz için kamera iznine ihtiyacımız var.';
          _isLaunching = false;
        });
      }
      return;
    }

    _hasPermission = true;

    // EventChannel dinlemeye başla (coaching feedback'leri için)
    _poseBridge.startListening();

    // Native ExerciseCoachingActivity'yi başlat
    final success = await _poseBridge.startExerciseCoaching(
      exerciseName: widget.exerciseConfig.displayName,
      exerciseType: widget.exerciseConfig.type.name,
      description: 'Egzersiz koçluk modu',
    );

    if (!success && mounted) {
      setState(() {
        _errorMessage = 'Native activity başlatılamadı';
        _isLaunching = false;
      });
      return;
    }

    // Stopwatch onExerciseStarted callback'inde başlıyor


    // UI refresh timer
    _uiRefreshTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() {});
    });

    if (mounted) {
      setState(() {
        _isLaunching = false;
      });
    }
  }

  void _stopSession() {
    _uiRefreshTimer?.cancel();
    _poseBridge.stopListening();
    _elapsedStopwatch.stop();

    if (mounted) {
      // Native'den gelen gerçek verilerle SessionResult oluştur
      final repCount = _poseBridge.repCount;
      final accuracy = _poseBridge.accuracy;
      
      // Native taraftaki başarılı rep'leri tahmin et (ortalama accuracy yüksekse)
      final perfectReps = accuracy > 0.8 ? repCount : (repCount * 0.7).toInt();
      final acceptableReps = repCount - perfectReps;
      
      final result = SessionResult(
        exerciseType: widget.exerciseConfig.type,
        totalReps: repCount,
        perfectReps: perfectReps,
        acceptableReps: acceptableReps > 0 ? acceptableReps : 0,
        badReps: 0,
        totalDuration: _elapsedStopwatch.elapsed,
        repHistory: [], // Native tarafta history tutulmadığı için şimdilik boş
        startTime: DateTime.now().subtract(_elapsedStopwatch.elapsed),
        endTime: DateTime.now(),
      );

      // Set tamamlama kutlaması (isterseniz buraya da konabilir ama genelde rep bittiğinde çalar)
      if (repCount > 0) {
         _feedbackEngine.onSetCompleted(totalReps: repCount, successRate: accuracy * 100);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FitnessSessionSummary(
            result: result,
            exerciseConfig: widget.exerciseConfig,
          ),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _uiRefreshTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (_hasPermission && !_isLaunching) {
        _uiRefreshTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
          if (mounted) setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    _uiRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _poseBridge.dispose();
    _feedbackEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Native Activity çalışıyor — Flutter'da bekleme ekranı
          _buildMainContent(),

          // Üst Bilgi Barı
          _buildTopBar(),

          // Debug Overlay — coaching feedback
          if (kDebugMode) _buildDebugOverlay(),

          // Alt Bilgi — Rep Sayacı
          _buildBottomBar(),

          // Geri butonu
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (!_hasPermission && _errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.videocam_off, color: AppColors.error, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Görüntüler cihazında kalır, sunucuya gönderilmez.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _requestPermissionAndLaunch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Tekrar Dene'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => openAppSettings(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ayarlar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (_isLaunching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryAccent),
            const SizedBox(height: 16),
            const Text('Kamera hazırlanıyor...',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Text(widget.exerciseConfig.displayName,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      );
    }

    // Native Activity çalışıyor
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: AppColors.success, size: 48),
            const SizedBox(height: 16),
            const Text('Kamera aktif — Egzersizine başla!',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            if (_poseBridge.feedback.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _poseBridge.feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.primaryAccent, fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.exerciseConfig.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatElapsed(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _poseBridge.isActive
                  ? Colors.green.withValues(alpha: 0.8)
                  : Colors.grey.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _poseBridge.isActive ? Colors.white : Colors.white54,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _poseBridge.isActive ? 'Aktif' : 'Bekleniyor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 65,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚀 MLKIT NATIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Status: ${_poseBridge.statusMessage}', style: const TextStyle(color: Colors.white, fontSize: 11)),
            Text('Accuracy: ${(_poseBridge.accuracy * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.cyanAccent, fontSize: 11)),
            Text('Feedback: ${_poseBridge.feedback}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text('Rep: ${_poseBridge.repCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 30,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Sol: Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⏳', style: TextStyle(fontSize: 20)),
                Text(
                  _poseBridge.isActive ? 'Aktif' : 'Bekleniyor',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            // Orta: Rep counter (native'den gelen)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_poseBridge.repCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/ ${widget.exerciseConfig.targetReps}',
                  style: const TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ],
            ),
            // Sağ: Stop butonu
            GestureDetector(
              onTap: _stopSession,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stop, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 4,
      child: IconButton(
        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  String _formatElapsed() {
    final elapsed = _elapsedStopwatch.elapsed;
    final m = elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
