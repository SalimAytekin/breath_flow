import 'package:flutter/material.dart';
import '../models/fitness_exercise.dart';

/// Antrenman özet/sonuç ekranı.
/// Egzersiz tamamlandıktan sonra gösterilir.
class AIWorkoutSummaryScreen extends StatefulWidget {
  final FitnessProgram program;
  final int? completedReps;
  final double? accuracyScore;

  const AIWorkoutSummaryScreen({
    super.key,
    required this.program,
    this.completedReps,
    this.accuracyScore,
  });

  @override
  State<AIWorkoutSummaryScreen> createState() =>
      _AIWorkoutSummaryScreenState();
}

class _AIWorkoutSummaryScreenState extends State<AIWorkoutSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Animasyonları başlat
    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Büyük onay animasyonu
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🎉', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tebrik başlığı
                const Text(
                  'Harika İş Çıkardın!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.program.name} tamamlandı',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // İstatistik kartları
                Row(
                  children: [
                    _buildStatCard(
                      emoji: widget.program.icon,
                      label: 'Program',
                      value: widget.program.exerciseCount.toString(),
                      unit: 'Hareket',
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      emoji: '⏱️',
                      label: 'Süre',
                      value: widget.program.totalDuration,
                      unit: '',
                    ),
                    if (widget.accuracyScore != null) ...[
                      const SizedBox(width: 12),
                      _buildStatCard(
                        emoji: '🎯',
                        label: 'Doğruluk',
                        value:
                            '${(widget.accuracyScore! * 100).toStringAsFixed(0)}%',
                        unit: '',
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 32),

                // Motivasyon mesajı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      const Text('💡',
                          style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.program.category == FitnessCategory.posture
                              ? 'Düzenli yapıldığında boyun ve omuz gerginliği büyük ölçüde azalır. Yarın tekrar hatırlatırım.'
                              : 'Vücudun bugün çalıştı! Muscle recovery için 48 saat dinlenmeyi unutma.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Ana sayfaya dön butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Ana sayfaya tüm stacki temizleyerek dön
                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F0F14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Ana Sayfaya Dön',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Yeniden başlat
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Tekrar Yap',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String label,
    required String value,
    required String unit,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
