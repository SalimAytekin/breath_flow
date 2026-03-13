import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎯 Geri Sayım Overlay — 3-2-1-BAŞLA!
///
/// Tam ekran overlay, pulse animasyonu, haptic feedback.
/// Geri sayım tamamlandığında [onComplete] callback çağrılır.
class CountdownOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final List<Color> gradientColors;

  const CountdownOverlay({
    super.key,
    required this.onComplete,
    this.gradientColors = const [Color(0xFFC4956A), Color(0xFFD4A574)],
  });

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with TickerProviderStateMixin {
  int _count = 3;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // İlk gösterim
    _fadeController.forward();
    _playTick();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_count > 1) {
        setState(() => _count--);
        _scaleController.reset();
        _scaleController.forward();
        _playTick();
      } else {
        _timer?.cancel();
        setState(() => _count = 0); // "BAŞLA!" göster
        _scaleController.reset();
        _scaleController.forward();
        _playGoHaptic();

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) widget.onComplete();
        });
      }
    });

    _scaleController.forward();
  }

  void _playTick() {
    HapticFeedback.mediumImpact();
  }

  void _playGoHaptic() {
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _count > 0
                ? _buildCountNumber()
                : _buildGoText(),
          ),
        ),
      ),
    );
  }

  Widget _buildCountNumber() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glow circle
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.gradientColors.first.withOpacity(0.3),
                widget.gradientColors.first.withOpacity(0.0),
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$_count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Hazırlan...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGoText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: widget.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'BAŞLA!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Icon(
          Icons.fitness_center,
          color: Colors.white54,
          size: 28,
        ),
      ],
    );
  }
}
