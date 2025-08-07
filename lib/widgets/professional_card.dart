import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// -----------------------------------------------------------------
/// ✨ ENUMS
/// -----------------------------------------------------------------

/// 🎭 Defines the base style of the card (e.g., standard, glass, gradient).
enum CardType {
  standard,
  elevated,
  glass,
  gradient,
  mood,
}

/// 🎨 Defines the visual style of the card's content.
enum CardContentType {
  /// Displays a centered icon and text, suitable for navigation.
  iconAndText,

  /// Displays a background image with a title overlay, suitable for media.
  imageWithTitle,
}

/// -----------------------------------------------------------------
/// ✨ MASTER WIDGET
/// -----------------------------------------------------------------

/// 💎 Professional Card Widget
/// A master card widget that adapts its style and content based on CardType and CardContentType.
class ProfessionalCard extends StatefulWidget {
  // --- Core Properties ---
  final CardType cardType;
  final CardContentType contentType;
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  
  // --- Styling ---
  final Color? backgroundColor;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  
  // --- Content Properties (for different content types) ---
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final String? imageUrl;
  final bool isPro;

  const ProfessionalCard({
    super.key,
    this.cardType = CardType.standard,
    this.contentType = CardContentType.iconAndText,
    this.child,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.backgroundColor,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.title,
    this.subtitle,
    this.icon,
    this.imageUrl,
    this.isPro = false,
  });

  @override
  State<ProfessionalCard> createState() => _ProfessionalCardState();
}

class _ProfessionalCardState extends State<ProfessionalCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isHovering = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getCardConfiguration();
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(config.borderRadius);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: AppSpacing.animationMedium,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: effectiveBorderRadius,
            boxShadow: [
              if (widget.isSelected || _isHovering)
                BoxShadow(
                  color: config.shadowColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: -5,
                )
              else
                BoxShadow(
                  color: config.shadowColor.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: -2,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: config.blurAmount, 
                sigmaY: config.blurAmount
              ),
              child: Stack(
                children: [
                  // Base Container for background and border
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: config.backgroundColor,
                        gradient: config.gradient,
                        borderRadius: effectiveBorderRadius,
                        border: Border.all(
                          color: config.borderColor ?? Colors.transparent,
                          width: config.borderWidth,
                        ),
                      ),
                    ),
                  ),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.contentType) {
      case CardContentType.imageWithTitle:
        return _buildImageCard();
      case CardContentType.iconAndText:
      default:
        return _buildIconCard();
    }
  }

  Widget _buildImageCard() {
    if (widget.imageUrl == null) {
      return _buildIconCard(); // Fallback to icon card if no image
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background Image - OPTIMIZED 🚀
        Image.asset(
          widget.imageUrl!,
          fit: BoxFit.cover,
          // 🚀 PERFORMANCE OPTIMIZATIONS
          cacheWidth: 400,  // Smaller cache for feature cards
          cacheHeight: 300, // Optimized for card dimensions
          isAntiAlias: true,
          filterQuality: FilterQuality.medium,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            // 🎭 Smooth loading animation
            if (wasSynchronouslyLoaded) return child;
            
            return AnimatedOpacity(
              opacity: frame == null ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 400),
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('🚨 Feature card image error: ${widget.imageUrl}');
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAccent.withOpacity(0.3),
                    AppColors.primaryAccent.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  widget.icon ?? Icons.image_not_supported,
                  size: 40,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            );
          },
        ),
        
        // 2. Readability Scrim
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.0),
                Colors.black.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.4, 1.0],
            ),
          ),
        ),
        
        // 3. Aurora Glow Effect (Animated)
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryAccent.withOpacity(
                    (widget.isSelected || _isHovering) ? 0.7 * _glowAnimation.value : 0.0
                  ),
                  width: 2.0,
                ),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(_getCardConfiguration().borderRadius),
              ),
            );
          },
        ),

        // 4. Content (Title, Subtitle, Pro Badge)
        Positioned(
          bottom: AppSpacing.medium,
          left: AppSpacing.medium,
          right: AppSpacing.medium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title != null)
                Text(
                  widget.title!,
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: AppSpacing.tiny),
                Text(
                  widget.subtitle!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // 5. Pro Badge
        if (widget.isPro)
          Positioned(
            top: AppSpacing.small,
            right: AppSpacing.small,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.premium.withOpacity(0.8),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                'PRO',
                style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIconCard() {
    if (widget.child != null) {
      return Padding(
        padding: widget.padding ?? _getCardConfiguration().defaultPadding,
        child: widget.child,
      );
    }

    return Padding(
      padding: widget.padding ?? _getCardConfiguration().defaultPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.icon != null)
            Icon(widget.icon, size: AppSpacing.iconXLarge, color: AppColors.primaryAccent),
          if (widget.icon != null && widget.title != null)
            const SizedBox(height: AppSpacing.medium),
          if (widget.title != null)
            Text(
              widget.title!,
              textAlign: TextAlign.center,
              style: AppTypography.labelLarge,
            ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: AppSpacing.tiny),
            Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  CardConfiguration _getCardConfiguration() {
    switch (widget.cardType) {
      case CardType.standard:
        return CardConfiguration(
          backgroundColor: widget.backgroundColor ?? AppColors.cardBackground,
          borderColor: AppColors.border,
          borderRadius: AppSpacing.radiusMedium,
          shadowColor: AppColors.shadowLight,
          defaultPadding: widget.padding ?? AppSpacing.cardPaddingAll,
        );
      case CardType.elevated:
        return CardConfiguration(
          backgroundColor: widget.backgroundColor ?? AppColors.surfaceElevated,
          borderRadius: AppSpacing.radiusXLarge,
          shadowColor: AppColors.shadowMedium,
          defaultPadding: widget.padding ?? AppSpacing.cardPaddingAll,
        );
      case CardType.glass:
        return CardConfiguration(
          backgroundColor: AppColors.glassLight,
          borderColor: AppColors.glassBorder,
          borderRadius: AppSpacing.radiusLarge,
          shadowColor: AppColors.primaryAccent,
          defaultPadding: widget.padding ?? AppSpacing.cardPaddingAll,
          blurAmount: 5.0,
        );
      case CardType.gradient:
        return CardConfiguration(
          gradient: widget.gradient ?? AppColors.primaryGradient,
          borderRadius: AppSpacing.radiusLarge,
          shadowColor: AppColors.primaryAccent,
          defaultPadding: widget.padding ?? AppSpacing.cardPaddingAll,
        );
      case CardType.mood:
        return CardConfiguration(
          gradient: widget.gradient ?? AppColors.relaxationGradient,
          borderRadius: AppSpacing.radiusLarge,
          shadowColor: AppColors.relaxation,
          defaultPadding: widget.padding ?? AppSpacing.cardPaddingAll,
        );
    }
  }
}

/// -----------------------------------------------------------------
/// ✨ CONFIGURATION & SPECIALIZED WIDGETS
/// -----------------------------------------------------------------

class CardConfiguration {
  final Color backgroundColor;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color shadowColor;
  final double blurAmount;
  final EdgeInsetsGeometry defaultPadding;

  CardConfiguration({
    this.backgroundColor = AppColors.cardBackground,
    this.gradient,
    this.borderColor = AppColors.border,
    this.borderWidth = 1.0,
    this.borderRadius = AppSpacing.radiusMedium,
    this.shadowColor = AppColors.shadowLight,
    this.blurAmount = 0.0,
    this.defaultPadding = AppSpacing.cardPaddingAll,
  });
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isSelected;
  final CardType cardType;
  
  const FeatureCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.imageUrl,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.isSelected = false,
    this.cardType = CardType.standard,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Decide content type based on whether imageUrl is provided
    final contentType = (imageUrl != null) 
        ? CardContentType.imageWithTitle 
        : CardContentType.iconAndText;

    return ProfessionalCard(
      cardType: cardType,
      contentType: contentType,
      isSelected: isSelected,
      backgroundColor: backgroundColor,
      onTap: onTap,
      // Pass all relevant properties to ProfessionalCard
      title: title,
      subtitle: subtitle,
      icon: icon,
      imageUrl: imageUrl,
      // Note: iconColor is handled inside ProfessionalCard's _buildIconCard if needed,
      // but for now, we let ProfessionalCard use its default.
      // To apply iconColor, we would need a custom child implementation like before.
      // For simplicity, we'll stick to ProfessionalCard's internal logic.
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final IconData? icon;
  final Color? iconColor;
  final Widget? chart;

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    this.change,
    this.icon,
    this.iconColor,
    this.chart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfessionalCard(
      cardType: CardType.elevated,
      padding: AppSpacing.cardPaddingAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor ?? AppColors.textTertiary, size: AppSpacing.iconSmall),
                const SizedBox(width: AppSpacing.small),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(color: AppColors.textTertiary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.displaySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (change != null) ...[
                const SizedBox(width: AppSpacing.small),
                Text(
                  change!,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.success),
                ),
              ],
            ],
          ),
          if (chart != null) ...[
            const SizedBox(height: AppSpacing.medium),
            Expanded(child: chart!),
          ]
        ],
      ),
    );
  }
} 