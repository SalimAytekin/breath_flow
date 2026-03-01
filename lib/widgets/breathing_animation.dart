import 'dart:math' as math;
import 'package:flutter/material.dart';
// vibration paketi kaldırıldı — egzersiz sırasında dikkat dağıtıcı
import '../models/breathing_exercise.dart';
import '../providers/breathing_provider.dart';

class BreathingAnimation extends StatefulWidget {
  final BreathingProvider provider;

  const BreathingAnimation({super.key, required this.provider});

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  BreathingStepType? _lastStep;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    
    // Hold sırasında hafif pulse efekti
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Sürekli glow animasyonu
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    widget.provider.addListener(_updateAnimation);
    _updateAnimation();
  }

  @override
  void dispose() {
    widget.provider.removeListener(_updateAnimation);
    _controller.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    final provider = widget.provider;
    if (provider.isCountingDown) {
      _controller.stop();
      _pulseController.stop();
      if (mounted) setState(() {});
      return;
    }

    final currentStep = provider.currentStep;
    
    if (currentStep == null) return;

    if (currentStep.type != _lastStep) {
      _lastStep = currentStep.type;
      _controller.duration = Duration(seconds: currentStep.duration);

      switch (currentStep.type) {
        case BreathingStepType.inhale:
          _pulseController.stop();
          _controller.forward(from: 0.0);
          break;
        case BreathingStepType.exhale:
          _pulseController.stop();
          _controller.forward(from: 0.0);
          break;
        case BreathingStepType.hold:
        case BreathingStepType.holdAfterExhale:
          _controller.stop();
          _pulseController.repeat(reverse: true);
          break;
      }
    }
    
    if (widget.provider.isPaused) {
      _controller.stop();
      _pulseController.stop();
    } else if (!_controller.isAnimating && 
               (currentStep.type == BreathingStepType.inhale || 
                currentStep.type == BreathingStepType.exhale)) {
      _controller.forward();
    }
    
    if (mounted) setState(() {});
  }

  // Nefes fazına göre halka rengi
  Color _getRingColor(BreathingStepType type) {
    switch (type) {
      case BreathingStepType.inhale:
        return const Color(0xFF4ECDC4); // Teal/Cyan
      case BreathingStepType.hold:
        return const Color(0xFFE8A838); // Amber/Gold
      case BreathingStepType.exhale:
        return const Color(0xFF667EEA); // Soft blue/indigo
      case BreathingStepType.holdAfterExhale:
        return const Color(0xFF764BA2); // Deep purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final isCountingDown = provider.isCountingDown;
    final currentStep = provider.currentStep;
    final countdown = provider.countdown;
    final preCountdown = provider.preCountdown;
    
    if (currentStep == null && !isCountingDown) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _pulseController, _glowController]),
      builder: (context, child) {
        double animationValue = 0.0;
        double pulseValue = 0.0;
        Color ringColor = const Color(0xFF4ECDC4); // Default Teal/Cyan
        
        if (!isCountingDown && currentStep != null) {
          switch (currentStep.type) {
            case BreathingStepType.inhale:
              animationValue = _controller.value;
              break;
            case BreathingStepType.exhale:
              animationValue = 1.0 - _controller.value;
              break;
            case BreathingStepType.hold:
              animationValue = 1.0;
              break;
            case BreathingStepType.holdAfterExhale:
              animationValue = 0.0;
              break;
          }
          animationValue = animationValue.clamp(0.0, 1.0);

          pulseValue = (currentStep.type == BreathingStepType.hold || 
                             currentStep.type == BreathingStepType.holdAfterExhale)
              ? _pulseController.value * 0.03
              : 0.0;
              
          ringColor = _getRingColor(currentStep.type);
        }

        final glowValue = _glowController.value;

        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;
        
        // Halka boyutları
        final minRingSize = isSmallScreen ? 160.0 : 200.0;
        final maxRingSize = isSmallScreen ? 260.0 : 300.0;
        final currentSize = minRingSize + (animationValue * (maxRingSize - minRingSize)) + (pulseValue * maxRingSize);

        // Session progress (dairesel ring)
        final sessionProgress = provider.totalCycles > 0
            ? provider.completedCycles / provider.totalCycles
            : 0.0;

        return SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Layer 1: Dış glow halo
              Container(
                width: currentSize + 60,
                height: currentSize + 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ringColor.withOpacity(0.08 + glowValue * 0.06),
                      blurRadius: 60 + (animationValue * 30),
                      spreadRadius: 20 + (animationValue * 15),
                    ),
                  ],
                ),
              ),

              // Layer 2: Session progress ring (gold/amber)
              SizedBox(
                width: currentSize + 24,
                height: currentSize + 24,
                child: CustomPaint(
                  painter: _ProgressRingPainter(
                    progress: sessionProgress,
                    color: const Color(0xFFE8A838),
                    strokeWidth: 3.5,
                    backgroundColor: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),

              // Layer 3: Ana parlayan halka (ring stroke)
              Container(
                width: currentSize,
                height: currentSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor.withOpacity(0.8 + glowValue * 0.2),
                    width: isSmallScreen ? 2.5 : 3.0,
                  ),
                  boxShadow: [
                    // İç glow
                    BoxShadow(
                      color: ringColor.withOpacity(0.3 + glowValue * 0.15),
                      blurRadius: 20 + (animationValue * 15),
                      spreadRadius: -2,
                    ),
                    // Dış glow
                    BoxShadow(
                      color: ringColor.withOpacity(0.15 + glowValue * 0.1),
                      blurRadius: 35 + (animationValue * 20),
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

              // Layer 4: İç soft gradient fill
              Container(
                width: currentSize - 8,
                height: currentSize - 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ringColor.withOpacity(0.06 + animationValue * 0.04),
                      ringColor.withOpacity(0.02),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Layer 5: Text'ler — halkanın içinde
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Yönlendirme metni
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      isCountingDown ? "" : currentStep!.instruction,
                      key: ValueKey(isCountingDown ? "countdown" : currentStep!.instruction),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                        decoration: TextDecoration.none,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 8),
                  // Countdown sayısı
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Text(
                      isCountingDown ? '$preCountdown' : '$countdown',
                      key: ValueKey(isCountingDown ? 'pre_$preCountdown' : 'count_$countdown'),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 44 : 52,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Dairesel progress ring painter
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Arka plan halkası
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress halkası
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Üstten başla
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}