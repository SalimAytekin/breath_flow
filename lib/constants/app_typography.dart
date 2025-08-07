import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 🔤 Professional Typography System
/// SF Pro Display/Roboto based typography hierarchy
class AppTypography {
  // 🎨 FONT FAMILIES
  static const String primaryFont = 'SF Pro Display';
  static const String secondaryFont = 'SF Pro Text';
  static const String fallbackFont = 'Roboto';
  
  // 🏷️ HEADINGS
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,  // Bold
    height: 1.25,                 // Line height: 40px
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,  // Bold
    height: 1.29,                 // Line height: 36px
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,  // SemiBold
    height: 1.33,                 // Line height: 32px
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,  // SemiBold
    height: 1.4,                  // Line height: 28px
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.33,                 // Line height: 24px
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.375,                // Line height: 22px
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );
  
  // 📝 BODY TEXT
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,  // Regular
    height: 1.5,                  // Line height: 24px
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: secondaryFont,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,  // Regular
    height: 1.43,                 // Line height: 20px
    letterSpacing: 0,
    color: AppColors.textSecondary,
    fontFamily: secondaryFont,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,  // Regular
    height: 1.33,                 // Line height: 16px
    letterSpacing: 0,
    color: AppColors.textTertiary,
    fontFamily: secondaryFont,
  );
  
  // 🏷️ LABELS
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.43,                 // Line height: 20px
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    fontFamily: secondaryFont,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.33,                 // Line height: 16px
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
    fontFamily: secondaryFont,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.4,                  // Line height: 14px
    letterSpacing: 0.5,
    color: AppColors.textTertiary,
    fontFamily: secondaryFont,
  );
  
  // 💫 SPECIAL STYLES
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.5,                  // Line height: 24px
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );
  
  static const TextStyle buttonTextSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.43,                 // Line height: 20px
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,  // Regular
    height: 1.33,                 // Line height: 16px
    letterSpacing: 0.4,
    color: AppColors.textTertiary,
    fontFamily: secondaryFont,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.6,                  // Line height: 16px
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
    fontFamily: secondaryFont,
  );
  
  // 🎯 NAVIGATION STYLES
  static const TextStyle navLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.33,                 // Line height: 16px
    letterSpacing: 0.5,
    color: AppColors.navUnselected,
    fontFamily: secondaryFont,
  );
  
  static const TextStyle navLabelSelected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.33,                 // Line height: 16px
    letterSpacing: 0.5,
    color: AppColors.navSelected,
    fontFamily: secondaryFont,
  );
  
  // 🌟 ACCENT STYLES
  static const TextStyle accent = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.5,                  // Line height: 24px
    letterSpacing: 0,
    color: AppColors.primaryAccent,
    fontFamily: primaryFont,
  );
  
  static const TextStyle accentSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.43,                 // Line height: 20px
    letterSpacing: 0,
    color: AppColors.primaryAccent,
    fontFamily: primaryFont,
  );
  
  // 🎭 MOOD STYLES
  static const TextStyle moodRelaxation = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.5,                  // Line height: 24px
    letterSpacing: 0,
    color: AppColors.relaxation,
    fontFamily: primaryFont,
  );
  
  static const TextStyle moodFocus = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.5,                  // Line height: 24px
    letterSpacing: 0,
    color: AppColors.focus,
    fontFamily: primaryFont,
  );
  
  static const TextStyle moodSleep = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.5,                  // Line height: 24px
    letterSpacing: 0,
    color: AppColors.sleep,
    fontFamily: primaryFont,
  );
  
  static const TextStyle moodEnergy = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.5,                  // Line height: 24px
    letterSpacing: 0,
    color: AppColors.energy,
    fontFamily: primaryFont,
  );
  
  // 📊 STATUS STYLES
  static const TextStyle success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.43,                 // Line height: 20px
    letterSpacing: 0,
    color: AppColors.success,
    fontFamily: secondaryFont,
  );
  
  static const TextStyle warning = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.43,                 // Line height: 20px
    letterSpacing: 0,
    color: AppColors.warning,
    fontFamily: secondaryFont,
  );
  
  static const TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.43,                 // Line height: 20px
    letterSpacing: 0,
    color: AppColors.error,
    fontFamily: secondaryFont,
  );
  
  // 🎪 UTILITY METHODS
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(color: style.color?.withOpacity(opacity));
  }
} 