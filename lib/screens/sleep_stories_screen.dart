import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/story_series.dart';
import '../providers/story_provider.dart';
import '../widgets/professional_card.dart';
import '../widgets/story_series_card.dart';
import '../screens/story_series_detail_screen.dart';

/// 🌙 Uyku Hikayeleri Ana Liste Sayfası
/// Tüm uyku hikayelerini kategorilere göre listeler
class SleepStoriesScreen extends StatefulWidget {
  const SleepStoriesScreen({super.key});

  @override
  State<SleepStoriesScreen> createState() => _SleepStoriesScreenState();
}

class _SleepStoriesScreenState extends State<SleepStoriesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  StoryCategory? _selectedCategory;

  // Kategoriler ve isimleri
  final Map<StoryCategory, String> _categoryNames = {
    StoryCategory.mythology: 'Mitoloji',
    StoryCategory.sciFi: 'Bilim-Kurgu', 
    StoryCategory.mystery: 'Gizem',
    StoryCategory.fantasy: 'Fantastik',
    StoryCategory.nature: 'Doğa',
    StoryCategory.history: 'Tarih',
    StoryCategory.philosophy: 'Felsefe',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 🌟 Professional App Bar
              _buildSliverAppBar(context),
              
              // 🔍 Arama Çubuğu
              _buildSearchSection(),
              
              // 📊 İstatistikler Kartı
              _buildStatsSection(storyProvider),
              
              // 🏷️ Kategori Filtreleri
              _buildCategoryFilters(),
              
              // 📚 Hikaye Kategorileri
              _buildStorySections(storyProvider),
              
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

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Uyku Hikayeleri',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.sleep.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              FeatherIcons.moon,
              size: 80,
              color: AppColors.sleep.withOpacity(0.2),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(FeatherIcons.filter),
          onPressed: _showFilterBottomSheet,
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cardStroke.withOpacity(0.1),
              ),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Hikaye ara...',
                prefixIcon: const Icon(FeatherIcons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(StoryProvider storyProvider) {
    final totalStories = storyProvider.allSeries.length;
    final completedStories = storyProvider.allSeries
        .where((series) => storyProvider.seriesProgress[series.id] != null)
        .length;
    final totalListeningTime = storyProvider.allSeries
        .fold<int>(0, (sum, series) => sum + series.totalDuration);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        child: FadeInUp(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          child: ProfessionalCard(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: FeatherIcons.bookOpen,
                    title: 'Toplam Hikaye',
                    value: '$totalStories',
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.cardStroke.withOpacity(0.2),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: FeatherIcons.checkCircle,
                    title: 'Dinlenen',
                    value: '$completedStories',
                    color: AppColors.success,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.cardStroke.withOpacity(0.2),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: FeatherIcons.clock,
                    title: 'Toplam Süre',
                    value: '${(totalListeningTime / 60).round()}h',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AppSpacing.small),
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
        child: FadeInLeft(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 400),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
            itemCount: _categoryNames.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.medium),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(
                  label: 'Tümü',
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                );
              }
              
              final category = _categoryNames.keys.elementAt(index - 1);
              final categoryName = _categoryNames[category]!;
              
              return _buildCategoryChip(
                label: categoryName,
                isSelected: _selectedCategory == category,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.small,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.cardStroke.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected 
                ? Colors.white 
                : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStorySections(StoryProvider storyProvider) {
    final filteredSeries = _getFilteredSeries(storyProvider);
    
    if (filteredSeries.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Öne Çıkan Hikayeler
          if (_selectedCategory == null && _searchQuery.isEmpty) ...[
            _buildSectionHeader('Öne Çıkan Hikayeler'),
            _buildFeaturedStories(storyProvider),
            const SizedBox(height: AppSpacing.xLarge),
          ],
          
          // Devam Eden Hikayeler
          if (storyProvider.continueWatching.isNotEmpty && _selectedCategory == null && _searchQuery.isEmpty) ...[
            _buildSectionHeader('Devam Eden Hikayeler'),
            _buildContinueWatching(storyProvider),
            const SizedBox(height: AppSpacing.xLarge),
          ],
          
          // Tüm Hikayeler
          _buildSectionHeader(_selectedCategory != null 
              ? _categoryNames[_selectedCategory!]! 
              : 'Tüm Hikayeler'),
          _buildAllStories(filteredSeries),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Text(
          title,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedStories(StoryProvider storyProvider) {
    final featuredStories = storyProvider.popularSeries.take(3).toList();
    
    return Container(
      height: 200,
      margin: const EdgeInsets.only(top: AppSpacing.medium),
      child: FadeInRight(
        duration: const Duration(milliseconds: 600),
        delay: const Duration(milliseconds: 200),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          itemCount: featuredStories.length,
          separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.medium),
          itemBuilder: (context, index) {
            final series = featuredStories[index];
            return SizedBox(
              width: 280,
              child: StorySeriesCard(
                series: series,
                onTap: () => _navigateToStoryDetail(series),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContinueWatching(StoryProvider storyProvider) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(top: AppSpacing.medium),
      child: FadeInLeft(
        duration: const Duration(milliseconds: 600),
        delay: const Duration(milliseconds: 300),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          itemCount: storyProvider.continueWatching.length,
          separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.medium),
          itemBuilder: (context, index) {
            final series = storyProvider.continueWatching[index];
            return SizedBox(
              width: 200,
              child: _buildCompactStoryCard(series, storyProvider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactStoryCard(StorySeries series, StoryProvider storyProvider) {
    final progress = storyProvider.getSeriesProgressPercentage(series.id);
    
    return ProfessionalCard(
      onTap: () => _navigateToStoryDetail(series),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                     Text(
             series.title,
             style: AppTypography.headlineSmall.copyWith(
               fontWeight: FontWeight.w600,
             ),
             maxLines: 2,
             overflow: TextOverflow.ellipsis,
           ),
          const SizedBox(height: AppSpacing.small),
          Text(
            series.author,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          
          // İlerleme çubuğu
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '%${progress.round()} tamamlandı',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.tiny),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: AppColors.cardStroke.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllStories(List<StorySeries> stories) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        children: List.generate(
          stories.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              bottom: index < stories.length - 1 ? AppSpacing.large : 0,
            ),
            child: FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: Duration(milliseconds: 100 * index),
              child: StorySeriesCard(
                series: stories[index],
                onTap: () => _navigateToStoryDetail(stories[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: FadeIn(
          duration: const Duration(milliseconds: 600),
          child: Column(
            children: [
              Icon(
                FeatherIcons.search,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: AppSpacing.large),
              Text(
                'Aradığınız kriterlere uygun hikaye bulunamadı',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Farklı kategoriler deneyebilir veya arama terimini değiştirebilirsiniz.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<StorySeries> _getFilteredSeries(StoryProvider storyProvider) {
    var series = storyProvider.allSeries;
    
    // Kategori filtresi
    if (_selectedCategory != null) {
      series = series.where((s) => s.category == _selectedCategory).toList();
    }
    
    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      series = series.where((s) => 
        s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }
    
    return series;
  }

  void _navigateToStoryDetail(StorySeries series) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StorySeriesDetailScreen(series: series),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardStroke.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          
          Text(
            'Filtreler',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          
          Text(
                         'Kategori',
             style: AppTypography.headlineSmall.copyWith(
               fontWeight: FontWeight.w600,
             ),
          ),
          const SizedBox(height: AppSpacing.medium),
          
          Wrap(
            spacing: AppSpacing.medium,
            runSpacing: AppSpacing.medium,
            children: [
              _buildFilterChip('Tümü', _selectedCategory == null, () {
                setState(() {
                  _selectedCategory = null;
                });
                Navigator.pop(context);
              }),
              ..._categoryNames.entries.map((entry) => 
                _buildFilterChip(
                  entry.value, 
                  _selectedCategory == entry.key, 
                  () {
                    setState(() {
                      _selectedCategory = entry.key;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xLarge),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardStroke.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
} 