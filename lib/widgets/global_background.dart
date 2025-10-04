import 'package:flutter/material.dart';
import 'dart:ui';

/// A globally reusable background widget that provides the app's signature
/// deep night sky look with aurora-like orbs and subtle blur effects.
class GlobalBackground extends StatelessWidget {
  final Widget child;

  const GlobalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base deep night gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 0.8, 1.0],
              colors: [
                Color(0xFF0B0B1A), // Deepest space blue
                Color(0xFF1A1A2E), // Midnight blue
                Color(0xFF16213E), // Dark indigo
                Color(0xFF0F0F1E), // Near black blue
              ],
            ),
          ),
        ),

        // 2. Floating aurora-like orbs for ambient light
        Positioned(
          top: -50,
          left: -100,
          child: _buildOrb(300, const Color(0xFF4A5568), 0.15),
        ),
        Positioned(
          bottom: -80,
          right: -80,
          child: _buildOrb(250, const Color(0xFF6B46C1), 0.12),
        ),
        Positioned(
          top: 200,
          right: 50,
          child: _buildOrb(180, const Color(0xFF4C6EF5), 0.08),
        ),

        // 3. Subtle animated shimmer overlay for a touch of magic
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.02),
                Colors.transparent,
                Colors.white.withOpacity(0.01),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // 4. Gentle blur layer for depth and to soften the orbs
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.02),
                  Colors.transparent,
                  Colors.black.withOpacity(0.03),
                ],
              ),
            ),
          ),
        ),

        // 5. The actual content
        child,
      ],
    );
  }

  /// Helper to build the decorative orbs.
  Widget _buildOrb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(opacity * 0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
