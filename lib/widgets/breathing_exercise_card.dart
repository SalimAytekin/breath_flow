import 'package:flutter/material.dart';
import '../models/breathing_exercise.dart';
import '../constants/app_colors.dart';

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
        onTap: onTap,
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
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getExerciseColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getExerciseIcon(),
                      color: _getExerciseColor(),
                      size: 24,
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
                          '${exercise.totalCycleTime} saniye/döngü',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (exercise.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'PRO',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Color _getExerciseColor() {
    switch (exercise.type) {
      case BreathingType.boxBreathing:
        return AppColors.focus;
      case BreathingType.breathing478:
        return AppColors.relaxation;
      case BreathingType.deepBreathing:
        return AppColors.sleep;
      case BreathingType.calmingBreath:
        return AppColors.primary;
    }
  }

  IconData _getExerciseIcon() {
    switch (exercise.type) {
      case BreathingType.boxBreathing:
        return Icons.crop_square;
      case BreathingType.breathing478:
        return Icons.favorite;
      case BreathingType.deepBreathing:
        return Icons.waves;
      case BreathingType.calmingBreath:
        return Icons.spa;
    }
  }

  Color _getStepColor(BreathingStepType type) {
    switch (type) {
      case BreathingStepType.inhale:
        return AppColors.success;
      case BreathingStepType.hold:
        return AppColors.warning;
      case BreathingStepType.exhale:
        return AppColors.info;
    }
  }
} 