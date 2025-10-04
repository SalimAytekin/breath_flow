import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/professional_card.dart';
import '../widgets/simple_banner_ad.dart';
import '../services/asset_manager.dart';
import 'breathing_screen.dart';
import 'sounds_screen.dart';
import 'sleep_screen.dart';
import 'sleep_stories_screen.dart';
import 'journeys_screen.dart';
import 'hrv_measurement_screen.dart';
import 'journal_screen.dart';
import 'sleep_input_screen.dart';
import 'sleep_analytics_screen.dart';

/// 🧭 Professional Explore Screen
/// Redesigned with Deep Night Serenity theme system
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Reklam banner'ı
          const SimpleBannerAd(
            placement: 'explore_screen',
            showPlaceholder: true,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern Header
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: _buildModernHeader(context),
                  ),
                  
                  const SizedBox(height: AppSpacing.large),
                  
                  // Nefes Egzersizleri
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: _buildSection(
                      context,
                      icon: FeatherIcons.wind,
                      title: 'Nefes Egzersizleri',
                      subtitle: 'Stres azaltma ve odaklanma teknikleri',
                      children: [
                        _buildFeatureCard(
                          title: 'Kutu Nefes',
                          subtitle: '4-4-4-4 ritmi ile sakinleşme',
                          imageUrl: AssetManager.coverOcean,
                          onTap: () => _navigateToBreathing(context),
                        ),
                        _buildFeatureCard(
                          title: '4-7-8 Tekniği',
                          subtitle: 'Hızlı uyku için güçlü teknik',
                          imageUrl: AssetManager.coverMeditationBell,
                          onTap: () => _navigateToBreathing(context),
                        ),
                        _buildFeatureCard(
                          title: 'Derin Nefes',
                          subtitle: 'Temel rahatlama egzersizi',
                          imageUrl: AssetManager.coverForest,
                          onTap: () => _navigateToBreathing(context),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xxLarge),
                  
                  // 🎵 Ses Dünyası
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: _buildSection(
                      context,
                      icon: FeatherIcons.music,
                      title: 'Ses Dünyası',
                      subtitle: 'Rahatlatıcı sesler ve karıştırıcı',
                      children: [
                        _buildFeatureCard(
                          title: 'Doğa Sesleri',
                          subtitle: 'Yağmur, okyanus, orman sesleri',
                          imageUrl: AssetManager.coverRain,
                          onTap: () => _navigateToSounds(context),
                        ),
                        _buildFeatureCard(
                          title: 'Ses Karıştırıcı',
                          subtitle: 'Kendi atmosferini yaratın',
                          imageUrl: AssetManager.coverWhiteNoise,
                          onTap: () => _navigateToSounds(context),
                        ),
                        _buildFeatureCard(
                          title: 'Lo-Fi Müzik',
                          subtitle: 'Odaklanma için müzik',
                          imageUrl: AssetManager.coverLofi,
                          onTap: () => _navigateToSounds(context),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xxLarge),
                  
                  // 🌙 Uyku & Rahatlama
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 600),
                    child: _buildSection(
                      context,
                      icon: FeatherIcons.moon,
                      title: 'Uyku & Rahatlama',
                      subtitle: 'Kaliteli uyku için özel içerikler',
                      children: [
                        _buildFeatureCard(
                          title: 'Uyku Hikayeleri',
                          subtitle: 'Sürükleyici hikayelerle uykuya dalış',
                          imageUrl: AssetManager.coverCampfire,
                          onTap: () => _navigateToSleepStories(context),
                        ),
                        _buildFeatureCard(
                          title: 'Uyku Modu',
                          subtitle: 'Gece için özel atmosfer',
                          imageUrl: AssetManager.coverThunder,
                          onTap: () => _navigateToSleep(context),
                        ),
                        _buildFeatureCard(
                          title: 'Uyku Takibi',
                          subtitle: 'Uyku kalitesi analizi',
                          imageUrl: AssetManager.coverMeditationBell,
                          onTap: () => _navigateToSleepInput(context),
                        ),
                      ],
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: _buildSection(
                  context,
                  icon: FeatherIcons.music,
                  title: 'Ses Dünyası',
                  subtitle: 'Rahatlatıcı sesler ve karıştırıcı',
                  children: [
                    _buildFeatureCard(
                      title: 'Doğa Sesleri',
                      subtitle: 'Yağmur, okyanus, orman sesleri',
                      imageUrl: AssetManager.coverRain,
                      onTap: () => _navigateToSounds(context),
                    ),
                    _buildFeatureCard(
                      title: 'Ses Karıştırıcı',
                      subtitle: 'Kendi atmosferini yaratın',
                      imageUrl: AssetManager.coverWhiteNoise,
                      onTap: () => _navigateToSounds(context),
                    ),
                    _buildFeatureCard(
                      title: 'Lo-Fi Müzik',
                      subtitle: 'Odaklanma için müzik',
                      imageUrl: AssetManager.coverLofi,
                      onTap: () => _navigateToSounds(context),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxLarge),
              
              // 🌙 Uyku & Rahatlama
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 600),
                child: _buildSection(
                  context,
                  icon: FeatherIcons.moon,
                  title: 'Uyku & Rahatlama',
                  subtitle: 'Kaliteli uyku için özel içerikler',
                  children: [
                    _buildFeatureCard(
                      title: 'Uyku Hikayeleri',
                      subtitle: 'Sürükleyici hikayelerle uykuya dalış',
                      imageUrl: AssetManager.coverCampfire,
                      onTap: () => _navigateToSleepStories(context),
                    ),
                    _buildFeatureCard(
                      title: 'Uyku Modu',
                      subtitle: 'Gece için özel atmosfer',
                      imageUrl: AssetManager.coverThunder,
                      onTap: () => _navigateToSleep(context),
                    ),
                    _buildFeatureCard(
                      title: 'Uyku Takibi',
                      subtitle: 'Uyku kalitesi analizi',
                      imageUrl: AssetManager.coverMeditationBell,
                      onTap: () => _navigateToSleepInput(context),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxLarge),
              
              // 📊 Analiz & Takip
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 800),
                child: _buildSection(
                  context,
                  icon: FeatherIcons.barChart2,
                  title: 'Analiz & Takip',
                  subtitle: 'İlerlemenizi takip edin ve analiz edin',
                  children: [
                    _buildFeatureCard(
                      title: 'HRV Ölçümü',
                      subtitle: 'Stres seviyesi ölçümü',
                      imageUrl: AssetManager.coverLofi,
                      onTap: () => _navigateToHRV(context),
                    ),
                    _buildFeatureCard(
                      title: 'Kişisel Günlük',
                      subtitle: 'Duygularınızı kaydedin',
                      imageUrl: AssetManager.coverRain,
                      onTap: () => _navigateToJournal(context),
                    ),
                    _buildFeatureCard(
                      title: 'Meditasyon Yolculukları',
                      subtitle: 'Yapılandırılmış programlar',
                      imageUrl: AssetManager.coverForest,
                      onTap: () => _navigateToJourneys(context),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// 🧭 Professional Header with Glass Effect
  Widget _buildProfessionalHeader(BuildContext context) {
    return ProfessionalCard(
      cardType: CardType.glass,
      padding: AppSpacing.cardPaddingAll,
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryAccent.withOpacity(0.2),
                  AppColors.primaryAccent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            child: Icon(
              FeatherIcons.compass,
              color: AppColors.primaryAccent,
              size: AppSpacing.iconLarge,
            ),
          ),
          
          const SizedBox(width: AppSpacing.large),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keşfet',
                  style: AppTypography.displaySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.tiny),
                Text(
                  'Tüm özellikler ve içerikler burada',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.primaryAccent,
                    size: AppTypography.displaySmall.fontSize,
                  ),
                  const SizedBox(width: AppSpacing.medium),
              Text(title, style: AppTypography.displaySmall),
                ],
              ),
              const SizedBox(height: AppSpacing.tiny),
              Text(subtitle,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        SizedBox(
          height: 220, // Give a fixed height for horizontal scrolling cards
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.9, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
          child: ListView.separated(
            itemCount: children.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.medium),
            itemBuilder: (context, index) => children[index],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 160, // Fixed width for horizontal items
      child: FeatureCard(
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        onTap: onTap,
      ),
    );
  }

  // 🚀 Navigation Methods
  void _navigateToBreathing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BreathingScreen(),
      ),
    );
  }

  void _navigateToSounds(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SoundsScreen(),
      ),
    );
  }

  void _navigateToSleep(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SleepScreen(),
      ),
    );
  }

  void _navigateToSleepStories(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SleepStoriesScreen(),
      ),
    );
  }

  void _navigateToJourneys(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JourneysScreen(),
      ),
    );
  }

  void _navigateToHRV(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HRVMeasurementScreen(),
      ),
    );
  }

  void _navigateToJournal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const JournalScreen(),
      ),
    );
  }

  void _navigateToSleepInput(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SleepInputScreen(),
      ),
    );
  }
}