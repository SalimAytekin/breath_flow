import 'package:breathe_flow/providers/premium_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/breathing_exercise.dart';
import '../providers/breathing_provider.dart';
import 'breathing_screen.dart';

class ExerciseListScreen extends StatelessWidget {
  final BreathingCategory category;
  final String heroTag;

  const ExerciseListScreen({
    super.key,
    required this.category,
    required this.heroTag,
  });

  String _getCategoryTitle(BreathingCategory category) {
    switch (category) {
      case BreathingCategory.odaklanma:
        return 'Odaklanma';
      case BreathingCategory.kaygiVeStres:
        return 'Kaygı ve Stres';
      case BreathingCategory.uykuVeRahatlama:
        return 'Uyku ve Rahatlama';
      case BreathingCategory.enerjiVeCanlilik:
        return 'Enerji ve Canlılık';
    }
  }

  @override
  Widget build(BuildContext context) {
    final breathingProvider = Provider.of<BreathingProvider>(context, listen: false);
    final exercises = BreathingExercise.allExercises
        .where((ex) => ex.category == category)
        .toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getCategoryColor(category).withOpacity(0.15),
              AppColors.primaryBackground.withOpacity(0.5),
              AppColors.primaryBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              expandedHeight: 120,
              leading: IconButton(
                icon: const Icon(FeatherIcons.arrowLeft),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: Hero(
                tag: heroTag,
                child: FlexibleSpaceBar(
                  title: Text(
                    _getCategoryTitle(category),
                    style: AppTypography.headlineSmall,
                  ),
                  centerTitle: true,
                  background: Container(color: Colors.transparent),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large, vertical: AppSpacing.large),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = exercises[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                      child: _buildNewExerciseCard(context, breathingProvider, exercise),
                    );
                  },
                  childCount: exercises.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(BreathingCategory category) {
    switch (category) {
      case BreathingCategory.odaklanma:
        return AppColors.focus;
      case BreathingCategory.kaygiVeStres:
        return AppColors.relaxation;
      case BreathingCategory.uykuVeRahatlama:
        return AppColors.sleep;
      case BreathingCategory.enerjiVeCanlilik:
        return AppColors.energy;
    }
  }

  Widget _buildNewExerciseCard(
    BuildContext context, BreathingProvider provider, BreathingExercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          onTap: () {
            if (exercise.isPremium && !context.read<PremiumProvider>().isPremiumUser) {
              context.read<PremiumProvider>().showFeatureLimitTrigger('advanced_breathing');
              return;
            }
            provider.setExercise(exercise);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const BreathingScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.large),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              color: AppColors.surfaceElevated.withOpacity(0.8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık ve Premium İkonu
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: AppTypography.headlineSmall,
                            ),
                          ),
                          if (exercise.isPremium)
                            Icon(FeatherIcons.award, color: AppColors.premium, size: 20),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.small),

                      // Ritim Bilgisi
                      Text(
                        exercise.timingsFormatted,
                        style: AppTypography.bodyMedium.copyWith(color: _getCategoryColor(category)),
                      ),
                      const SizedBox(height: AppSpacing.large),

                      // Alt Bilgi Etiketleri (Zorluk, Süre)
                      Row(
                        children: [
                          _buildInfoTag(
                            icon: FeatherIcons.shield,
                            text: exercise.purpose,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.large),
                          _buildDifficultyBadge(exercise.difficulty),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                // Başlat Butonu
                Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                   decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(FeatherIcons.play, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // YENİ: Zorluk seviyesi rozeti oluşturan yardımcı widget
  Widget _buildDifficultyBadge(ExerciseDifficulty difficulty) {
    final Map<ExerciseDifficulty, dynamic> S = {
      ExerciseDifficulty.beginner: {'text': 'Başlangıç', 'color': AppColors.success},
      ExerciseDifficulty.intermediate: {'text': 'Orta', 'color': AppColors.warning},
      ExerciseDifficulty.advanced: {'text': 'İleri', 'color': AppColors.error},
    };

    final selected = S[difficulty]!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.tiny,
      ),
      decoration: BoxDecoration(
        color: selected['color'].withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: Text(
        selected['text'],
        style: AppTypography.labelSmall.copyWith(
          color: selected['color'],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Bilgi etiketleri için yardımcı widget
  Widget _buildInfoTag({required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.small),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
} 