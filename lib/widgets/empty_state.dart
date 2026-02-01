import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import 'professional_button.dart';

/// 📭 Empty State Widget - Modern ve kullanışlı
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? color;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? AppColors.primaryAccent;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(AppSpacing.xLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withOpacity(0.2),
                    accentColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: accentColor,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xLarge),
            
            // Title
            Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.medium),
            
            // Message
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action Button
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxLarge),
              ProfessionalButton(
                text: actionText!,
                onPressed: onAction!,
                icon: FeatherIcons.arrowRight,
                buttonType: ButtonType.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 📭 Empty Favorites State
class EmptyFavoritesState extends StatelessWidget {
  final String type; // 'sounds' or 'exercises'
  final VoidCallback onExplore;
  
  const EmptyFavoritesState({
    super.key,
    required this.type,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final isSounds = type == 'sounds';
    
    return EmptyState(
      icon: FeatherIcons.heart,
      title: isSounds ? AppStrings.emptyFavoriteSoundTitle : AppStrings.emptyFavoriteExerciseTitle,
      message: isSounds 
          ? AppStrings.emptyFavoriteSoundMessage
          : AppStrings.emptyFavoriteExerciseMessage,
      actionText: AppStrings.exploreGoButton,
      onAction: onExplore,
      color: AppColors.relaxation,
    );
  }
}

/// 📭 No Activity State  
class NoActivityState extends StatelessWidget {
  final VoidCallback onStartSession;
  
  const NoActivityState({
    super.key,
    required this.onStartSession,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: FeatherIcons.activity,
      title: AppStrings.noActivityTitle,
      message: AppStrings.noActivityMessage,
      actionText: AppStrings.startNowButton,
      onAction: onStartSession,
      color: AppColors.energy,
    );
  }
}

