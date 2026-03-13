import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import '../../../constants/app_colors.dart';
import '../models/exercise_config.dart';
import '../widgets/countdown_overlay.dart';
import 'fitness_exercise_screen.dart';

/// 📐 Telefon Konumlandırma Rehberi
///
/// Kamera izni → Konumlandırma talimatları → Geri sayım → Egzersiz başlat
class PositioningGuideScreen extends StatefulWidget {
  final ExerciseConfig config;

  const PositioningGuideScreen({super.key, required this.config});

  @override
  State<PositioningGuideScreen> createState() => _PositioningGuideScreenState();
}

class _PositioningGuideScreenState extends State<PositioningGuideScreen> {
  bool _showCountdown = false;

  void _startCountdown() {
    setState(() => _showCountdown = true);
  }

  void _onCountdownComplete() {
    // Geri sayım tamamlandı — Egzersiz ekranına geç
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FitnessExerciseScreen(
          exerciseConfig: widget.config,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          // Ana içerik
          SafeArea(
            child: Column(
              children: [
                // Üst bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Hazırlık',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lottie Animasyon
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Lottie animasyon
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.config.gradientColors.first
                                      .withOpacity(0.1),
                                  widget.config.gradientColors.last
                                      .withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.glassBorder),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Lottie.asset(
                                'assets/lottie/breathing_circle.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Başlık
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 100),
                          child: const Text(
                            'Telefonunu Yerleştir',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            widget.config.phonePosition.instruction,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Konumlandırma adımları
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 300),
                          child: _buildStepsList(),
                        ),

                        const SizedBox(height: 24),

                        // Güvenlik / Gizlilik notu
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 400),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.2),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.lock_outline,
                                    color: AppColors.success, size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Kamera görüntülerin sadece cihazında işlenir, sunucuya gönderilmez.',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CTA butonu — sabit alt
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                border: Border(
                  top: BorderSide(color: AppColors.glassBorder),
                ),
              ),
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 600),
                child: GestureDetector(
                  onTap: _startCountdown,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.config.gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: widget.config.gradientColors.first
                              .withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Hazırım, Başla!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Geri sayım overlay
          if (_showCountdown)
            CountdownOverlay(
              onComplete: _onCountdownComplete,
              gradientColors: widget.config.gradientColors,
            ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    final steps = [
      _StepInfo(
        icon: Icons.phone_android,
        title: widget.config.phonePosition.displayName,
        subtitle: 'Telefonu sabit bir yüzeye yerleştir',
      ),
      const _StepInfo(
        icon: Icons.person_outline,
        title: 'Kadrajına gir',
        subtitle: 'Tam vücudun kamerada görünsün',
      ),
      const _StepInfo(
        icon: Icons.lightbulb_outline,
        title: 'Aydınlık ortam',
        subtitle: 'İyi ışık, daha iyi analiz sonuçları',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 16 : 0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    step.icon,
                    color: AppColors.primaryAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepInfo {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StepInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
