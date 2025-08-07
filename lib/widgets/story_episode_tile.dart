import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_series.dart';
import '../providers/story_provider.dart';
import '../constants/app_colors.dart';

class StoryEpisodeTile extends StatelessWidget {
  final StorySeries series;
  final StoryEpisode episode;
  final VoidCallback? onTap;
  final bool showPlayButton;

  const StoryEpisodeTile({
    super.key,
    required this.series,
    required this.episode,
    this.onTap,
    this.showPlayButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryProvider>(
      builder: (context, storyProvider, child) {
        final isUnlocked = storyProvider.isEpisodeUnlocked(series.id, episode.id);
        final isCurrentlyPlaying = storyProvider.currentlyPlayingEpisode == episode.id;
        final isPlaying = storyProvider.isPlaying && isCurrentlyPlaying;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isCurrentlyPlaying 
              ? series.primaryColor.withOpacity(0.1)
              : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentlyPlaying 
                ? series.primaryColor.withOpacity(0.3)
                : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            
            // Bölüm numarası
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isUnlocked 
                  ? series.primaryColor.withOpacity(0.1)
                  : AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isUnlocked
                  ? Text(
                      episode.episodeNumber.toString(),
                      style: TextStyle(
                        color: series.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  : Icon(
                      Icons.lock,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
              ),
            ),
            
            // Başlık ve açıklama
            title: Text(
              episode.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isUnlocked 
                  ? null 
                  : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  episode.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUnlocked 
                      ? AppColors.textSecondary 
                      : AppColors.textSecondary.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Süre ve premium bilgisi
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${episode.durationMinutes} dakika',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    
                    if (episode.isPremium) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                // İlerleme çubuğu (eğer çalıyor veya daha önce dinlendiyse)
                if (isCurrentlyPlaying && storyProvider.totalDuration > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: storyProvider.currentPosition / storyProvider.totalDuration,
                          backgroundColor: series.primaryColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(series.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(storyProvider.currentPosition),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              _formatDuration(storyProvider.totalDuration),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            // Oynatma butonu
            trailing: showPlayButton
              ? GestureDetector(
                  onTap: isUnlocked 
                    ? () => _handlePlayPause(context, storyProvider)
                    : () => _showLockedDialog(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isUnlocked 
                        ? (isCurrentlyPlaying ? series.primaryColor : series.primaryColor.withOpacity(0.1))
                        : AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      isUnlocked
                        ? (isPlaying ? Icons.pause : Icons.play_arrow)
                        : Icons.lock,
                      color: isUnlocked
                        ? (isCurrentlyPlaying ? Colors.white : series.primaryColor)
                        : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                )
              : null,
            
            onTap: isUnlocked 
              ? onTap ?? () => _handlePlayPause(context, storyProvider)
              : () => _showLockedDialog(context),
          ),
        );
      },
    );
  }

  void _handlePlayPause(BuildContext context, StoryProvider storyProvider) {
    if (storyProvider.currentlyPlayingEpisode == episode.id) {
      // Aynı bölüm çalıyorsa pause/resume
      if (storyProvider.isPlaying) {
        storyProvider.pauseEpisode();
      } else {
        storyProvider.resumeEpisode();
      }
    } else {
      // Yeni bölüm çalmaya başla
      storyProvider.playEpisode(series.id, episode.id);
    }
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bölüm Kilitli'),
        content: Text(
          episode.isPremium 
            ? 'Bu bölüm premium içeriktir. Premium üyeliğinizi aktifleştirin.'
            : 'Bu bölümü açmak için önceki bölümleri tamamlamanız gerekiyor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
          if (episode.isPremium)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Premium sayfasına yönlendir
              },
              child: const Text('Premium Al'),
            ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 