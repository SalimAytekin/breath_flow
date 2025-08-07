import 'dart:ui';
import 'package:breathe_flow/models/meditation_journey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:breathe_flow/constants/app_colors.dart';

class JourneyCard extends StatelessWidget {
  final MeditationJourney journey;
  final VoidCallback onTap;

  const JourneyCard({
    super.key,
    required this.journey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackgroundImage(),
              _buildGradientOverlay(),
              _buildCardContent(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Image.asset(
      journey.imagePath,
      fit: BoxFit.cover,
      color: Colors.black.withOpacity(0.2),
      colorBlendMode: BlendMode.darken,
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }

  Widget _buildCardContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTag(theme),
          const Spacer(),
          _buildTitle(theme),
          const SizedBox(height: 8),
          _buildDescription(theme),
          const SizedBox(height: 16),
          _buildProgressBar(theme),
        ],
      ),
    );
  }

  Widget _buildTag(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${journey.steps.length} GÜNLÜK YOLCULUK',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      journey.title,
      style: theme.textTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [const Shadow(blurRadius: 8, color: Colors.black54)],
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      journey.description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.white.withOpacity(0.9),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: journey.progress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(DarkAppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${(journey.progress * 100).toInt()}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }
} 