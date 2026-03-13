import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../constants/app_colors.dart';
import '../models/exercise_config.dart';
import 'exercise_detail_screen.dart';

/// 🏋️ Egzersiz Kataloğu — Premium grid görünümü
///
/// Kullanıcı buradan egzersiz seçer.
/// Aktif egzersizler tıklanabilir, kilitli olanlar "Yakında" etiketi taşır.
class ExerciseCatalogScreen extends StatelessWidget {
  const ExerciseCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseConfig.allExercises();
    final active = exercises.where((e) => !e.isLocked).toList();
    final locked = exercises.where((e) => e.isLocked).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                    const Expanded(
                      child: Text(
                        'AI Fitness Koçu',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              color: AppColors.primaryAccent, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'BETA',
                            style: TextStyle(
                              color: AppColors.primaryAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Header Banner
            SliverToBoxAdapter(
              child: FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A2523), Color(0xFF332D2A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.primaryAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kameranla Egzersiz Yap',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'AI koçun formunu analiz etsin, seni yönlendirsin',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // "Egzersizler" Bölüm Başlığı
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Egzersizler',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${active.length} aktif',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Aktif Egzersiz Kartları
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: index * 100),
                      child: _ExerciseCard(
                        config: active[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailScreen(
                                config: active[index],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: active.length,
                ),
              ),
            ),

            // "Yakında" Bölüm Başlığı
            if (locked.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Yakında',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.lock_outline,
                          color: AppColors.textTertiary, size: 16),
                    ],
                  ),
                ),
              ),

            // Kilitli Egzersiz Kartları
            if (locked.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: Duration(milliseconds: (active.length + index) * 100),
                        child: _ExerciseCard(
                          config: locked[index],
                          onTap: null,
                        ),
                      );
                    },
                    childCount: locked.length,
                  ),
                ),
              ),

            // Alt boşluk
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

/// Tek bir egzersiz kartı
class _ExerciseCard extends StatelessWidget {
  final ExerciseConfig config;
  final VoidCallback? onTap;

  const _ExerciseCard({required this.config, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLocked = config.isLocked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLocked
                ? [
                    AppColors.cardBackground.withOpacity(0.5),
                    AppColors.surfaceElevated.withOpacity(0.5),
                  ]
                : [
                    config.gradientColors.first.withOpacity(0.15),
                    config.gradientColors.last.withOpacity(0.08),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? AppColors.glassBorder.withOpacity(0.3)
                : config.gradientColors.first.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // İkon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: isLocked
                    ? null
                    : LinearGradient(
                        colors: config.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isLocked ? AppColors.textDisabled.withOpacity(0.3) : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isLocked ? Icons.lock_outline : config.iconData,
                color: isLocked ? AppColors.textDisabled : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Başlık + Alt bilgi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.displayName,
                    style: TextStyle(
                      color: isLocked
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildTag(
                        config.difficulty.displayName,
                        isLocked
                            ? AppColors.textDisabled
                            : config.difficulty.color,
                        isLocked,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.timer_outlined,
                        '${config.estimatedDuration.inMinutes} dk',
                        isLocked,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.local_fire_department_outlined,
                        '${config.estimatedCalories} cal',
                        isLocked,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ok veya "Yakında" etiketi
            if (isLocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textDisabled.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Yakında',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, bool dimmed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (dimmed ? AppColors.textDisabled : color).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: dimmed ? AppColors.textDisabled : color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool dimmed) {
    final color = dimmed ? AppColors.textDisabled : AppColors.textTertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 11),
        ),
      ],
    );
  }
}
