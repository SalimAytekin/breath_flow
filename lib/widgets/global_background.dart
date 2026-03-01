import 'package:flutter/material.dart';
import 'dart:ui';

/// A globally reusable background widget that provides the app's signature
/// warm night comfort look with soft ambient orbs and subtle warmth.
class GlobalBackground extends StatelessWidget {
  final Widget child;

  const GlobalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base warm golden-brown gradient — Mockup'a birebir
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.3, 0.6, 1.0],
              colors: [
                Color(0xFF2C1E10), // Koyu altın-kahve üst
                Color(0xFF3A2815), // Sıcak amber-kahve
                Color(0xFF2E1F10), // Orta altın-kahve
                Color(0xFF1E1408), // Koyu alt
              ],
            ),
          ),
        ),

        // 2. Floating warm orbs for ambient light (2 orb - performans için)
        Positioned(
          top: -60,
          left: -80,
          child: _buildOrb(350, const Color(0xFFD4A050), 0.12),
        ),
        Positioned(
          top: 200,
          right: -120,
          child: _buildOrb(280, const Color(0xFFC48A40), 0.08),
        ),
        Positioned(
          bottom: -80,
          right: -80,
          child: _buildOrb(250, const Color(0xFFB87830), 0.06),
        ),

        // 3. Warm golden shimmer overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFD4A050).withOpacity(0.04),
                Colors.transparent,
                const Color(0xFFC48A40).withOpacity(0.03),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),

        // 4. Gentle overlay for depth (BackdropFilter kaldırıldı - performans için)
        Container(
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
