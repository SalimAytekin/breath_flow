import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// 🔘 Professional Button Widget
/// Standardized button design matching Deep Night Serenity theme
class ProfessionalButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType buttonType;
  final ButtonSize buttonSize;
  final IconData? icon;
  final bool iconOnRight;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final bool isPulsing;
  
  const ProfessionalButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.buttonType = ButtonType.primary,
    this.buttonSize = ButtonSize.medium,
    this.icon,
    this.iconOnRight = false,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.width,
    this.height,
    this.isPulsing = false,
  }) : super(key: key);
  
  @override
  State<ProfessionalButton> createState() => _ProfessionalButtonState();
}

class _ProfessionalButtonState extends State<ProfessionalButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _loadingController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for press feedback
    _scaleController = AnimationController(
      duration: AppSpacing.animationFast,
      vsync: this,
    );
    
    // Shimmer animation for hover effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Pulse animation for gentle, continuous feedback
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppSpacing.easeOutQuart,
    ));
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isLoading) {
      _loadingController.repeat();
    }
    
    if (widget.isPulsing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ProfessionalButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
      }
    }
    
    if (widget.isPulsing != oldWidget.isPulsing) {
      if (widget.isPulsing) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _loadingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isEnabled || widget.isLoading) return;
    
    setState(() => _isPressed = true);
    _scaleController.forward();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isEnabled || widget.isLoading) return;
    
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _onHoverEnter(PointerEnterEvent event) {
    if (!widget.isEnabled || widget.isLoading) return;
    
    setState(() => _isHovered = true);
    _shimmerController.forward();
  }

  void _onHoverExit(PointerExitEvent event) {
    setState(() => _isHovered = false);
    _shimmerController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getButtonConfiguration();
    final isDisabled = !widget.isEnabled || widget.isLoading;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _shimmerAnimation,
        _rotationAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: _onHoverEnter,
              onExit: _onHoverExit,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onTap: isDisabled ? null : widget.onPressed,
                child: AnimatedContainer(
                  duration: AppSpacing.animationMedium,
                  curve: AppSpacing.easeOutQuart,
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    gradient: isDisabled ? null : widget.gradient,
                    color: isDisabled ? AppColors.textDisabled : config.backgroundColor,
                    borderRadius: BorderRadius.circular(config.borderRadius),
                    border: config.borderColor != null 
                        ? Border.all(
                            color: isDisabled 
                                ? AppColors.textDisabled 
                                : config.borderColor!,
                            width: 1.5,
                          )
                        : null,
                    boxShadow: isDisabled ? null : [
                      BoxShadow(
                        color: (config.shadowColor ?? AppColors.primaryAccent)
                            .withOpacity(_isHovered ? 0.4 : 0.2),
                        blurRadius: _isHovered ? 20 : 12,
                        offset: Offset(0, _isHovered ? 8 : 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shimmer effect on hover
                      if (_isHovered && !isDisabled)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(config.borderRadius),
                            child: AnimatedBuilder(
                              animation: _shimmerAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    _shimmerAnimation.value * 200,
                                    0,
                                  ),
                                  child: Container(
                                    width: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.2),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      
                      // Button content
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: config.horizontalPadding,
                          vertical: config.verticalPadding,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.isLoading) ...[
                              AnimatedBuilder(
                                animation: _rotationAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _rotationAnimation.value * 2 * 3.14159,
                                    child: SizedBox(
                                      width: config.iconSize,
                                      height: config.iconSize,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          config.textColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: AppSpacing.small),
                            ] else if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: config.iconSize,
                                color: isDisabled 
                                    ? AppColors.textTertiary 
                                    : config.textColor,
                              ),
                              SizedBox(width: config.iconSpacing),
                            ],
                            
                            Flexible(
                              child: Text(
                                widget.isLoading ? 'Yükleniyor...' : widget.text,
                                style: config.textStyle.copyWith(
                                  color: isDisabled 
                                      ? AppColors.textTertiary 
                                      : config.textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ButtonConfiguration _getButtonConfiguration() {
    switch (widget.buttonType) {
      case ButtonType.primary:
        return ButtonConfiguration(
          backgroundColor: null,
          gradient: AppColors.primaryGradient,
          textColor: AppColors.textPrimary,
          borderColor: null,
          shadowColor: AppColors.primaryAccent,
          height: _getHeight(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          borderRadius: AppSpacing.radiusMedium,
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
          iconSpacing: AppSpacing.small,
        );
      
      case ButtonType.secondary:
        return ButtonConfiguration(
          backgroundColor: AppColors.surfaceElevated,
          gradient: null,
          textColor: AppColors.textPrimary,
          borderColor: AppColors.border,
          shadowColor: AppColors.surfaceElevated,
          height: _getHeight(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          borderRadius: AppSpacing.radiusMedium,
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
          iconSpacing: AppSpacing.small,
        );
      
      case ButtonType.ghost:
        return ButtonConfiguration(
          backgroundColor: Colors.transparent,
          gradient: null,
          textColor: AppColors.primaryAccent,
          borderColor: AppColors.primaryAccent,
          shadowColor: null,
          height: _getHeight(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          borderRadius: AppSpacing.radiusMedium,
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
          iconSpacing: AppSpacing.small,
        );
      
      case ButtonType.gradient:
        return ButtonConfiguration(
          backgroundColor: null,
          gradient: AppColors.focusGradient,
          textColor: AppColors.textPrimary,
          borderColor: null,
          shadowColor: AppColors.focus,
          height: _getHeight(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          borderRadius: AppSpacing.radiusMedium,
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
          iconSpacing: AppSpacing.small,
        );
      
      case ButtonType.mood:
        return ButtonConfiguration(
          backgroundColor: null,
          gradient: AppColors.relaxationGradient,
          textColor: AppColors.textPrimary,
          borderColor: null,
          shadowColor: AppColors.relaxation,
          height: _getHeight(),
          horizontalPadding: _getHorizontalPadding(),
          verticalPadding: _getVerticalPadding(),
          borderRadius: AppSpacing.radiusLarge,
          textStyle: _getTextStyle(),
          iconSize: _getIconSize(),
          iconSpacing: AppSpacing.small,
        );
    }
  }

  double _getHeight() {
    switch (widget.buttonSize) {
      case ButtonSize.small:
        return 36.0;
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.buttonSize) {
      case ButtonSize.small:
        return AppSpacing.medium;
      case ButtonSize.medium:
        return AppSpacing.large;
      case ButtonSize.large:
        return AppSpacing.xLarge;
    }
  }

  double _getVerticalPadding() {
    switch (widget.buttonSize) {
      case ButtonSize.small:
        return AppSpacing.small;
      case ButtonSize.medium:
        return AppSpacing.medium;
      case ButtonSize.large:
        return AppSpacing.large;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.buttonSize) {
      case ButtonSize.small:
        return AppTypography.labelMedium;
      case ButtonSize.medium:
        return AppTypography.labelLarge;
      case ButtonSize.large:
        return AppTypography.headlineSmall;
    }
  }

  double _getIconSize() {
    switch (widget.buttonSize) {
      case ButtonSize.small:
        return AppSpacing.iconSmall;
      case ButtonSize.medium:
        return AppSpacing.iconMedium;
      case ButtonSize.large:
        return AppSpacing.iconLarge;
    }
  }
}

class ButtonConfiguration {
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color textColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final TextStyle textStyle;
  final double iconSize;
  final double iconSpacing;

  const ButtonConfiguration({
    required this.backgroundColor,
    required this.gradient,
    required this.textColor,
    required this.borderColor,
    required this.shadowColor,
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.borderRadius,
    required this.textStyle,
    required this.iconSize,
    required this.iconSpacing,
  });
}

/// 🎭 Button Type Enumeration
enum ButtonType {
  primary,
  secondary,
  ghost,
  gradient,
  mood,
}

/// 📏 Button Size Enumeration
enum ButtonSize {
  small,
  medium,
  large,
}

/// 🌈 Gradient Button Widget
/// Special button with gradient background
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final ButtonSize buttonSize;
  final IconData? icon;
  final bool iconOnRight;
  final bool isLoading;
  final bool isEnabled;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final bool isPulsing;
  
  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    required this.gradient,
    this.buttonSize = ButtonSize.medium,
    this.icon,
    this.iconOnRight = false,
    this.isLoading = false,
    this.isEnabled = true,
    this.foregroundColor,
    this.width,
    this.height,
    this.isPulsing = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ProfessionalButton(
      text: text,
      onPressed: onPressed,
      buttonType: ButtonType.gradient,
      buttonSize: buttonSize,
      icon: icon,
      width: width,
      height: height,
      isPulsing: isPulsing,
    );
  }
}

/// 🎯 Action Button Widget
/// Specialized button for main actions
class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  
  const ActionButton({
    Key? key,
    required this.text,
    this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ProfessionalButton(
      text: text,
      onPressed: onPressed,
      buttonType: ButtonType.primary,
      buttonSize: ButtonSize.large,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isLoading: isLoading,
      isEnabled: isEnabled,
      width: width,
    );
  }
}

/// 🎵 Mood Button Widget
/// Button with mood-specific styling
class MoodButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData icon;
  final MoodType moodType;
  final bool isSelected;
  final bool isEnabled;
  
  const MoodButton({
    Key? key,
    required this.text,
    this.onPressed,
    required this.icon,
    required this.moodType,
    this.isSelected = false,
    this.isEnabled = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final moodColors = _getMoodColors();
    
    return ProfessionalButton(
      text: text,
      onPressed: onPressed,
      buttonType: isSelected ? ButtonType.mood : ButtonType.secondary,
      buttonSize: ButtonSize.medium,
      icon: icon,
      backgroundColor: isSelected ? moodColors.color : null,
      foregroundColor: isSelected ? AppColors.textPrimary : moodColors.color,
      isEnabled: isEnabled,
    );
  }
  
  ({Color color, Gradient gradient}) _getMoodColors() {
    switch (moodType) {
      case MoodType.relaxation:
        return (
          color: AppColors.relaxation,
          gradient: AppColors.relaxationGradient,
        );
      case MoodType.focus:
        return (
          color: AppColors.focus,
          gradient: AppColors.focusGradient,
        );
      case MoodType.sleep:
        return (
          color: AppColors.sleep,
          gradient: AppColors.sleepGradient,
        );
      case MoodType.energy:
        return (
          color: AppColors.energy,
          gradient: AppColors.energyGradient,
        );
    }
  }
}

/// 🎭 Mood Type Enumeration
enum MoodType {
  relaxation,
  focus,
  sleep,
  energy,
}

/// 🔄 Toggle Button Widget
/// Button that can be toggled on/off
class ToggleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSelected;
  final bool isEnabled;
  final Color? selectedColor;
  final Color? unselectedColor;
  
  const ToggleButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isSelected = false,
    this.isEnabled = true,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ProfessionalButton(
      text: text,
      onPressed: onPressed,
      buttonType: isSelected ? ButtonType.primary : ButtonType.secondary,
      buttonSize: ButtonSize.medium,
      icon: icon,
      backgroundColor: isSelected 
          ? (selectedColor ?? AppColors.primaryAccent)
          : (unselectedColor ?? AppColors.glassLight),
      foregroundColor: isSelected 
          ? AppColors.textPrimary 
          : AppColors.textSecondary,
      isEnabled: isEnabled,
    );
  }
} 