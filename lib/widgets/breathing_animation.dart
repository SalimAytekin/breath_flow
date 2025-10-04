import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
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
          Vibrate.feedback(FeedbackType.light);
          break;
        case BreathingStepType.hold:
        case BreathingStepType.holdAfterExhale:
          Vibrate.feedback(FeedbackType.medium);
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
                child: Container(
                  width: 150 + (animationValue * 120), // 150px'den 270px'e
                  height: 150 + (animationValue * 120),
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
                      child: Text(
                        currentStep.instruction,
                        key: ValueKey(currentStep.instruction),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black54,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$countdown',
                      style: TextStyle(
                        fontSize: 48, // Sabit boyut
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                        decoration: TextDecoration.none, // Alt çizgiyi kaldır
                        shadows: const [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.black54,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
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