import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/story_series.dart';
import '../providers/story_provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';

class StoryPlayerScreen extends StatefulWidget {
  final StorySeries series;
  final StoryEpisode episode;

  const StoryPlayerScreen({
    super.key,
    required this.series,
    required this.episode,
  });

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  bool _sleepModeActive = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController.forward();
    
    // Oynatmaya başla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);
      storyProvider.playEpisode(widget.series.id, widget.episode.id);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sleepModeActive ? Colors.black : null,
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, child) {
          return Stack(
            children: [
              // Arka plan gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _sleepModeActive 
                      ? [Colors.black, Colors.black]
                      : [
                          widget.series.primaryColor.withOpacity(0.3),
                          widget.series.secondaryColor.withOpacity(0.1),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                  ),
                ),
              ),
              
              // Ana içerik
              SafeArea(
                child: Column(
                  children: [
                    // Üst bar
                    _buildTopBar(context, storyProvider),
                    
                    // Orta kısım - Görsel ve bilgiler
                    Expanded(
                      child: _buildMainContent(context, storyProvider),
                    ),
                    
                    // Alt kontroller
                    _buildControls(context, storyProvider),
                  ],
                ),
              ),
              
              // Uyku modu overlay
              if (_sleepModeActive)
                _buildSleepModeOverlay(context, storyProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, StoryProvider storyProvider) {
    return AnimatedOpacity(
      opacity: _sleepModeActive ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: _sleepModeActive ? Colors.white54 : null,
              ),
            ),
            
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.series.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _sleepModeActive ? Colors.white70 : null,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Bölüm ${widget.episode.episodeNumber}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _sleepModeActive 
                        ? Colors.white54 
                        : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Uyku modu toggle
            IconButton(
              onPressed: _toggleSleepMode,
              icon: Icon(
                _sleepModeActive ? Icons.bedtime : Icons.bedtime_outlined,
                color: _sleepModeActive ? Colors.white70 : widget.series.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, StoryProvider storyProvider) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Spacer(),
          
          // Ana görsel
          FadeIn(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.1);
                return Transform.scale(
                  scale: storyProvider.isPlaying ? scale : 1.0,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.series.primaryColor,
                          widget.series.secondaryColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.series.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      size: 80,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Bölüm bilgileri
          AnimatedOpacity(
            opacity: _sleepModeActive ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                Text(
                  widget.episode.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _sleepModeActive ? Colors.white70 : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  widget.episode.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _sleepModeActive 
                      ? Colors.white54 
                      : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Seslendiren: ${widget.series.narrator}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _sleepModeActive 
                      ? Colors.white54 
                      : AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, StoryProvider storyProvider) {
    return AnimatedOpacity(
      opacity: _sleepModeActive ? 0.3 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _sleepModeActive 
            ? Colors.black.withOpacity(0.5)
            : Theme.of(context).cardColor.withOpacity(0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İlerleme çubuğu
            _buildProgressBar(storyProvider),
            
            const SizedBox(height: 24),
            
            // Oynatma kontrolleri
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Geri sarma
                IconButton(
                  onPressed: () => _seekBackward(storyProvider),
                  icon: Icon(
                    Icons.replay_30,
                    size: 32,
                    color: _sleepModeActive ? Colors.white54 : null,
                  ),
                ),
                
                // Ana oynatma butonu
                GestureDetector(
                  onTap: () => _togglePlayPause(storyProvider),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.series.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: widget.series.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      storyProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                // İleri sarma
                IconButton(
                  onPressed: () => _seekForward(storyProvider),
                  icon: Icon(
                    Icons.forward_30,
                    size: 32,
                    color: _sleepModeActive ? Colors.white54 : null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Ek kontroller
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Zamanlayıcı
                IconButton(
                  onPressed: () => _showTimerDialog(context),
                  icon: Icon(
                    Icons.timer,
                    color: _sleepModeActive ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
                
                // Hız kontrolü
                IconButton(
                  onPressed: () => _showSpeedDialog(context),
                  icon: Icon(
                    Icons.speed,
                    color: _sleepModeActive ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
                
                // Favori
                IconButton(
                  onPressed: () => _toggleFavorite(storyProvider),
                  icon: Icon(
                    storyProvider.isFavorite(widget.series.id) 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                    color: storyProvider.isFavorite(widget.series.id) 
                      ? Colors.red 
                      : (_sleepModeActive ? Colors.white54 : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(StoryProvider storyProvider) {
    final progress = storyProvider.totalDuration > 0 
      ? storyProvider.currentPosition / storyProvider.totalDuration 
      : 0.0;
    
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.series.primaryColor,
            inactiveTrackColor: widget.series.primaryColor.withOpacity(0.2),
            thumbColor: widget.series.primaryColor,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              final newPosition = value * storyProvider.totalDuration;
              storyProvider.updatePosition(newPosition, storyProvider.totalDuration);
            },
          ),
        ),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(storyProvider.currentPosition),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _sleepModeActive ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
            Text(
              _formatDuration(storyProvider.totalDuration),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _sleepModeActive ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleepModeOverlay(BuildContext context, StoryProvider storyProvider) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Container(
        color: Colors.transparent,
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  storyProvider.isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 80,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.episode.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleSleepMode() {
    setState(() {
      _sleepModeActive = !_sleepModeActive;
    });
    
    if (_sleepModeActive) {
      // Tema provider'dan dark mode'u aktif et
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      themeProvider.setThemeMode(ThemeMode.dark);
    }
  }

  void _togglePlayPause(StoryProvider storyProvider) {
    if (storyProvider.isPlaying) {
      storyProvider.pauseEpisode();
    } else {
      storyProvider.resumeEpisode();
    }
  }

  void _seekBackward(StoryProvider storyProvider) {
    final newPosition = (storyProvider.currentPosition - 30).clamp(0.0, storyProvider.totalDuration);
    storyProvider.updatePosition(newPosition, storyProvider.totalDuration);
  }

  void _seekForward(StoryProvider storyProvider) {
    final newPosition = (storyProvider.currentPosition + 30).clamp(0.0, storyProvider.totalDuration);
    storyProvider.updatePosition(newPosition, storyProvider.totalDuration);
  }

  void _toggleFavorite(StoryProvider storyProvider) {
    storyProvider.toggleFavorite(widget.series.id);
  }

  void _showTimerDialog(BuildContext context) {
    // Zamanlayıcı dialog'u göster
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uyku Zamanlayıcısı'),
        content: const Text('Zamanlayıcı özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSpeedDialog(BuildContext context) {
    // Hız kontrolü dialog'u göster
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oynatma Hızı'),
        content: const Text('Hız kontrolü özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.series.category) {
      case StoryCategory.mythology:
        return Icons.auto_stories;
      case StoryCategory.sciFi:
        return Icons.rocket_launch;
      case StoryCategory.mystery:
        return Icons.search;
      case StoryCategory.fantasy:
        return Icons.castle;
      case StoryCategory.nature:
        return Icons.nature;
      case StoryCategory.history:
        return Icons.museum;
      case StoryCategory.philosophy:
        return Icons.psychology;
    }
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 