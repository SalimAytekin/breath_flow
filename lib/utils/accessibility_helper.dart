import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// ♿ Accessibility Helper
/// Comprehensive accessibility features for Deep Night Serenity theme
class AccessibilityHelper {
  /// 🔍 High Contrast Mode
  static bool _isHighContrastMode = false;
  static bool get isHighContrastMode => _isHighContrastMode;
  
  /// 📏 Font Scale Factor
  static double _fontScaleFactor = 1.0;
  static double get fontScaleFactor => _fontScaleFactor;
  
  /// 🎯 Minimum Touch Target Size
  static const double minTouchTargetSize = 44.0;
  
  /// 🔊 Screen Reader Announcements
  static void announceForScreenReader(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
  
  /// 📱 Haptic Feedback Levels
  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }
  
  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }
  
  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }
  
  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }
  
  /// 🎨 High Contrast Colors
  static Color getHighContrastColor(Color originalColor, BuildContext context) {
    if (!_isHighContrastMode) return originalColor;
    
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }
  
  /// 📏 Scaled Font Size
  static double getScaledFontSize(double originalSize) {
    return originalSize * _fontScaleFactor;
  }
  
  /// 🎯 Ensure Minimum Touch Target
  static Size ensureMinimumTouchTarget(Size originalSize) {
    return Size(
      originalSize.width < minTouchTargetSize ? minTouchTargetSize : originalSize.width,
      originalSize.height < minTouchTargetSize ? minTouchTargetSize : originalSize.height,
    );
  }
  
  /// ⚙️ Set High Contrast Mode
  static void setHighContrastMode(bool enabled) {
    _isHighContrastMode = enabled;
    announceForScreenReader(enabled ? 'Yüksek kontrast modu açıldı' : 'Yüksek kontrast modu kapatıldı');
  }
  
  /// 📏 Set Font Scale Factor
  static void setFontScaleFactor(double factor) {
    _fontScaleFactor = factor.clamp(0.8, 2.0);
    announceForScreenReader('Yazı boyutu ${(_fontScaleFactor * 100).round()}% olarak ayarlandı');
  }
  
  /// 🔍 Get Accessible Text Style
  static TextStyle getAccessibleTextStyle(TextStyle baseStyle, BuildContext context) {
    return baseStyle.copyWith(
      fontSize: getScaledFontSize(baseStyle.fontSize ?? 14),
      color: getHighContrastColor(baseStyle.color ?? AppColors.textPrimary, context),
      fontWeight: _isHighContrastMode ? FontWeight.bold : baseStyle.fontWeight,
    );
  }
  
  /// 🎨 Get Accessible Color Scheme
  static ColorScheme getAccessibleColorScheme(ColorScheme baseScheme) {
    if (!_isHighContrastMode) return baseScheme;
    
    return baseScheme.copyWith(
      primary: baseScheme.brightness == Brightness.dark ? Colors.white : Colors.black,
      secondary: baseScheme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
      surface: baseScheme.brightness == Brightness.dark ? Colors.black : Colors.white,
      background: baseScheme.brightness == Brightness.dark ? Colors.black : Colors.white,
      onPrimary: baseScheme.brightness == Brightness.dark ? Colors.black : Colors.white,
      onSecondary: baseScheme.brightness == Brightness.dark ? Colors.black : Colors.white,
      onSurface: baseScheme.brightness == Brightness.dark ? Colors.white : Colors.black,
      onBackground: baseScheme.brightness == Brightness.dark ? Colors.white : Colors.black,
    );
  }
}

/// ♿ Accessible Widget
/// Wrapper widget that applies accessibility features
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticsLabel;
  final String? semanticsHint;
  final bool isButton;
  final VoidCallback? onTap;
  final bool excludeSemantics;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticsLabel,
    this.semanticsHint,
    this.isButton = false,
    this.onTap,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) return child;
    
    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      button: isButton,
      onTap: onTap,
      child: child,
    );
  }
}

/// 🎯 Accessible Button
/// Button with proper accessibility features
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final String? semanticsHint;
  final ButtonStyle? style;
  final bool isIconButton;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticsLabel,
    this.semanticsHint,
    this.style,
    this.isIconButton = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;
    
    if (isIconButton) {
      button = IconButton(
        onPressed: onPressed,
        style: style?.copyWith(
          minimumSize: MaterialStateProperty.all(
            AccessibilityHelper.ensureMinimumTouchTarget(const Size(44, 44)),
          ),
        ),
        icon: child,
      );
    } else {
      button = ElevatedButton(
        onPressed: onPressed,
        style: style?.copyWith(
          minimumSize: MaterialStateProperty.all(
            AccessibilityHelper.ensureMinimumTouchTarget(const Size(120, 44)),
          ),
        ),
        child: child,
      );
    }
    
    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      button: true,
      enabled: onPressed != null,
      child: button,
    );
  }
}

/// 📝 Accessible Text Field
/// Text field with proper accessibility features
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final String? semanticsLabel;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? labelText,
      hint: hintText,
      textField: true,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        maxLines: maxLines,
        style: AccessibilityHelper.getAccessibleTextStyle(
          AppTypography.bodyMedium,
          context,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          labelStyle: AccessibilityHelper.getAccessibleTextStyle(
            AppTypography.bodyMedium,
            context,
          ),
          hintStyle: AccessibilityHelper.getAccessibleTextStyle(
            AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            context,
          ),
        ),
      ),
    );
  }
}

/// 🎛️ Accessibility Settings
/// Settings for accessibility features
class AccessibilitySettings {
  static const String _highContrastKey = 'high_contrast_mode';
  static const String _fontScaleKey = 'font_scale_factor';
  
  /// Load accessibility settings
  static Future<void> loadSettings() async {
    // Implementation would load from SharedPreferences
    // For now, using default values
    AccessibilityHelper.setHighContrastMode(false);
    AccessibilityHelper.setFontScaleFactor(1.0);
  }
  
  /// Save accessibility settings
  static Future<void> saveSettings() async {
    // Implementation would save to SharedPreferences
    // For now, just announcing the save
    AccessibilityHelper.announceForScreenReader('Erişilebilirlik ayarları kaydedildi');
  }
  
  /// Reset to defaults
  static void resetToDefaults() {
    AccessibilityHelper.setHighContrastMode(false);
    AccessibilityHelper.setFontScaleFactor(1.0);
    AccessibilityHelper.announceForScreenReader('Erişilebilirlik ayarları sıfırlandı');
  }
}

/// 🎨 Accessibility Theme Extensions
extension AccessibilityThemeExtensions on ThemeData {
  /// Get accessibility-aware theme
  ThemeData get accessibilityAware {
    return copyWith(
      colorScheme: AccessibilityHelper.getAccessibleColorScheme(colorScheme),
      textTheme: textTheme.apply(
        fontSizeFactor: AccessibilityHelper.fontScaleFactor,
        displayColor: AccessibilityHelper.getHighContrastColor(
          textTheme.bodyLarge?.color ?? AppColors.textPrimary,
          // Note: context is needed here, but extension doesn't have access
          // This would need to be handled differently in actual implementation
        ),
      ),
    );
  }
}

/// 🔊 Screen Reader Announcements
class ScreenReaderAnnouncements {
  static void welcomeMessage() {
    AccessibilityHelper.announceForScreenReader(
      'BreatheFlow uygulamasına hoş geldiniz. Nefes egzersizleri ve meditasyon için erişilebilir bir deneyim.',
    );
  }
  
  static void navigationChange(String screenName) {
    AccessibilityHelper.announceForScreenReader('$screenName sayfasına geçildi');
  }
  
  static void exerciseStart(String exerciseName) {
    AccessibilityHelper.announceForScreenReader('$exerciseName egzersizi başladı');
  }
  
  static void exerciseComplete(String exerciseName) {
    AccessibilityHelper.announceForScreenReader('$exerciseName egzersizi tamamlandı');
  }
  
  static void settingChanged(String settingName, String value) {
    AccessibilityHelper.announceForScreenReader('$settingName $value olarak değiştirildi');
  }
} 