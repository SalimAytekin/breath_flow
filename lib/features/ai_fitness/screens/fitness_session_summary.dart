import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../constants/app_colors.dart';
import '../models/rep_result.dart';
import '../models/exercise_phase.dart';
import '../models/exercise_config.dart';
import 'exercise_catalog_screen.dart';

/// Egzersiz oturumu özet ekranı.
///
/// Kullanıcıya setin sonucunu gösterir:
/// toplam rep, başarı oranı, süre, kalite dağılımı.
class FitnessSessionSummary extends StatelessWidget {
  final SessionResult result;
  final ExerciseConfig? exerciseConfig;

  const FitnessSessionSummary({
    super.key,
    required this.result,
    this.exerciseConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Confetti animasyonu
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/lottie/confetti_celebration.json',
                repeat: false,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              const SizedBox(height: 20),

              // 🏆 Başlık
              const Text(
                '🏋️ Antrenman Tamamlandı!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                result.exerciseType.name,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 📊 Ana İstatistikler
              Row(
                children: [
                  _buildStatCard(
                    icon: Icons.repeat,
                    label: 'Toplam',
                    value: '${result.totalReps}',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.check_circle,
                    label: 'Başarı',
                    value: '${result.successRate.toStringAsFixed(0)}%',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.timer,
                    label: 'Süre',
                    value: _formatDuration(result.totalDuration),
                    color: Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 📈 Kalite Dağılımı
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kalite Dağılımı',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQualityRow('Mükemmel', result.perfectReps,
                        result.totalReps, Colors.green),
                    const SizedBox(height: 10),
                    _buildQualityRow('Kabul Edilebilir', result.acceptableReps,
                        result.totalReps, Colors.orange),
                    const SizedBox(height: 10),
                    _buildQualityRow('Yanlış Form', result.badReps,
                        result.totalReps, Colors.red),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 📋 Rep Geçmişi
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tekrar Detayları',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: result.repHistory.length,
                          itemBuilder: (context, index) {
                            final rep = result.repHistory[index];
                            return _buildRepTile(rep);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 💡 İyileştirme Önerisi
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryAccent.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: AppColors.primaryAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.badReps > result.perfectReps
                            ? 'Bir sonraki sefer formuna daha çok dikkat et!'
                            : result.successRate >= 80
                                ? 'Muhteşem! Formun harika, zorluğu artırabilirsin.'
                                : 'Güzel ilerleme! Biraz daha pratik yapınca mükemmel olacak.',
                        style: TextStyle(
                          color: AppColors.primaryAccent,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔁 Tekrar Yap + Başka Egzersiz Butonları
              if (exerciseConfig != null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseCatalogScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.grid_view, size: 18),
                        label: const Text('Başka Egzersiz'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Tekrar Yap'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // 🔙 Ana Sayfa
              ElevatedButton(
                onPressed: () {
                  // Pop all until explore screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.08),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ana Sayfaya Dön',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityRow(
      String label, int count, int total, Color color) {
    final ratio = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.white.withOpacity(0.1),
              color: color,
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepTile(RepResult rep) {
    Color qualityColor;
    IconData qualityIcon;

    switch (rep.quality) {
      case RepQuality.perfect:
        qualityColor = Colors.green;
        qualityIcon = Icons.star;
        break;
      case RepQuality.acceptable:
        qualityColor = Colors.orange;
        qualityIcon = Icons.check;
        break;
      case RepQuality.bad:
        qualityColor = Colors.red;
        qualityIcon = Icons.close;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: qualityColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(qualityIcon, color: qualityColor, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            'Rep #${rep.repNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '${rep.durationMs}ms',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}dk ${seconds}s';
    }
    return '${seconds}s';
  }
}
