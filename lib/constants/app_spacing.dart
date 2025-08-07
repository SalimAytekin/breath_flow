import 'package:flutter/material.dart';

/// 📐 Professional Spacing System
/// 8pt Grid System - Industry standard spacing
class AppSpacing {
  AppSpacing._();

  // 🔢 BASE SPACING SCALE (8pt Grid)
  static const double tiny = 4.0;        // 0.5x
  static const double small = 8.0;       // 1x - Base unit
  static const double medium = 12.0;     // 1.5x
  static const double large = 16.0;      // 2x
  static const double xLarge = 24.0;     // 3x
  static const double xxLarge = 32.0;    // 4x
  static const double huge = 48.0;       // 6x
  static const double massive = 64.0;    // 8x

  // YENİ İSİMLER (backward compatibility için eskiler de korundu)
  /// 4.0
  static const double xsmall = tiny;

  /// 16.0 - Ana orta boşluk
  static const double mediumNew = large;

  /// 24.0 - Büyük boşluk
  static const double largeNew = xLarge;

  /// 32.0 - Çok büyük boşluk
  static const double xlarge = xxLarge;

  /// 48.0 - En büyük boşluk
  static const double xxlarge = huge;
  
  // 📱 COMPONENT SPECIFIC SPACING
  static const double cardPadding = medium;
  static const double sectionSpacing = xLarge;
  static const double screenPadding = large;
  
  // 🎯 SEMANTIC SPACING
  static const double betweenSections = xLarge;
  static const double betweenItems = medium;
  static const double betweenElements = small;
  static const double insideCard = medium;
  
  // 🎴 CARD SPACING
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(20.0);  // 2.5x
  static const EdgeInsets cardPaddingSymmetric = EdgeInsets.symmetric(
    horizontal: 20.0,  // 2.5x
    vertical: 16.0,    // 2x
  );
  
  // 📄 PAGE SPACING
  static const EdgeInsets pagePadding = EdgeInsets.all(16.0);     // 2x
  static const EdgeInsets pageMargin = EdgeInsets.symmetric(
    horizontal: 16.0,  // 2x
    vertical: 8.0,     // 1x
  );
  
  // 📋 LIST SPACING
  static const EdgeInsets listPadding = EdgeInsets.symmetric(
    horizontal: 16.0,  // 2x
    vertical: 8.0,     // 1x
  );
  
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,  // 2x
    vertical: 12.0,    // 1.5x
  );
  
  // 🎯 NAVIGATION SPACING
  static const double navHeight = 80.0;          // 10x
  static const double navPadding = 16.0;         // 2x
  static const double navIconSize = 24.0;        // 3x
  
  // 🏷️ HEADER SPACING
  static const double headerHeight = 56.0;       // 7x
  static const EdgeInsets headerPadding = EdgeInsets.symmetric(
    horizontal: 16.0,  // 2x
    vertical: 8.0,     // 1x
  );
  
  // 🎨 BORDER RADIUS SYSTEM
  static const double radiusNone = 0.0;
  static const double radiusSmall = 8.0;         // 1x
  static const double radiusMedium = 12.0;       // 1.5x
  static const double radiusLarge = 16.0;        // 2x
  static const double radiusXLarge = 20.0;       // 2.5x
  static const double radiusRound = 999.0;       // Fully rounded
  
  // 🎭 ELEVATION SYSTEM
  static const double elevationNone = 0.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 12.0;
  static const double elevationHuge = 16.0;
  
  // 📏 ICON SIZES
  static const double iconSmall = 16.0;          // 2x
  static const double iconMedium = 20.0;         // 2.5x
  static const double iconLarge = 24.0;          // 3x
  static const double iconXLarge = 32.0;         // 4x
  static const double iconHuge = 48.0;           // 6x
  
  // 🎪 ANIMATION DURATIONS
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 250);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationSlower = Duration(milliseconds: 800);
  
  // 🌊 CURVES
  static const Curve easeOutQuart = Curves.easeOutQuart;
  static const Curve easeInOutQuart = Curves.easeInOutQuart;
  static const Curve easeOutBack = Curves.easeOutBack;

  // 🔘 BUTTON SPACING
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,  // 3x
    vertical: 16.0,    // 2x
  );
  
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: 16.0,  // 2x
    vertical: 12.0,    // 1.5x
  );
  
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: 32.0,  // 4x
    vertical: 20.0,    // 2.5x
  );
  
  // 📝 INPUT SPACING
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 16.0,  // 2x
    vertical: 14.0,    // 1.75x
  );
} 