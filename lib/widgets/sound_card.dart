import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../models/sound_item.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../screens/immersive_sound_player_screen.dart';
import '../providers/audio_provider.dart';
import 'package:provider/provider.dart';

class SoundCard extends StatefulWidget {
  final SoundItem sound;
  final double? width;
  final double? height;

  const SoundCard({
    super.key,
    required this.sound,
    this.width,
    this.height = 200,
  });

  @override
  State<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(SoundCard oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  void _onCardTap() {
    HapticFeedback.mediumImpact();
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            ImmersiveSoundPlayerScreen(sound: widget.sound),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _onPlayPauseButtonTap() {
    HapticFeedback.mediumImpact();
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            ImmersiveSoundPlayerScreen(sound: widget.sound),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _onMixerButtonTap() {
    HapticFeedback.selectionClick();
    Provider.of<AudioProvider>(context, listen: false).toggleMixerSound(widget.sound);
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final isPlayingInMixer = audioProvider.mixerSounds.any((s) => s.id == widget.sound.id);
    final isThisSoundExclusive = audioProvider.exclusiveSound?.id == widget.sound.id;
    final isThisSoundPlaying = isThisSoundExclusive && audioProvider.isPlaying(widget.sound.id);

    final bool shouldPulse = isPlayingInMixer || isThisSoundPlaying;

    if (shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!shouldPulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onCardTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: shouldPulse
                ? _pulseAnimation.value * (_isPressed ? 0.95 : 1.0)
                : (_isPressed ? 0.95 : 1.0),
            child: Container(
              width: widget.width,
              height: widget.height ?? 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                  if (shouldPulse)
                    BoxShadow(
                      color: widget.sound.color.withOpacity(0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildBackgroundImage(),
                    _buildGradientOverlay(),
                    _buildGlassmorphismOverlay(),
                    _buildContent(isThisSoundPlaying),
                    if (widget.sound.isPremium) _buildProBadge(),
                    _buildMixerButton(isPlayingInMixer),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        widget.sound.imagePath,
        fit: BoxFit.cover,
        // 🚀 PERFORMANCE OPTIMIZATIONS
        cacheWidth: 600,  // Memory cache optimization
        cacheHeight: 800, // Reduces memory usage
        isAntiAlias: true, // Smooth rendering
        filterQuality: FilterQuality.medium, // Balance between quality and performance
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          // 🎭 Loading animation
          if (wasSynchronouslyLoaded) return child;
          
          return AnimatedOpacity(
            opacity: frame == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('🚨 Image load error: ${widget.sound.imagePath}');
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.sound.color.withOpacity(0.3),
                  widget.sound.color.withOpacity(0.6),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                widget.sound.icon,
                size: 60,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.05),
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.8),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphismOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isPlaying) {
    return Positioned(
      bottom: AppSpacing.medium,
      left: AppSpacing.medium,
      right: AppSpacing.medium,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.sound.name,
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.tiny),
                Text(
                  widget.sound.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          GestureDetector(
            onTap: _onPlayPauseButtonTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.85),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Icon(
                isPlaying ? FeatherIcons.pause : FeatherIcons.play,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProBadge() {
    return Positioned(
      top: AppSpacing.medium,
      left: AppSpacing.medium,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.premium.withOpacity(0.8),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.diamond,
          color: AppColors.premium,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildMixerButton(bool isPlayingInMixer) {
    return Positioned(
      top: AppSpacing.medium,
      right: AppSpacing.medium,
      child: GestureDetector(
        onTap: _onMixerButtonTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPlayingInMixer 
                ? AppColors.secondaryAccent.withOpacity(0.9) 
                : Colors.black.withOpacity(0.4),
            border: Border.all(
              color: isPlayingInMixer
                  ? AppColors.secondaryAccent
                  : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            isPlayingInMixer ? FeatherIcons.check : FeatherIcons.plus,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayingIndicator() {
    return Positioned(
      bottom: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.graphic_eq, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              "Çalıyor",
              style: AppTypography.labelSmall.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
} 