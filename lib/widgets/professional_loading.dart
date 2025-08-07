import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

/// 🔄 Professional Loading Widget
/// Beautiful loading states with Deep Night Serenity theme
class ProfessionalLoading extends StatefulWidget {
  final LoadingType type;
  final String? message;
  final Color? color;
  final double? size;
  final bool showMessage;

  const ProfessionalLoading({
    super.key,
    this.type = LoadingType.spinner,
    this.message,
    this.color,
    this.size,
    this.showMessage = true,
  });

  @override
  State<ProfessionalLoading> createState() => _ProfessionalLoadingState();
}

class _ProfessionalLoadingState extends State<ProfessionalLoading>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  
  late Animation<double> _spinAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _spinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimations();
  }

  void _startAnimations() {
    switch (widget.type) {
      case LoadingType.spinner:
        _spinController.repeat();
        break;
      case LoadingType.pulse:
        _pulseController.repeat(reverse: true);
        break;
      case LoadingType.wave:
        _waveController.repeat();
        break;
      case LoadingType.dots:
        _waveController.repeat();
        break;
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingWidget(),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: AppSpacing.large),
          Text(
            widget.message!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget() {
    final color = widget.color ?? AppColors.primaryAccent;
    final size = widget.size ?? 40.0;
    
    switch (widget.type) {
      case LoadingType.spinner:
        return _buildSpinner(color, size);
      case LoadingType.pulse:
        return _buildPulse(color, size);
      case LoadingType.wave:
        return _buildWave(color, size);
      case LoadingType.dots:
        return _buildDots(color, size);
    }
  }

  Widget _buildSpinner(Color color, double size) {
    return AnimatedBuilder(
      animation: _spinAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _spinAnimation.value * 2 * 3.14159,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: SweepGradient(
                colors: [
                  color.withOpacity(0.1),
                  color,
                  color.withOpacity(0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: BorderRadius.circular((size - 8) / 2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulse(Color color, double size) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  color,
                  color.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(size / 2),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWave(Color color, double size) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return SizedBox(
          width: size * 2,
          height: size,
          child: Stack(
            children: List.generate(3, (index) {
              final delay = index * 0.3;
              final animationValue = (_waveAnimation.value + delay) % 1.0;
              
              return Positioned.fill(
                child: Opacity(
                  opacity: 1.0 - animationValue,
                  child: Transform.scale(
                    scale: animationValue,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: color.withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(size),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildDots(Color color, double size) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_waveAnimation.value + delay) % 1.0;
            final scale = 0.5 + (0.5 * (1.0 - (animationValue - 0.5).abs() * 2));
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: size * 0.1),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: BoxDecoration(
                    color: color.withOpacity(scale),
                    borderRadius: BorderRadius.circular(size * 0.15),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

enum LoadingType {
  spinner,
  pulse,
  wave,
  dots,
}

/// 🎭 Loading Overlay
/// Full-screen loading overlay with blur effect
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final LoadingType loadingType;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.loadingType = LoadingType.spinner,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: AppColors.overlay,
              child: Center(
                child: Container(
                  padding: AppSpacing.cardPaddingAll,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowDark,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ProfessionalLoading(
                    type: loadingType,
                    message: message,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
} 