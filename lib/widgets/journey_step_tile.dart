import 'package:breathe_flow/constants/app_colors.dart';
import 'package:breathe_flow/models/meditation_journey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

enum StepStatus { locked, unlocked, completed }

class JourneyStepTile extends StatelessWidget {
  final JourneyStep step;
  final int stepIndex;
  final StepStatus status;
  final bool isCurrentlyPlaying;
  final VoidCallback onTap;

  const JourneyStepTile({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.status,
    required this.isCurrentlyPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isPlayable = status == StepStatus.unlocked;

    return InkWell(
      onTap: isPlayable ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            _buildStepNumber(theme),
            const SizedBox(width: 16),
            _buildStepInfo(theme),
            const Spacer(),
            _buildStepIcon(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStepNumber(ThemeData theme) {
    return Text(
      (stepIndex + 1).toString().padLeft(2, '0'),
      style: theme.textTheme.headlineSmall?.copyWith(
        color: status == StepStatus.locked
            ? AppColors.textTertiary
            : DarkAppColors.textSecondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStepInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: status == StepStatus.locked
                ? AppColors.textTertiary
                : DarkAppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              FeatherIcons.clock,
              size: 14,
              color: status == StepStatus.locked
                  ? AppColors.textTertiary.withOpacity(0.7)
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              step.duration,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: status == StepStatus.locked
                    ? AppColors.textTertiary.withOpacity(0.7)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIcon(ThemeData theme) {
    IconData iconData;
    Color iconColor;
    Color? backgroundColor;

    if (isCurrentlyPlaying) {
      iconData = FeatherIcons.pause;
      iconColor = Colors.white;
      backgroundColor = DarkAppColors.primary;
    } else {
      switch (status) {
        case StepStatus.locked:
          iconData = FeatherIcons.lock;
          iconColor = AppColors.textTertiary;
          backgroundColor = AppColors.surfaceVariant.withOpacity(0.5);
          break;
        case StepStatus.unlocked:
          iconData = FeatherIcons.play;
          iconColor = Colors.white;
          backgroundColor = DarkAppColors.primary;
          break;
        case StepStatus.completed:
          iconData = FeatherIcons.play;
          iconColor = DarkAppColors.primary;
          backgroundColor = DarkAppColors.primary.withOpacity(0.15);
          break;
      }
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }
} 