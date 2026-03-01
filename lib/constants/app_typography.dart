import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 🔤 Professional Typography System
/// Primary: Nunito (warm, friendly UI)
/// Display: Cinzel (premium headings)
class AppTypography {
  // =========================
  // 🎨 FONT FAMILIES
  // =========================
  static String get primaryFont => GoogleFonts.nunito().fontFamily ?? 'Nunito';
  static String get secondaryFont => GoogleFonts.nunito().fontFamily ?? 'Nunito';

  /// Premium display font for hero / section headings
  static String get displayFont => GoogleFonts.cinzel().fontFamily ?? 'Cinzel';

  static const String fallbackFont = 'Roboto';

  // =========================
  // 🌟 PREMIUM DISPLAY (CINZEL)
  // Use these for: "İyi Akşamlar", "Şu An Yardım Et", section titles etc.
  // =========================
  static TextStyle get brandDisplayXL => GoogleFonts.cinzel(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: 0.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get brandDisplayL => GoogleFonts.cinzel(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: 0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get brandDisplayM => GoogleFonts.cinzel(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.20,
        letterSpacing: 0.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get brandDisplayS => GoogleFonts.cinzel(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
      );

  // =========================
  // 🏷️ HEADINGS (NUNITO)
  // =========================
  static TextStyle get displayLarge => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
        letterSpacing: -0.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineLarge => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.375,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  // =========================
  // 🏷️ TITLE STYLES
  // =========================
  static TextStyle get titleLarge => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  // =========================
  // 📝 BODY TEXT
  // =========================
  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0,
        color: AppColors.textTertiary,
      );

  // =========================
  // 🏷️ LABELS
  // =========================
  static TextStyle get labelLarge => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
        color: AppColors.textTertiary,
      );

  // =========================
  // 💫 SPECIAL STYLES
  // =========================
  static TextStyle get buttonText => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonTextSmall => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
        color: AppColors.textTertiary,
      );

  static TextStyle get overline => GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.6,
        letterSpacing: 1.5,
        color: AppColors.textSecondary,
      );

  // =========================
  // 🎯 NAVIGATION STYLES
  // =========================
  static TextStyle get navLabel => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
        color: AppColors.navUnselected,
      );

  static TextStyle get navLabelSelected => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.5,
        color: AppColors.navSelected,
      );

  // =========================
  // 🌟 ACCENT STYLES
  // =========================
  static TextStyle get accent => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.primaryAccent,
      );

  static TextStyle get accentSmall => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0,
        color: AppColors.primaryAccent,
      );

  // =========================
  // 🎭 MOOD STYLES
  // =========================
  static TextStyle get moodRelaxation => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.relaxation,
      );

  static TextStyle get moodFocus => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.focus,
      );

  static TextStyle get moodSleep => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.sleep,
      );

  static TextStyle get moodEnergy => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.energy,
      );

  // =========================
  // 📊 STATUS STYLES
  // =========================
  static TextStyle get success => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0,
        color: AppColors.success,
      );

  static TextStyle get warning => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0,
        color: AppColors.warning,
      );

  static TextStyle get error => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0,
        color: AppColors.error,
      );

  // =========================
  // 🧰 UTILITY METHODS
  // =========================
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
