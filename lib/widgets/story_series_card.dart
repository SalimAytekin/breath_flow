import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/story_series.dart';
import '../providers/story_provider.dart';
import '../constants/app_colors.dart';

class StorySeriesCard extends StatelessWidget {
  final StorySeries series;
  final VoidCallback? onTap;
  final bool showProgress;
  final bool isCompact;

  const StorySeriesCard({
    super.key,
    required this.series,
    this.onTap,
    this.showProgress = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryProvider>(
      builder: (context, storyProvider, child) {
        final progress = storyProvider.getSeriesProgressPercentage(series.id);
        final isCurrentlyPlaying = storyProvider.currentlyPlayingSeries == series.id;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: isCompact ? 160 : double.infinity,
            margin: EdgeInsets.only(
              bottom: isCompact ? 0 : 16,
              right: isCompact ? 12 : 0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  series.primaryColor.withOpacity(0.1),
                  series.secondaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrentlyPlaying 
                  ? AppColors.primary 
                  : series.primaryColor.withOpacity(0.2),
                width: isCurrentlyPlaying ? 2 : 1,
              ),
            ),
            child: isCompact ? _buildCompactCard(context, storyProvider, progress) 
                            : _buildFullCard(context, storyProvider, progress),
          ),
        );
      },
    );
  }

  Widget _buildCompactCard(BuildContext context, StoryProvider storyProvider, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kapak resmi
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [series.primaryColor, series.secondaryColor],
            ),
          ),
          child: Stack(
            children: [
              // Placeholder icon
              Center(
                child: Icon(
                  _getCategoryIcon(),
                  size: 40,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              
              // Premium badge
              if (series.isPremium)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              // Playing indicator
              if (storyProvider.currentlyPlayingSeries == series.id)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      storyProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // İçerik
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  series.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  series.author,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // İlerleme çubuğu
                if (showProgress && progress > 0)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: series.primaryColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(series.primaryColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toInt()}% tamamlandı',
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
        ),
      ],
    );
  }

  Widget _buildFullCard(BuildContext context, StoryProvider storyProvider, double progress) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Kapak resmi
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [series.primaryColor, series.secondaryColor],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getCategoryIcon(),
                    size: 32,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                
                if (series.isPremium)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                if (storyProvider.currentlyPlayingSeries == series.id)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        storyProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // İçerik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  series.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'Yazar: ${series.author} • Seslendiren: ${series.narrator}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  series.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // İstatistikler
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      series.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${series.totalListeners}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${series.totalDuration} dk',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                // İlerleme çubuğu
                if (showProgress && progress > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: series.primaryColor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(series.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toInt()}% tamamlandı • ${series.unlockedEpisodes}/${series.totalEpisodes} bölüm',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (series.category) {
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
}

// Hikaye serilerini yatay liste halinde gösteren widget
class StorySeriesHorizontalList extends StatelessWidget {
  final String title;
  final List<StorySeries> series;
  final VoidCallback? onSeeAll;
  final Function(StorySeries)? onSeriesTap;

  const StorySeriesHorizontalList({
    super.key,
    required this.title,
    required this.series,
    this.onSeeAll,
    this.onSeriesTap,
  });

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('Tümünü Gör'),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: series.length,
            itemBuilder: (context, index) {
              final storySeriesItem = series[index];
              return FadeInRight(
                duration: Duration(milliseconds: 300 + (index * 100)),
                child: StorySeriesCard(
                  series: storySeriesItem,
                  isCompact: true,
                  onTap: () => onSeriesTap?.call(storySeriesItem),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 