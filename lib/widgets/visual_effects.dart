import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// ✨ Visual Effects Library
/// Advanced visual effects for Deep Night Serenity theme
class VisualEffects {
  /// 🌟 Particle System
  static Widget createParticleSystem({
    required int particleCount,
    required Color color,
    required Size size,
    double speed = 1.0,
    ParticleType type = ParticleType.floating,
  }) {
    return ParticleSystem(
      particleCount: particleCount,
      color: color,
      size: size,
      speed: speed,
      type: type,
    );
  }
  
  /// 🌊 Parallax Effect
  static Widget createParallaxBackground({
    required List<ParallaxLayer> layers,
    required ScrollController scrollController,
  }) {
    return ParallaxBackground(
      layers: layers,
      scrollController: scrollController,
    );
  }
  
  /// 💎 Enhanced Glassmorphism
  static Widget createGlassmorphism({
    required Widget child,
    double blur = 10.0,
    double opacity = 0.1,
    Color? borderColor,
    BorderRadius? borderRadius,
  }) {
    return EnhancedGlassmorphism(
      blur: blur,
      opacity: opacity,
      borderColor: borderColor,
      borderRadius: borderRadius,
      child: child,
    );
  }
  
  /// 🌈 Gradient Animations
  static Widget createAnimatedGradient({
    required List<Color> colors,
    Duration duration = const Duration(seconds: 3),
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return AnimatedGradientBackground(
      colors: colors,
      duration: duration,
      begin: begin,
      end: end,
    );
  }
}

/// 🌟 Particle System Widget
class ParticleSystem extends StatefulWidget {
  final int particleCount;
  final Color color;
  final Size size;
  final double speed;
  final ParticleType type;

  const ParticleSystem({
    super.key,
    required this.particleCount,
    required this.color,
    required this.size,
    this.speed = 1.0,
    this.type = ParticleType.floating,
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (3000 / widget.speed).round()),
      vsync: this,
    );
    
    _initializeParticles();
    _controller.repeat();
  }

  void _initializeParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        position: Offset(
          math.Random().nextDouble() * widget.size.width,
          math.Random().nextDouble() * widget.size.height,
        ),
        velocity: Offset(
          (math.Random().nextDouble() - 0.5) * 2 * widget.speed,
          (math.Random().nextDouble() - 0.5) * 2 * widget.speed,
        ),
        size: math.Random().nextDouble() * 4 + 1,
        opacity: math.Random().nextDouble() * 0.8 + 0.2,
        color: widget.color,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateParticles();
        return CustomPaint(
          size: widget.size,
          painter: ParticlePainter(_particles, widget.type),
        );
      },
    );
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.position += particle.velocity;
      
      // Wrap around screen edges
      if (particle.position.dx < 0) {
        particle.position = Offset(widget.size.width, particle.position.dy);
      } else if (particle.position.dx > widget.size.width) {
        particle.position = Offset(0, particle.position.dy);
      }
      
      if (particle.position.dy < 0) {
        particle.position = Offset(particle.position.dx, widget.size.height);
      } else if (particle.position.dy > widget.size.height) {
        particle.position = Offset(particle.position.dx, 0);
      }
      
      // Animate opacity for breathing effect
      if (widget.type == ParticleType.breathing) {
        particle.opacity = (math.sin(_controller.value * 2 * math.pi) + 1) / 2 * 0.8 + 0.2;
      }
    }
  }
}

/// 🎨 Particle Painter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final ParticleType type;

  ParticlePainter(this.particles, this.type);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      switch (type) {
        case ParticleType.floating:
          canvas.drawCircle(particle.position, particle.size, paint);
          break;
        case ParticleType.breathing:
          // Draw with subtle glow effect
          final glowPaint = Paint()
            ..color = particle.color.withOpacity(particle.opacity * 0.3)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
          
          canvas.drawCircle(particle.position, particle.size * 2, glowPaint);
          canvas.drawCircle(particle.position, particle.size, paint);
          break;
        case ParticleType.stars:
          _drawStar(canvas, particle.position, particle.size, paint);
          break;
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.5;
    
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi) / 5;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(angle - math.pi / 2);
      final y = center.dy + radius * math.sin(angle - math.pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 🌊 Parallax Background
class ParallaxBackground extends StatelessWidget {
  final List<ParallaxLayer> layers;
  final ScrollController scrollController;

  const ParallaxBackground({
    super.key,
    required this.layers,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: layers.map((layer) {
        return AnimatedBuilder(
          animation: scrollController,
          builder: (context, child) {
            final offset = scrollController.hasClients 
                ? scrollController.offset * layer.speed 
                : 0.0;
            
            return Transform.translate(
              offset: Offset(0, offset),
              child: layer.child,
            );
          },
        );
      }).toList(),
    );
  }
}

/// 💎 Enhanced Glassmorphism
class EnhancedGlassmorphism extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  const EnhancedGlassmorphism({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLarge),
            border: borderColor != null 
                ? Border.all(color: borderColor!, width: 1)
                : Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(opacity * 1.5),
                Colors.white.withOpacity(opacity * 0.5),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 🌈 Animated Gradient Background
class AnimatedGradientBackground extends StatefulWidget {
  final List<Color> colors;
  final Duration duration;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const AnimatedGradientBackground({
    super.key,
    required this.colors,
    this.duration = const Duration(seconds: 3),
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: widget.begin,
              end: widget.end,
              colors: widget.colors.map((color) {
                return Color.lerp(
                  color,
                  color.withOpacity(0.7),
                  _animation.value,
                ) ?? color;
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// 🌟 Floating Action Button with Effects
class EffectFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final bool enableParticles;

  const EffectFloatingActionButton({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.enableParticles = true,
  });

  @override
  State<EffectFloatingActionButton> createState() => _EffectFloatingActionButtonState();
}

class _EffectFloatingActionButtonState extends State<EffectFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Particle effect background
        if (widget.enableParticles)
          SizedBox(
            width: 120,
            height: 120,
            child: VisualEffects.createParticleSystem(
              particleCount: 8,
              color: widget.backgroundColor ?? AppColors.primaryAccent,
              size: const Size(120, 120),
              speed: 0.5,
              type: ParticleType.breathing,
            ),
          ),
        
        // Pulsing glow effect
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.backgroundColor ?? AppColors.primaryAccent)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Main FAB
        FloatingActionButton(
          onPressed: widget.onPressed,
          backgroundColor: widget.backgroundColor,
          elevation: widget.elevation ?? 8,
          child: widget.child,
        ),
      ],
    );
  }
}

/// 🎭 Data Models
class Particle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

class ParallaxLayer {
  final Widget child;
  final double speed;

  const ParallaxLayer({
    required this.child,
    this.speed = 0.5,
  });
}

/// 🎨 Enums
enum ParticleType {
  floating,
  breathing,
  stars,
}

/// 🌊 Morphing Container
class MorphingContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final List<BoxDecoration> decorations;

  const MorphingContainer({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 4),
    required this.decorations,
  });

  @override
  State<MorphingContainer> createState() => _MorphingContainerState();
}

class _MorphingContainerState extends State<MorphingContainer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.decorations.length;
        });
        _controller.reset();
        _controller.forward();
      }
    });
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentDecoration = widget.decorations[_currentIndex];
        final nextDecoration = widget.decorations[
          (_currentIndex + 1) % widget.decorations.length
        ];
        
        return Container(
          decoration: BoxDecoration.lerp(
            currentDecoration,
            nextDecoration,
            _animation.value,
          ),
          child: widget.child,
        );
      },
    );
  }
} 