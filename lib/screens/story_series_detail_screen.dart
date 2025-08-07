import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/story_series.dart';
import '../providers/story_provider.dart';
import '../constants/app_colors.dart';
import '../widgets/story_episode_tile.dart';
import '../screens/story_player_screen.dart';

class StorySeriesDetailScreen extends StatefulWidget {
  final StorySeries series;

  const StorySeriesDetailScreen({
    super.key,
    required this.series,
  });

  @override
  State<StorySeriesDetailScreen> createState() => _StorySeriesDetailScreenState();
}

class _StorySeriesDetailScreenState extends State<StorySeriesDetailScreen> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, child) {
          final progress = storyProvider.getSeriesProgressPercentage(widget.series.id);
          final nextEpisode = storyProvider.getNextEpisode(widget.series.id);
          
          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Arka plan gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.series.primaryColor,
                              widget.series.secondaryColor,
                            ],
                          ),
                        ),
                      ),
                      
                      // Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      
                      // İçerik
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seri ikonu
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getCategoryIcon(),
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Başlık
                            Text(
                              widget.series.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Yazar ve seslendiren
                            Text(
                              '${widget.series.author} • ${widget.series.narrator}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // İçerik
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // İstatistikler
                      _buildStatsRow(),
                      
                      const SizedBox(height: 24),
                      
                      // İlerleme çubuğu
                      if (progress > 0)
                        _buildProgressSection(progress),
                      
                      if (progress > 0)
                        const SizedBox(height: 24),
                      
                      // Devam Et butonu
                      if (nextEpisode != null)
                        _buildContinueButton(storyProvider, nextEpisode),
                      
                      if (nextEpisode != null)
                        const SizedBox(height: 24),
                      
                      // Açıklama
                      _buildDescription(),
                      
                      const SizedBox(height: 24),
                      
                      // Etiketler
                      _buildTags(),
                      
                      const SizedBox(height: 32),
                      
                      // Bölümler başlığı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bölümler',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.series.totalEpisodes} bölüm',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              
              // Bölüm listesi
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final episode = widget.series.episodes[index];
                    return FadeInUp(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: StoryEpisodeTile(
                          series: widget.series,
                          episode: episode,
                          onTap: () => _navigateToPlayer(context, episode),
                        ),
                      ),
                    );
                  },
                  childCount: widget.series.episodes.length,
                ),
              ),
              
              // Alt boşluk
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Rating
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                size: 16,
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
              Text(
                widget.series.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Dinleyici sayısı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people_outline,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.series.totalListeners}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Toplam süre
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.series.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: widget.series.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.series.totalDuration} dk',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.series.primaryColor,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Premium badge
        if (widget.series.isPremium)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressSection(double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.series.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İlerleme',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: widget.series.primaryColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(widget.series.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% tamamlandı • ${widget.series.unlockedEpisodes}/${widget.series.totalEpisodes} bölüm',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(StoryProvider storyProvider, StoryEpisode nextEpisode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToPlayer(context, nextEpisode),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.series.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.play_arrow),
        label: Text(
          'Devam Et: ${nextEpisode.title}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hakkında',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.series.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          maxLines: _isDescriptionExpanded ? null : 3,
          overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
        ),
        if (widget.series.description.length > 100)
          TextButton(
            onPressed: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(
              _isDescriptionExpanded ? 'Daha az göster' : 'Devamını oku',
              style: TextStyle(
                color: widget.series.primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTags() {
    if (widget.series.tags.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiketler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.series.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _navigateToPlayer(BuildContext context, StoryEpisode episode) {
    final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    
    // Bölümün açık olup olmadığını kontrol et
    if (!storyProvider.isEpisodeUnlocked(widget.series.id, episode.id)) {
      _showLockedDialog(context, episode);
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryPlayerScreen(
          series: widget.series,
          episode: episode,
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context, StoryEpisode episode) {
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
} 