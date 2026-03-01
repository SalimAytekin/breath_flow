import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import '../constants/app_strings.dart';
import '../models/sound_item.dart';
import '../models/premium_trigger.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../screens/immersive_sound_player_screen.dart';
import '../providers/audio_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/premium_provider.dart';
import '../widgets/smart_premium_dialog.dart';

class SoundCard extends StatefulWidget {
  final SoundItem sound;
  final double? width;
  final double? height;
  final void Function(SoundItem)? onTap; // optional external tap handler

  const SoundCard({
    super.key,
    required this.sound,
    this.width,
    this.height = 200,
    this.onTap,
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
    
    // 🔒 Premium içerik kontrolü
    if (widget.sound.isPremium) {
      final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
      if (!premiumProvider.canAccessPremiumContent(widget.sound.isPremium)) {
        HapticFeedback.heavyImpact();
        final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
          (t) => t.targetFeatures.contains(PremiumProvider.featurePremiumSounds),
          orElse: () => PremiumTrigger.predefinedTriggers.first,
        );
        SmartPremiumDialog.show(context, trigger);
        return;
      }
    }
    
    if (widget.onTap != null) {
      widget.onTap!(widget.sound);
      return;
    }

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
    
    // 🔒 Premium içerik kontrolü
    if (widget.sound.isPremium) {
      final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
      if (!premiumProvider.canAccessPremiumContent(widget.sound.isPremium)) {
        HapticFeedback.heavyImpact();
        final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
          (t) => t.targetFeatures.contains(PremiumProvider.featurePremiumSounds),
          orElse: () => PremiumTrigger.predefinedTriggers.first,
        );
        SmartPremiumDialog.show(context, trigger);
        return;
      }
    }
    
    if (widget.onTap != null) {
      widget.onTap!(widget.sound);
      return;
    }

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
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    audioProvider.toggleMixerSound(widget.sound);
  }

  @override
  Widget build(BuildContext context) {
    // ⚡ PERFORMANCE: Selector yerine watch kullanımı optimize edildi
    // Sadece bu sound'a ait değişikliklerde rebuild olur
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
                border: isPlayingInMixer
                    ? Border.all(
                        color: const Color(0xFFFFD700),
                        width: 1.5,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                  if (isPlayingInMixer)
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  if (shouldPulse && !isPlayingInMixer)
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
                    // Sol üst: Favori butonu
                    _buildFavoriteButton(),
                    // Sağ üst: Premium badge (premium içerik ise) + Mix butonu
                    _buildTopRightControls(isPlayingInMixer),
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
          // ⚡ Image error - silent fallback (no log spam)
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
                  widget.sound.name.toUpperCase(),
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8A838),
                    Color(0xFFD4912A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE8A838).withOpacity(0.5),
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

  /// Sağ üst kontroller: Mix butonu (PRO badge sol üstte ayrı gösterilecek)
  Widget _buildTopRightControls(bool isPlayingInMixer) {
    return Positioned(
      top: AppSpacing.medium,
      right: AppSpacing.medium,
      child: Consumer<PremiumProvider>(
        builder: (context, premiumProvider, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium badge - Favori butonunun yanında göster
              if (widget.sound.isPremium && !premiumProvider.isPremiumUser)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.premium,
                        AppColors.premium.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.premium.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.diamond,
                        color: Colors.white,
                        size: 11,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              // Mix butonu
              _buildMixButton(isPlayingInMixer, premiumProvider),
            ],
          );
        },
      ),
    );
  }
  
  /// Mix butonu
  Widget _buildMixButton(bool isPlayingInMixer, PremiumProvider premiumProvider) {
    return GestureDetector(
      onTap: () {
        final audioProvider = Provider.of<AudioProvider>(context, listen: false);
        
        // Mix limiti kontrolü - Merkezi sistem kullan
        final canAdd = premiumProvider.canAddToMix(audioProvider.mixerSounds.length);
        final isAlreadyInMix = audioProvider.mixerSounds.any((s) => s.id == widget.sound.id);
        
        if (!canAdd && !isAlreadyInMix) {
          HapticFeedback.heavyImpact();
          final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
            (t) => t.targetFeatures.contains(PremiumProvider.featureUnlimitedMixes),
            orElse: () => PremiumTrigger.predefinedTriggers.first,
          );
          SmartPremiumDialog.show(context, trigger);
          return;
        }
        
        _onMixerButtonTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isPlayingInMixer 
              ? const Color(0xFFFFD700).withValues(alpha: 0.15) 
              : Colors.black.withValues(alpha: 0.5),
          border: Border.all(
            color: isPlayingInMixer
                ? const Color(0xFFFFD700)
                : Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlayingInMixer ? FeatherIcons.check : FeatherIcons.plus,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              AppStrings.mixButton,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        final isFavorite = userPrefs.isFavoriteSound(widget.sound.id);
        
        return Positioned(
          top: AppSpacing.medium,
          left: AppSpacing.medium,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              userPrefs.toggleFavoriteSound(widget.sound.id);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFavorite ? Colors.red : Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

}