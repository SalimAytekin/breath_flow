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
    if (currentStep == null || currentStep.type == _lastStep) return;

    _lastStep = currentStep.type;
    _controller.duration = Duration(seconds: currentStep.duration);

    // Haptik geri bildirim (YENİ PAKETLE GÜNCELLENDİ)
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
        // Mevcut durumda kal, animasyonu durdur.
        _controller.stop();
        // Animasyonun o anki değerinde kalmasını sağla.
        _animation = Tween<double>(begin: _controller.value, end: _controller.value)
            .animate(_controller);
        break;
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
        final animationValue = (_animation.value).clamp(0.0, 1.0);
        final isInhaling = currentStep.type == BreathingStepType.inhale;

        // Arka plan gradyanı
        final backgroundGradient = RadialGradient(
          colors: isInhaling
              ? [AppColors.focus.withOpacity(0.4), AppColors.primaryBackground]
              : [AppColors.sleep.withOpacity(0.4), AppColors.primaryBackground],
          radius: 1.0 + animationValue * 1.5,
          stops: const [0.0, 1.0],
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            // 1. Hareketli Arka Plan
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(gradient: backgroundGradient),
            ),

            // 2. Parçacıklar veya diğer efektler buraya eklenebilir
            // ...

            // 3. Ana Nefes Dairesi
            Container(
              width: 200 + (animationValue * 100),
              height: 200 + (animationValue * 100),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.4, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isInhaling ? AppColors.focus : AppColors.sleep)
                        .withOpacity(0.3),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentStep.instruction,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$countdown',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 