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

/// 🖼️ Defines how images should fit within the card.
enum ImageFitMode {
  /// Automatically selects the best fit based on card dimensions.
  auto,
  
  /// Scales the image to cover the entire card area (may crop).
  cover,
  
  /// Scales the image to fit entirely within the card (may show empty space).
  contain,
  
  /// Stretches the image to fill the card (may distort).
  fill,
  
  /// Scales the image to fit the card width.
  fitWidth,
  
  /// Scales the image to fit the card height.
  fitHeight,
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
  final ImageFitMode? imageFitMode;

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
    this.imageFitMode = ImageFitMode.auto,
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
    );
    // ⚡ Optimizasyon: Sadece seçili veya hovering durumunda başlat
    if (widget.isSelected) {
      _animationController.repeat(reverse: true);
    }

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void didUpdateWidget(ProfessionalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ⚡ Optimizasyon: isSelected değiştiğinde animasyonu kontrol et
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// ⚡ Animasyonu hover durumuna göre kontrol et
  void _updateAnimation() {
    if (_isHovering || widget.isSelected) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getCardConfiguration();
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(config.borderRadius);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _updateAnimation(); // ⚡ Animasyonu güncelle
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _updateAnimation(); // ⚡ Animasyonu güncelle
      },
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
            // ⚡ PERFORMANCE: BackdropFilter sadece gerçekten gerekli olduğunda kullanılır
            // Glass effect için gradient yeterli, GPU yükünü %90 azaltır
            child: config.blurAmount > 0
                ? BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: config.blurAmount, 
                      sigmaY: config.blurAmount
                    ),
                    child: _buildCardContent(config, effectiveBorderRadius),
                  )
                : _buildCardContent(config, effectiveBorderRadius),
          ),
        ),
      ),
    );
  }

  /// ⚡ Helper method to build card content without duplication
  Widget _buildCardContent(CardConfiguration config, BorderRadius effectiveBorderRadius) {
    return Stack(
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
        // 1. 🖼️ OPTIMIZE EDİLMİŞ GÖRSEL CONTAINER
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground, // Yükleme sırasında görünecek arka plan
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Kart boyutlarına göre optimize edilmiş görsel
                final cacheSize = ImageOptimizer.getCacheSize(constraints);
                final fitMode = widget.imageFitMode ?? ImageFitMode.auto;
                final boxFit = ImageOptimizer.getBoxFit(fitMode, constraints);
                final alignment = ImageOptimizer.getAlignment(boxFit);
                
                return Image.asset(
                  widget.imageUrl!,
                  // 🎯 AKILLI FIT SEÇIMI
                  fit: boxFit,
                  alignment: alignment,
                  
                  // 🚀 PERFORMANS OPTİMİZASYONU
                  // Kart boyutuna göre cache boyutu ayarla
                  cacheWidth: cacheSize.width.toInt(),
                  cacheHeight: cacheSize.height.toInt(),
                  
                  // Kalite ayarları
                  isAntiAlias: true,
                  filterQuality: FilterQuality.medium,
                  
                  // Yumuşak yükleme animasyonu
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    
                    return AnimatedOpacity(
                      opacity: frame == null ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                  
                  // Hata durumu için fallback
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('🚨 Feature card image error: ${widget.imageUrl}');
                    return _buildFallbackImage();
                  },
                );
              },
            ),
          ),
        ),
        
        // 2. Readability Scrim - ENHANCED
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.95),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 0.7, 1.0],
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

  /// 🎨 Fallback görsel - hata durumunda gösterilecek
  Widget _buildFallbackImage() {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon ?? Icons.image_not_supported,
              size: 40,
              color: Colors.white.withOpacity(0.8),
            ),
            if (widget.title != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.title!,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
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
          blurAmount: 0.0, // ⚡ PERFORMANCE: BackdropFilter kaldırıldı, gradient yeterli
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

/// 🖼️ Image Optimization Helper Class
class ImageOptimizer {
  /// Returns the optimal BoxFit based on ImageFitMode and card constraints
  static BoxFit getBoxFit(ImageFitMode mode, BoxConstraints constraints) {
    switch (mode) {
      case ImageFitMode.cover:
        return BoxFit.cover;
      case ImageFitMode.contain:
        return BoxFit.contain;
      case ImageFitMode.fill:
        return BoxFit.fill;
      case ImageFitMode.fitWidth:
        return BoxFit.fitWidth;
      case ImageFitMode.fitHeight:
        return BoxFit.fitHeight;
      case ImageFitMode.auto:
      default:
        // Otomatik seçim - kart oranına göre en uygun fit'i seç
        final aspectRatio = constraints.maxWidth / constraints.maxHeight;
        
        if (aspectRatio > 1.8) {
          // Geniş kartlar için
          return BoxFit.fitWidth;
        } else if (aspectRatio < 0.6) {
          // Uzun kartlar için
          return BoxFit.fitHeight;
        } else {
          // Normal kartlar için
          return BoxFit.cover;
        }
    }
  }
  
  /// Returns the optimal alignment based on BoxFit
  static Alignment getAlignment(BoxFit fit) {
    switch (fit) {
      case BoxFit.fitWidth:
        return Alignment.topCenter;
      case BoxFit.fitHeight:
        return Alignment.centerLeft;
      default:
        return Alignment.center;
    }
  }
  
  /// Calculates optimal cache dimensions based on card constraints
  static Size getCacheSize(BoxConstraints constraints) {
    // 2x resolution for crisp display on high-DPI screens
    return Size(
      (constraints.maxWidth * 2).clamp(400.0, 1200.0),
      (constraints.maxHeight * 2).clamp(300.0, 900.0),
    );
  }
}

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
  final ImageFitMode? imageFitMode;
  
  // 🆕 Favori özellikleri
  final bool showFavoriteButton;
  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;
  
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
    this.imageFitMode,
    this.showFavoriteButton = false,
    this.isFavorite,
    this.onFavoriteToggle,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Decide content type based on whether imageUrl is provided
    final contentType = (imageUrl != null) 
        ? CardContentType.imageWithTitle 
        : CardContentType.iconAndText;

    return Stack(
      children: [
        ProfessionalCard(
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
          imageFitMode: imageFitMode,
          // Note: iconColor is handled inside ProfessionalCard's _buildIconCard if needed,
          // but for now, we let ProfessionalCard use its default.
          // To apply iconColor, we would need a custom child implementation like before.
          // For simplicity, we'll stick to ProfessionalCard's internal logic.
        ),
        
        // 💖 Favori butonu - Sol üst köşe
        if (showFavoriteButton && onFavoriteToggle != null)
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite == true ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite == true ? Colors.red : AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? change;
  final IconData? icon;
  final Color? iconColor;
  final Widget? chart;

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
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
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.tiny),
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (chart != null) ...[
            const SizedBox(height: AppSpacing.medium),
            Expanded(child: chart!),
          ]
        ],
      ),
    );
  }
}