import 'package:flutter/material.dart';

/// 🌙 Deep Night Serenity - Professional Color System
/// Meditopia, Calm, Better Sleep seviyesinde profesyonel renk paleti
class AppColors {
  // 🌌 BACKGROUND SYSTEM
  static const Color primaryBackground = Color(0xFF0B0D17);    // Gece mavisi - çok koyu
  static const Color secondaryBackground = Color(0xFF1A1D29);  // Hafif daha açık
  static const Color cardBackground = Color(0xFF242938);       // Kart arkaplanı
  static const Color surfaceElevated = Color(0xFF2D3142);      // Yükseltilmiş yüzeyler
  
  // 🎨 CONTENT COLORS
  static const Color textPrimary = Color(0xFFF8F9FD);         // Ana metin - neredeyse beyaz
  static const Color textSecondary = Color(0xFFA8ABBF);       // İkincil metin - gri
  static const Color textTertiary = Color(0xFF6B7280);        // Üçüncül metin - koyu gri
  static const Color textDisabled = Color(0xFF4B5563);        // Devre dışı metin
  
  // ✨ ACCENT SYSTEM
  static const Color primaryAccent = Color(0xFF7C3AED);       // Mor - ana vurgu
  static const Color secondaryAccent = Color(0xFF06B6D4);     // Cyan - ikincil vurgu
  static const Color success = Color(0xFF10B981);             // Yeşil - başarı
  static const Color warning = Color(0xFFF59E0B);             // Turuncu - uyarı
  static const Color error = Color(0xFFEF4444);               // Kırmızı - hata
  
  // 🌸 MOOD COLORS
  static const Color relaxation = Color(0xFF8B5CF6);          // Lavanta
  static const Color focus = Color(0xFF06B6D4);               // Cyan
  static const Color sleep = Color(0xFF6366F1);               // İndigo
  static const Color energy = Color(0xFFF59E0B);              // Turuncu
  
  // 🔮 GLASSMORPHISM EFFECTS
  static const Color glassLight = Color(0x0DF8F9FD);          // rgba(248, 249, 253, 0.05)
  static const Color glassMedium = Color(0x14F8F9FD);         // rgba(248, 249, 253, 0.08)
  static const Color glassStrong = Color(0x1FF8F9FD);         // rgba(248, 249, 253, 0.12)
  static const Color glassBorder = Color(0x26F8F9FD);         // rgba(248, 249, 253, 0.15)
  
  // 🌫️ SHADOW COLORS
  static const Color shadowLight = Color(0x4D000000);         // rgba(0, 0, 0, 0.3)
  static const Color shadowMedium = Color(0x66000000);        // rgba(0, 0, 0, 0.4)
  static const Color shadowDark = Color(0x80000000);          // rgba(0, 0, 0, 0.5)
  
  // 🌈 GRADIENT SYSTEM
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED),  // primaryAccent
      Color(0xFF8B5CF6),  // relaxation
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0B0D17),  // primaryBackground
      Color(0xFF1A1D29),  // secondaryBackground
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF242938),  // cardBackground
      Color(0xFF2D3142),  // surfaceElevated
    ],
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x0DF8F9FD),  // glassLight
      Color(0x1FF8F9FD),  // glassStrong
    ],
  );
  
  // 🎭 MOOD GRADIENTS
  static const LinearGradient relaxationGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6),  // relaxation
      Color(0xFF6D28D9),  // deep violet
      Color(0xFF7C3AED),  // primaryAccent
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient focusGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF06B6D4),  // focus
      Color(0xFF0891B2),  // darker cyan
    ],
  );
  
  static const LinearGradient sleepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),  // sleep
      Color(0xFF4F46E5),  // darker indigo
    ],
  );
  
  static const LinearGradient energyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B),  // energy
      Color(0xFFD97706),  // darker orange
    ],
  );
  
  // 🎯 UTILITY COLORS
  static const Color divider = Color(0xFF374151);             // Bölücü çizgiler
  static const Color border = Color(0xFF4B5563);              // Kenarlıklar
  static const Color overlay = Color(0x80000000);             // Modal overlay
  static const Color shimmer = Color(0x1AF8F9FD);            // Loading shimmer
  
  // 📱 NAVIGATION COLORS
  static const Color navBackground = Color(0xFF1A1D29);       // Navigation bar
  static const Color navSelected = Color(0xFF7C3AED);         // Seçili nav item
  static const Color navUnselected = Color(0xFF6B7280);       // Seçili olmayan nav item
  
  // 🔔 STATUS COLORS
  static const Color online = Color(0xFF10B981);              // Online status
  static const Color offline = Color(0xFF6B7280);             // Offline status
  static const Color premium = Color(0xFFFFD700);             // Premium badge
  
  // 🌟 SPECIAL EFFECTS
  static const Color glow = Color(0x4D7C3AED);               // Glow effect
  static const Color highlight = Color(0x1F7C3AED);          // Highlight effect
  static const Color ripple = Color(0x1AF8F9FD);             // Ripple effect
  
  // 🔄 BACKWARD COMPATIBILITY (Eski isimlerin yeni karşılıkları)
  static const Color primary = primaryAccent;                 // Eski: primary → Yeni: primaryAccent
  static const Color primaryLight = secondaryAccent;          // Eski: primaryLight → Yeni: secondaryAccent
  static const Color info = focus;                           // Eski: info → Yeni: focus
  static const Color surface = surfaceElevated;              // Eski: surface → Yeni: surfaceElevated
  static const Color cardStroke = border;                    // Eski: cardStroke → Yeni: border
  static const Color surfaceVariant = cardBackground;        // Eski: surfaceVariant → Yeni: cardBackground
  static const Color background = primaryBackground;         // Eski: background → Yeni: primaryBackground

  // Yeni Akıllı Öneri Kartı Gradyeni
  static const LinearGradient recommendationGradient = LinearGradient(
    colors: [Color(0xFF6B46C1), Color(0xFF4C6EF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.1, 0.9],
  );
}

/// 🔄 BACKWARD COMPATIBILITY CLASS
/// Eski DarkAppColors sınıfının yeni karşılığı
class DarkAppColors {
  static const Color primary = AppColors.primaryAccent;
  static const Color primaryLight = AppColors.secondaryAccent;
  static const Color background = AppColors.primaryBackground;
  static const Color surface = AppColors.surfaceElevated;
  static const Color surfaceVariant = AppColors.cardBackground;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color info = AppColors.focus;
  static const Color cardStroke = AppColors.border;
  
  static const LinearGradient primaryGradient = AppColors.primaryGradient;
}

/// 🎨 Light Theme Colors
/// Professional light theme matching Deep Night Serenity aesthetic
class LightAppColors {
  // Background System - Light
  static const Color primaryBackground = Color(0xFFFBFBFD);
  static const Color secondaryBackground = Color(0xFFF8F9FA);
  static const Color tertiaryBackground = Color(0xFFF1F3F4);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  
  // Content Colors - Light
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  
  // Accent System - Light (keeping same vibrant colors)
  static const Color primaryAccent = Color(0xFF7C3AED);
  static const Color secondaryAccent = Color(0xFF06B6D4);
  static const Color focus = Color(0xFF0EA5E9);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Mood Colors - Light (adjusted for light theme)
  static const Color relaxation = Color(0xFFB794F6);
  static const Color energy = Color(0xFFED8936);
  static const Color sleep = Color(0xFF667EEA);
  
  // Glassmorphism - Light
  static const Color glassLight = Color(0xFFF9FAFB);
  static const Color glassMedium = Color(0xFFE5E7EB);
  static const Color glassDark = Color(0xFFD1D5DB);
  static const Color glassBorder = Color(0xFFE5E7EB);
  
  // Utility Colors - Light
  static const Color border = Color(0xFFE5E7EB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardStroke = Color(0xFFE5E7EB);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color overlay = Color(0x80FFFFFF);
  static const Color ripple = Color(0x1A7C3AED);
  static const Color highlight = Color(0x0D7C3AED);
  
  // Shadow Colors - Light
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
  
  // Gradient System - Light
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient relaxationGradient = LinearGradient(
    colors: [Color(0xFFB794F6), Color(0xFFD6BCFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient energyGradient = LinearGradient(
    colors: [Color(0xFFED8936), Color(0xFFF6AD55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sleepGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient focusGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// 🎨 Adaptive Colors Helper
class AdaptiveColors {
  /// Get background color based on theme
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? LightAppColors.primaryBackground
        : AppColors.primaryBackground;
  }
  
  /// Get text color based on theme
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? LightAppColors.textPrimary
        : AppColors.textPrimary;
  }
  
  /// Get text secondary color based on theme
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? LightAppColors.textSecondary
        : AppColors.textSecondary;
  }
  
  /// Get card background based on theme
  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? LightAppColors.cardBackground
        : AppColors.cardBackground;
  }
  
  /// Get surface color based on theme
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? LightAppColors.surface
        : AppColors.surface;
  }
  
  /// Get border color based on theme
  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? LightAppColors.border
        : AppColors.border;
  }
  
  /// Get primary gradient based on theme
  static LinearGradient getPrimaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? LightAppColors.primaryGradient
        : AppColors.primaryGradient;
  }
  
  /// Get relaxation gradient based on theme
  static LinearGradient getRelaxationGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? LightAppColors.relaxationGradient
        : AppColors.relaxationGradient;
  }
  
  /// Get shadow color based on theme
  static Color getShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? LightAppColors.shadowMedium
        : AppColors.shadowMedium;
  }
} 