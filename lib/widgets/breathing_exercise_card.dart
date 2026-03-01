import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/breathing_exercise.dart';
import '../models/premium_trigger.dart';
import '../constants/app_colors.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/smart_premium_dialog.dart';

class BreathingExerciseCard extends StatelessWidget {
  final BreathingExercise exercise;
  final bool isSelected;
  final VoidCallback onTap;

  const BreathingExerciseCard({
    super.key,
    required this.exercise,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected 
          ? BorderSide(color: AppColors.primary, width: 2)
          : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleTap(context),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primaryLight.withOpacity(0.05),
                  ],
                )
              : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Görsel ve başlık
              Row(
                children: [
                  // Egzersiz görseli
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(exercise.imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exercise.totalCycleTime} saniye/tekrar',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<UserPreferencesProvider>(
                    builder: (context, userPrefs, child) {
                      final isFavorite = userPrefs.isFavoriteExercise(exercise.type.name);
                      
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          userPrefs.toggleFavoriteExercise(exercise.type.name);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFavorite 
                                ? Colors.red.shade50 
                                : AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFavorite 
                                  ? Colors.red.shade300 
                                  : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red.shade400 : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                  // PRO etiketi - Sadece premium olmayan kullanıcılara göster
                  if (exercise.isPremium)
                    Consumer<PremiumProvider>(
                      builder: (context, premium, _) {
                        if (premium.isPremiumUser) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.premium.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.premium.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.diamond,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                exercise.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: exercise.steps.map((step) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStepColor(step.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${step.duration}s',
                      style: TextStyle(
                        color: _getStepColor(step.type),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔒 Premium kontrollü tıklama işleyicisi
  void _handleTap(BuildContext context) {
    // Premium egzersiz kontrolü
    if (exercise.isPremium) {
      final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
      if (!premiumProvider.canAccessPremiumContent(exercise.isPremium)) {
        HapticFeedback.heavyImpact();
        final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
          (t) => t.targetFeatures.contains(PremiumProvider.featurePremiumExercises),
          orElse: () => PremiumTrigger.predefinedTriggers.first,
        );
        SmartPremiumDialog.show(context, trigger);
        return;
      }
    }
    
    // Premium değilse veya erişim varsa normal onTap çağır
    onTap();
  }

  Color _getStepColor(BreathingStepType type) {
    switch (type) {
      case BreathingStepType.inhale:
        return AppColors.success;
      case BreathingStepType.hold:
        return AppColors.warning;
      case BreathingStepType.exhale:
        return AppColors.info;
      case BreathingStepType.holdAfterExhale:
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
} 