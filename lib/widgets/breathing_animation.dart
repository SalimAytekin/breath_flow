import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../constants/app_colors.dart';
import '../models/breathing_exercise.dart';
import '../providers/breathing_provider.dart';
import '../constants/app_typography.dart';
import '../services/asset_manager.dart';
import 'package:lottie/lottie.dart';

class BreathingAnimation extends StatefulWidget {
  final BreathingProvider provider;

  const BreathingAnimation({super.key, required this.provider});

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  BreathingStepType? _lastStep;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Provider'ı dinleyerek animasyonu güncelle
    widget.provider.addListener(_updateAnimation);
    // İlk animasyon durumunu ayarla
    _updateAnimation();
  }

  @override
  void dispose() {
    widget.provider.removeListener(_updateAnimation);
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    final currentStep = widget.provider.currentStep;
    final stepProgress = widget.provider.stepProgress;
    
    if (currentStep == null) return;

    // Sadece yeni adıma geçildiğinde animasyonu yeniden başlat
    if (currentStep.type != _lastStep) {
      _lastStep = currentStep.type;
      _controller.duration = Duration(seconds: currentStep.duration);

      // Haptik geri bildirim
      switch (currentStep.type) {
        case BreathingStepType.inhale:
        case BreathingStepType.exhale:
          Vibration.vibrate(duration: 50);
          break;
        case BreathingStepType.hold:
        case BreathingStepType.holdAfterExhale:
          Vibration.vibrate(duration: 100);
          break;
      }

      switch (currentStep.type) {
        case BreathingStepType.inhale:
          _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          );
          _controller.forward(from: 0.0);
          break;
        case BreathingStepType.exhale:
          _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          );
          _controller.forward(from: 0.0);
          break;
        case BreathingStepType.hold:
        case BreathingStepType.holdAfterExhale:
          // Hold durumunda animasyonu durdur ve mevcut pozisyonda tut
          _controller.stop();
          break;
      }
    }
    
    // Pause durumunda animasyonu durdur
    if (widget.provider.isPaused) {
      _controller.stop();
    } else if (!_controller.isAnimating && 
               (currentStep.type == BreathingStepType.inhale || 
                currentStep.type == BreathingStepType.exhale)) {
      // Resume durumunda animasyonu devam ettir
      _controller.forward();
    }
    
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final currentStep = provider.currentStep;
    final countdown = provider.countdown;
    if (currentStep == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Animasyon değerini nefes durumuna göre hesapla
        double animationValue;
        switch (currentStep.type) {
          case BreathingStepType.inhale:
            animationValue = _controller.value; // 0.0'dan 1.0'a büyür
            break;
          case BreathingStepType.exhale:
            animationValue = 1.0 - _controller.value; // 1.0'dan 0.0'a küçülür
            break;
          case BreathingStepType.hold:
            // Nefes alındıktan sonra hold - büyük halde sabit kalır
            animationValue = 1.0;
            break;
          case BreathingStepType.holdAfterExhale:
            // Nefes verildikten sonra hold - küçük halde sabit kalır
            animationValue = 0.0;
            break;
        }
        
        animationValue = animationValue.clamp(0.0, 1.0);

        return SizedBox.expand(
          child: Stack(
            children: [
              // Ana nefes dairesi - sadece görsel efekt
              Center(
                child: Builder(
                  builder: (context) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallScreen = screenWidth < 400;
                    final baseSize = isSmallScreen ? 120 : 150;
                    final maxSize = isSmallScreen ? 200 : 270;
                    
                      return Container(
                      width: baseSize + (animationValue * (maxSize - baseSize)),
                      height: baseSize + (animationValue * (maxSize - baseSize)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 30 + (animationValue * 20),
                            spreadRadius: 5 + (animationValue * 10),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Text'ler - yumuşak geçişli
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.3),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      child: Builder(
                        builder: (context) {
                          final screenWidth = MediaQuery.of(context).size.width;
                          final isSmallScreen = screenWidth < 400;
                          
                          return Text(
                            currentStep.instruction,
                            key: ValueKey(currentStep.instruction),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              decoration: TextDecoration.none,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black54,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width < 400 ? 6 : 8),
                    Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final isSmallScreen = screenWidth < 400;
                        
                        return Text(
                          '$countdown',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 40 : 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                            decoration: TextDecoration.none,
                            shadows: const [
                              Shadow(
                                blurRadius: 15,
                                color: Colors.black54,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 