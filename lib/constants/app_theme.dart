import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// 🎨 Deep Night Serenity Theme System
/// Professional theme matching Meditopia, Calm, Better Sleep standards
class AppTheme {
  /// 🌅 Light Theme - Deep Night Serenity Light
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // 🎨 COLOR SCHEME
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: LightAppColors.primaryAccent,
        onPrimary: Colors.white,
        secondary: LightAppColors.secondaryAccent,
        onSecondary: Colors.white,
        tertiary: LightAppColors.relaxation,
        onTertiary: Colors.white,
        error: LightAppColors.error,
        onError: Colors.white,
        background: LightAppColors.primaryBackground,
        onBackground: LightAppColors.textPrimary,
        surface: LightAppColors.cardBackground,
        onSurface: LightAppColors.textPrimary,
        surfaceVariant: LightAppColors.surfaceElevated,
        onSurfaceVariant: LightAppColors.textSecondary,
        outline: LightAppColors.border,
        outlineVariant: LightAppColors.glassBorder,
        shadow: LightAppColors.shadowMedium,
        scrim: LightAppColors.overlay,
        inverseSurface: LightAppColors.textPrimary,
        onInverseSurface: LightAppColors.primaryBackground,
        inversePrimary: LightAppColors.primaryAccent,
        surfaceTint: LightAppColors.primaryAccent,
      ),
      
      scaffoldBackgroundColor: LightAppColors.primaryBackground,
      canvasColor: LightAppColors.primaryBackground,
      
      // 🔤 TYPOGRAPHY
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: LightAppColors.textPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: LightAppColors.textPrimary),
        displaySmall: AppTypography.displaySmall.copyWith(color: LightAppColors.textPrimary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: LightAppColors.textPrimary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: LightAppColors.textPrimary),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: LightAppColors.textPrimary),
        titleLarge: AppTypography.headlineMedium.copyWith(color: LightAppColors.textPrimary),
        titleMedium: AppTypography.headlineSmall.copyWith(color: LightAppColors.textPrimary),
        titleSmall: AppTypography.labelLarge.copyWith(color: LightAppColors.textPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: LightAppColors.textPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: LightAppColors.textSecondary),
        bodySmall: AppTypography.bodySmall.copyWith(color: LightAppColors.textSecondary),
        labelLarge: AppTypography.labelLarge.copyWith(color: LightAppColors.textPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: LightAppColors.textSecondary),
        labelSmall: AppTypography.labelSmall.copyWith(color: LightAppColors.textTertiary),
      ),
      
      // 📱 APP BAR THEME
      appBarTheme: AppBarTheme(
        backgroundColor: LightAppColors.secondaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: LightAppColors.textPrimary,
          size: AppSpacing.iconLarge,
        ),
        titleTextStyle: AppTypography.headlineMedium.copyWith(color: LightAppColors.textPrimary),
        toolbarHeight: AppSpacing.headerHeight,
        surfaceTintColor: Colors.transparent,
      ),
      
      // 🎴 CARD THEME
      cardTheme: CardTheme(
        color: LightAppColors.cardBackground,
        elevation: 0,
        shadowColor: LightAppColors.shadowLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          side: const BorderSide(
            color: LightAppColors.glassBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // 🔘 ELEVATED BUTTON THEME
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LightAppColors.primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: LightAppColors.shadowMedium,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          padding: AppSpacing.buttonPadding,
          textStyle: AppTypography.buttonText,
          minimumSize: const Size(120, 56),
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: LightAppColors.textPrimary,
        size: AppSpacing.iconMedium,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightAppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: LightAppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: LightAppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          borderSide: const BorderSide(color: LightAppColors.primaryAccent, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(color: LightAppColors.textSecondary),
        hintStyle: AppTypography.bodyMedium.copyWith(color: LightAppColors.textTertiary),
      ),
    );
  }

  /// 🌙 Primary Dark Theme - Deep Night Serenity
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // 🎨 COLOR SCHEME
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primaryAccent,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.secondaryAccent,
        onSecondary: AppColors.textPrimary,
        tertiary: AppColors.relaxation,
        onTertiary: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textPrimary,
        background: AppColors.primaryBackground,
        onBackground: AppColors.textPrimary,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        surfaceVariant: AppColors.surfaceElevated,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.divider,
        shadow: AppColors.shadowMedium,
        scrim: AppColors.overlay,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.primaryBackground,
        inversePrimary: AppColors.primaryAccent,
        surfaceTint: AppColors.primaryAccent,
      ),
      
      scaffoldBackgroundColor: AppColors.primaryBackground,
      canvasColor: AppColors.primaryBackground,
      
      // 🔤 TYPOGRAPHY
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.headlineMedium,
        titleMedium: AppTypography.headlineSmall,
        titleSmall: AppTypography.labelLarge,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      
      // 📱 APP BAR THEME
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppSpacing.iconLarge,
        ),
        titleTextStyle: AppTypography.headlineMedium,
        toolbarHeight: AppSpacing.headerHeight,
        surfaceTintColor: Colors.transparent,
      ),
      
      // 🎴 CARD THEME
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 0,
        shadowColor: AppColors.shadowLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          side: const BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // 🔘 ELEVATED BUTTON THEME
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shadowColor: AppColors.shadowMedium,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          padding: AppSpacing.buttonPadding,
          textStyle: AppTypography.buttonText,
          minimumSize: const Size(120, 56),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.primaryAccent.withOpacity(0.8);
            }
            if (states.contains(MaterialState.hovered)) {
              return AppColors.primaryAccent.withOpacity(0.9);
            }
            return AppColors.primaryAccent;
          }),
          elevation: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return 2;
            }
            if (states.contains(MaterialState.hovered)) {
              return 6;
            }
            return 4;
          }),
        ),
      ),
      
      // 🔲 OUTLINED BUTTON THEME
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.glassLight,
          elevation: 0,
          side: const BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          padding: AppSpacing.buttonPadding,
          textStyle: AppTypography.buttonText,
          minimumSize: const Size(120, 56),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.glassMedium;
            }
            if (states.contains(MaterialState.hovered)) {
              return AppColors.glassLight;
            }
            return AppColors.glassLight;
          }),
        ),
      ),
      
      // 📝 TEXT BUTTON THEME
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          padding: AppSpacing.buttonPaddingSmall,
          textStyle: AppTypography.buttonTextSmall,
        ).copyWith(
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.textPrimary;
            }
            if (states.contains(MaterialState.hovered)) {
              return AppColors.textPrimary;
            }
            return AppColors.textSecondary;
          }),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.glassLight;
            }
            if (states.contains(MaterialState.hovered)) {
              return AppColors.glassLight.withOpacity(0.5);
            }
            return Colors.transparent;
          }),
        ),
      ),
      
      // 🎯 BOTTOM NAVIGATION BAR THEME
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBackground,
        selectedItemColor: AppColors.navSelected,
        unselectedItemColor: AppColors.navUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.navLabelSelected,
        unselectedLabelStyle: AppTypography.navLabel,
        selectedIconTheme: const IconThemeData(
          size: AppSpacing.navIconSize,
        ),
        unselectedIconTheme: const IconThemeData(
          size: AppSpacing.navIconSize,
        ),
      ),
      
      // 📝 INPUT DECORATION THEME
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: const BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: const BorderSide(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: const BorderSide(
            color: AppColors.primaryAccent,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: AppSpacing.inputPadding,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTypography.labelMedium,
        floatingLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.primaryAccent,
        ),
      ),
      
      // 🎛️ SLIDER THEME
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryAccent,
        inactiveTrackColor: AppColors.surfaceElevated,
        thumbColor: AppColors.primaryAccent,
        overlayColor: AppColors.primaryAccent.withOpacity(0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      
      // 🔄 SWITCH THEME
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryAccent;
          }
          return AppColors.textTertiary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryAccent.withOpacity(0.3);
          }
          return AppColors.surfaceElevated;
        }),
      ),
      
      // 📊 PROGRESS INDICATOR THEME
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryAccent,
        linearTrackColor: AppColors.surfaceElevated,
        circularTrackColor: AppColors.surfaceElevated,
      ),
      
      // 🎨 ICON THEME
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: AppSpacing.iconLarge,
      ),
      primaryIconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppSpacing.iconLarge,
      ),
      
      // ➖ DIVIDER THEME
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      // 📋 LIST TILE THEME
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.glassLight,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        selectedColor: AppColors.primaryAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        contentPadding: AppSpacing.listItemPadding,
      ),
      
      // 🎪 ANIMATION THEME
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      // 🌟 FLOATING ACTION BUTTON THEME
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
      ),
      
      // 🎭 DIALOG THEME
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.cardBackground,
        elevation: 8,
        shadowColor: AppColors.shadowDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
        ),
        titleTextStyle: AppTypography.headlineSmall,
        contentTextStyle: AppTypography.bodyMedium,
      ),
      
      // 🍃 BOTTOM SHEET THEME
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.cardBackground,
        elevation: 8,
        modalElevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXLarge),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.textTertiary,
        dragHandleSize: const Size(40, 4),
      ),
      
      // 🎨 CHIP THEME
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.primaryAccent,
        disabledColor: AppColors.surfaceElevated.withOpacity(0.5),
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium,
        brightness: Brightness.dark,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
        ),
      ),
    );
  }
  

  
  // 🎨 CUSTOM DECORATIONS
  
  /// Standard Card Decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 6,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  /// Elevated Card Decoration
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 15,
        offset: const Offset(0, 10),
      ),
    ],
  );
  
  /// Glass Morphism Decoration
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: AppColors.glassLight,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  /// Primary Gradient Decoration
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryAccent.withOpacity(0.3),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  /// Mood Gradient Decorations
  static BoxDecoration get relaxationGradientDecoration => BoxDecoration(
    gradient: AppColors.relaxationGradient,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
    boxShadow: [
      BoxShadow(
        color: AppColors.relaxation.withOpacity(0.3),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get focusGradientDecoration => BoxDecoration(
    gradient: AppColors.focusGradient,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
    boxShadow: [
      BoxShadow(
        color: AppColors.focus.withOpacity(0.3),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get sleepGradientDecoration => BoxDecoration(
    gradient: AppColors.sleepGradient,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
    boxShadow: [
      BoxShadow(
        color: AppColors.sleep.withOpacity(0.3),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get energyGradientDecoration => BoxDecoration(
    gradient: AppColors.energyGradient,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
    boxShadow: [
      BoxShadow(
        color: AppColors.energy.withOpacity(0.3),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
} 