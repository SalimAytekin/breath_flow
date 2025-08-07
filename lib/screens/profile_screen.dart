import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../providers/theme_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../widgets/professional_card.dart';
import '../widgets/theme_toggle_widget.dart';
import '../widgets/professional_button.dart';
import '../widgets/profile_photo_widget.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../test_video_screen.dart';
import '../models/sound_item.dart';

/// 👤 Professional Profile Screen
/// Redesigned with Deep Night Serenity theme system
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    // We will use a StreamBuilder to check the auth state.
    return StreamBuilder(
      stream: _auth.user,
      builder: (context, snapshot) {
        // If the user is not logged in, show a call to action.
        if (!snapshot.hasData) {
          return _buildLoggedOutView(context);
        }
        
        // If the user is logged in, show the full profile.
        return _buildLoggedInView(context);
      },
    );
  }

  /// Builds the view for a logged-in user.
  Widget _buildLoggedInView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Uses the main navigation's background.
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: _buildProfessionalHeader(context),
              ),
              const SizedBox(height: AppSpacing.xxLarge),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: _buildStatsOverview(context),
              ),
              const SizedBox(height: AppSpacing.xxLarge),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 600),
                child: _buildSettingsSection(context),
              ),
              const SizedBox(height: AppSpacing.xLarge),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 800),
                child: Center(
                  child: ProfessionalButton(
                    text: "Çıkış Yap",
                    onPressed: () async {
                      await _auth.signOut();
                    },
                    icon: FeatherIcons.logOut,
                    buttonType: ButtonType.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Builds a simple view for logged-out users, prompting them to log in.
  Widget _buildLoggedOutView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(FeatherIcons.logIn, size: 60, color: AppColors.primaryAccent),
              const SizedBox(height: 20),
              Text(
                'Tüm özelliklere erişmek için giriş yapın.',
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'İlerlemenizi kaydedin, istatistiklerinizi görün ve daha fazlası.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 30),
              ProfessionalButton(
                text: "Giriş Yap veya Kayıt Ol",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                icon: FeatherIcons.arrowRight,
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the professional header for the profile.
  Widget _buildProfessionalHeader(BuildContext context) {
    final user = _auth.user.asBroadcastStream().first;
    return ProfessionalCard(
      cardType: CardType.glass,
      padding: AppSpacing.cardPaddingAll,
      child: Row(
        children: [
          FutureBuilder(
            future: user,
            builder: (context, snapshot) {
              return ProfilePhotoWidget(
                initialPhotoURL: snapshot.data?.photoURL,
                size: 80,
                isEditable: true,
                onPhotoUpdated: () {
                  setState(() {});
                },
              );
            },
          ),
          const SizedBox(width: AppSpacing.large),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: user,
                  builder: (context, snapshot) {
                     return Text(
                      snapshot.data?.email ?? 'Kullanıcı',
                      style: AppTypography.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    );
                  }
                ),
                const SizedBox(height: AppSpacing.tiny),
                Text(
                  'İlerlemenizi takip edin',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the statistics overview section.
  Widget _buildStatsOverview(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.tiny),
              child: Text('İstatistikler', style: AppTypography.headlineMedium),
            ),
            const SizedBox(height: AppSpacing.large),
            ProfessionalCard(
              cardType: CardType.elevated,
              child: Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Toplam Seans',
                      value: '${userPrefs.totalSessions}',
                      icon: FeatherIcons.play,
                      iconColor: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: StatsCard(
                      title: 'Toplam Süre',
                      value: userPrefs.totalTimeText,
                      icon: FeatherIcons.clock,
                      iconColor: AppColors.focus,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the settings section.
  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.tiny),
          child: Text('Ayarlar', style: AppTypography.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.large),
        ProfessionalCard(
          cardType: CardType.standard,
          child: Column(
            children: [
              _buildThemeSettingItem(context),
              const Divider(),
              _buildVideoTestItem(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the theme setting item with a toggle.
  Widget _buildThemeSettingItem(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.getCurrentBrightness(context) == Brightness.dark;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(AppSpacing.small),
            decoration: BoxDecoration(
              color: AppColors.sleep.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Icon(
              isDark ? FeatherIcons.moon : FeatherIcons.sun,
              color: AppColors.sleep,
              size: AppSpacing.iconMedium,
            ),
          ),
          title: Text('Tema', style: AppTypography.labelLarge),
          subtitle: Text(
            isDark ? 'Koyu tema aktif' : 'Açık tema aktif',
            style: AppTypography.caption,
          ),
          trailing: const ThemeToggleWidget(
            style: ThemeToggleStyle.toggle,
            showLabel: false,
          ),
        );
      },
    );
  }

  /// Builds the video test item.
  Widget _buildVideoTestItem(BuildContext context) {
    // Test için "Çadırda Yağmur" sound item'ını buluyoruz
    final testSound = SoundItem(
      id: 'test_video',
      name: 'Çadırda Yağmur',
      description: 'Huzurlu bir kamp anı',
      imagePath: 'assets/images/sounds/rain.jpg',
      assetPath: 'assets/audio/rain_on_tent.mp3',
      videoPath: 'assets/videos/rain_drop.mp4',
      icon: FeatherIcons.umbrella,
      color: const Color(0xFF4A90A4),
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.small),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        child: Icon(
          FeatherIcons.video,
          color: AppColors.primary,
          size: AppSpacing.iconMedium,
        ),
      ),
      title: Text('İmmersive Video Test', style: AppTypography.labelLarge),
      subtitle: Text(
        'Video + Audio + Timer Player',
        style: AppTypography.caption,
      ),
      trailing: Icon(FeatherIcons.chevronRight),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestVideoScreen(sound: testSound),
          ),
        );
      },
    );
  }
}

// A simple stats card for the overview section.
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: Icon(icon, color: iconColor, size: AppSpacing.iconLarge),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTypography.headlineSmall),
              Text(title, style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
} 