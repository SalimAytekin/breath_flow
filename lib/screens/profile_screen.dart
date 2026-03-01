import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'package:breathe_flow/constants/app_typography.dart';
import 'package:breathe_flow/widgets/legal_dialogs.dart';
import '../constants/app_strings.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/professional_card.dart';
import '../widgets/global_background.dart';
import '../screens/favorites_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../services/notification_service.dart';
import '../widgets/smart_premium_dialog.dart';
import '../providers/premium_provider.dart';
import '../models/premium_trigger.dart';

/// 👤 Professional Profile Screen
/// Redesigned with Deep Night Serenity theme system
/// Simplified - No authentication needed (local-only data)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildProfileView(context);
  }
  
  /// Builds profile view with settings and favorites
  Widget _buildProfileView(BuildContext context) {
    return GlobalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: AppSpacing.pagePadding,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: Center(
                    child: Text(
                      AppStrings.settingsTitle,
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                
                // 👤 Kullanıcı Bilgisi Kartı veya Giriş Yap Butonu
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    // Misafir kullanıcı için giriş yap kartı göster
                    if (!authProvider.isAuthenticated) {
                      return FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: const Duration(milliseconds: 20),
                        child: _buildCosmicCard(
                          verticalOffset: 0.0,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryAccent.withOpacity(0.4),
                                          AppColors.primaryAccent.withOpacity(0.15),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: AppColors.primaryAccent.withOpacity(0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: AppColors.textSecondary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.medium),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'guestUser'.tr(),
                                          style: AppTypography.titleMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppStrings.profileWelcome,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              // "İlerlemenizi kaybetmemek için" + "Giriş Yap" butonu
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryAccent.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppStrings.profileKeepProgress,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _showLoginPrompt(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryAccent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        minimumSize: Size.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        'loginOrRegister'.tr(),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    final user = authProvider.user;
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 20),
                      child: ProfessionalCard(
                        cardType: CardType.glass,
                        padding: AppSpacing.cardPaddingAll,
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryAccent,
                                    AppColors.primaryAccent.withOpacity(0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: AppColors.primaryAccent.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: user?.photoURL != null && user!.photoURL!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        user.photoURL!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildAvatarIcon(user.email),
                                      ),
                                    )
                                  : _buildAvatarIcon(user?.email),
                            ),
                            const SizedBox(width: AppSpacing.medium),
                            // Kullanıcı bilgileri
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.displayName ?? user?.email?.split('@').first ?? 'Kullanıcı',
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? '',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Premium badge
                            Consumer<PremiumProvider>(
                              builder: (context, premiumProvider, _) {
                                if (!premiumProvider.isPremiumUser) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.amber,
                                        Colors.orange,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        FeatherIcons.star,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'PRO',
                                        style: AppTypography.caption.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.medium),
                
                // 🎉 Premium Butonu
                Consumer<PremiumProvider>(
                  builder: (context, premiumProvider, child) {
                    if (premiumProvider.isPremiumUser) {
                      return const SizedBox.shrink(); // Premium kullanıcıya gösterme
                    }
                    
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 25),
                      child: GestureDetector(
                        onTap: () {
                          // Hazır trigger'lardan birini kullan
                          final triggers = PremiumTrigger.predefinedTriggers;
                          if (triggers.isNotEmpty) {
                            SmartPremiumDialog.show(context, triggers.first);
                          }
                        },
                        child: _buildCosmicCard(
                          verticalOffset: 200.0,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.small),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                                ),
                                child: const Icon(
                                  FeatherIcons.star,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.medium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '⭐ ${AppStrings.premiumDeepRelax}',
                                      style: AppTypography.titleMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppStrings.premiumDeepRelaxDesc,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                FeatherIcons.arrowRight,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.medium),
                
                // Satın Almaları Geri Yükle butonu en alta taşındı
                
                // Favoriler bölümü
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 50),
                  child: _buildPreferencesSection(context),
                ),
                
                const SizedBox(height: AppSpacing.large),
                
                // Ayarlar kartı
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: _buildCosmicCard(
                    verticalOffset: 600.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FeatherIcons.settings,
                              color: AppColors.primaryAccent,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.small),
                            Text(
                              AppStrings.settings,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Consumer<UserPreferencesProvider>(
                          builder: (context, userPrefs, child) {
                            return _buildSettingItem(
                              icon: FeatherIcons.bell,
                              title: AppStrings.notifications,
                              subtitle: userPrefs.notificationsEnabled ? AppStrings.notificationsOn : AppStrings.notificationsOff,
                              onTap: () {
                                _showNotificationSettings(context, userPrefs);
                              },
                            );
                          },
                        ),
                        const Divider(height: AppSpacing.large),
                        // 🌍 Dil Seçimi
                        _buildSettingItem(
                          icon: FeatherIcons.globe,
                          title: 'language'.tr(),
                          subtitle: AppStrings.languageNativeName,
                          onTap: () {
                            _showLanguageSelector(context);
                          },
                        ),
                        const Divider(height: AppSpacing.large),
                        _buildSettingItem(
                          icon: FeatherIcons.alertTriangle,
                          title: AppStrings.healthWarning,
                          subtitle: AppStrings.healthWarningSubtitle,
                          onTap: () {
                            _showHealthWarning(context);
                          },
                        ),
                        const Divider(height: AppSpacing.large),
                        _buildSettingItem(
                          icon: FeatherIcons.shield,
                          title: AppStrings.privacyPolicy,
                          subtitle: AppStrings.privacyPolicySubtitle,
                          onTap: () {
                            _showPrivacyPolicy(context);
                          },
                        ),
                        const Divider(height: AppSpacing.large),
                        _buildSettingItem(
                          icon: FeatherIcons.fileText,
                          title: AppStrings.termsOfService,
                          subtitle: AppStrings.termsOfServiceSubtitle,
                          onTap: () {
                            _showTermsOfService(context);
                          },
                        ),
                        // 🔧 Debug butonu (sadece debug modunda)
                        if (kDebugMode) ...[
                          const Divider(height: AppSpacing.large),
                          _buildSettingItem(
                            icon: FeatherIcons.settings,
                            title: 'Premium Debug',
                            subtitle: 'Premium durumunu kontrol et',
                            onTap: () {
                              _showPremiumDebug(context);
                            },
                          ),
                        ],
                        const Divider(height: AppSpacing.large),
                        _buildSettingItem(
                          icon: FeatherIcons.mail,
                          title: AppStrings.contact,
                          subtitle: AppStrings.contactSubtitle,
                          onTap: () {
                            _showContactDialog(context);
                          },
                        ),
                        const Divider(height: AppSpacing.large),
                        _buildSettingItem(
                          icon: FeatherIcons.info,
                          title: AppStrings.about,
                          subtitle: AppStrings.version,
                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.large),
                
                // 🚪 Çıkış Yap Butonu
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (!authProvider.isAuthenticated) {
                      return const SizedBox.shrink();
                    }
                    
                    return Column(
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          delay: const Duration(milliseconds: 150),
                          child: GestureDetector(
                            onTap: () => _showLogoutConfirmation(context, authProvider),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.medium),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FeatherIcons.logOut,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.small),
                                  Text(
                                    AppStrings.logout,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        // 🔄 Satın Almaları Geri Yükle (Text Link)
                        FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          delay: const Duration(milliseconds: 200),
                          child: TextButton(
                            onPressed: () async {
                              final premiumProvider = context.read<PremiumProvider>();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppStrings.restoringPurchases),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              await premiumProvider.restorePurchases();
                              if (premiumProvider.isPremiumUser) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppStrings.premiumRestored),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppStrings.noActiveSubscription),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              AppStrings.restorePurchases,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary.withOpacity(0.8),
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.textSecondary.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.large),
                        // 🗑️ Hesabı Sil Butonu
                        FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          delay: const Duration(milliseconds: 250),
                          child: TextButton(
                            onPressed: () => _showDeleteAccountConfirmation(context, authProvider),
                            child: Text(
                              AppStrings.deleteAccountTitle,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.error.withOpacity(0.8),
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.error.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: AppSpacing.xxLarge),
              ],
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }

  /// 🌌 Kozmik gradient arka planlı kart wrapper'ı
  Widget _buildCosmicCard({
    required Widget child,
    double verticalOffset = 0.0,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    BorderRadius? borderRadius,
  }) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLarge);
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAccent.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                // Kozmik gradient arka plan
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CosmicGradientPainter(
                      animationValue: _shimmerController.value,
                      verticalOffset: verticalOffset,
                    ),
                  ),
                ),
                // Glassmorphism overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      border: Border.all(
                        color: AppColors.primaryAccent.withOpacity(0.15),
                        width: 1,
                      ),
                      borderRadius: radius,
                    ),
                  ),
                ),
                // İçerik
                Padding(
                  padding: padding,
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Bildirim ayarları dialog'u
  void _showNotificationSettings(BuildContext context, UserPreferencesProvider userPrefs) {
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Icon(FeatherIcons.bell, color: AppColors.primaryAccent, size: 24),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(child: Text(AppStrings.notificationSettings)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.dailyReminderMessage,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.large),
              SwitchListTile(
                value: userPrefs.notificationsEnabled,
                onChanged: (value) async {
                  await userPrefs.setNotificationsEnabled(value);
                  setState(() {});
                  
                  if (value) {
                    // İzin isteme
                    final hasPermission = await NotificationService.instance.requestPermissions();
                    if (hasPermission) {
                      // Test bildirimi göster
                      await NotificationService.instance.showTestNotification(
                        title: AppStrings.breatheFlowApp,
                        body: AppStrings.notificationsActive,
                      );
                    }
                  } else {
                    // Bildirimleri kapat
                    await NotificationService.instance.cancelAllReminders();
                  }
                },
                title: Text(
                  AppStrings.reminders,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  userPrefs.notificationsEnabled
                      ? AppStrings.dailyRemindersActive
                      : AppStrings.notificationsClosed,
                  style: AppTypography.caption,
                ),
                activeColor: AppColors.primaryAccent,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                AppStrings.notificationInfo,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
              child: Text(AppStrings.ok),
            ),
          ],
        ),
      ),
    );
  }

  /// Ayar öğesi oluşturur
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FeatherIcons.chevronRight,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the favorites section - Premium kart tasarımı
  Widget _buildPreferencesSection(BuildContext context) {
    return Consumer<UserPreferencesProvider>(
      builder: (context, userPrefs, child) {
        final favoriteExercisesCount = userPrefs.favoriteExerciseIds.length;
        final favoriteSoundsCount = userPrefs.favoriteSoundIds.length;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.tiny),
              child: Text(AppStrings.myFavorites, style: AppTypography.headlineMedium),
            ),
            const SizedBox(height: AppSpacing.large),
            
            // Birleşik Favori Kartı
            _buildUnifiedFavoriteCard(
              context: context,
              soundsCount: favoriteSoundsCount,
              exercisesCount: favoriteExercisesCount,
              onTap: () => _navigateToFavoritesScreen(context),
            ),
          ],
        );
      },
    );
  }

  /// Birleşik favori kartı - tek satırda ses ve egzersizler
  Widget _buildUnifiedFavoriteCard({
    required BuildContext context,
    required int soundsCount,
    required int exercisesCount,
    required VoidCallback onTap,
  }) {
    final totalCount = soundsCount + exercisesCount;
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 400 ? 22.0 : 28.0;
    final titleFontSize = screenWidth < 400 ? 15.0 : (screenWidth < 500 ? 17.0 : 18.0);
    
    return GestureDetector(
      onTap: onTap,
      child: _buildCosmicCard(
        verticalOffset: 400.0,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Icon(FeatherIcons.heart, color: Colors.white, size: iconSize),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.favoriteSoundsAndExercises,
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalCount > 0 
                        ? '$soundsCount ${AppStrings.soundsLabel}, $exercisesCount ${AppStrings.exercisesLabel}' 
                        : AppStrings.noFavoriteContent,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (totalCount > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 400 ? AppSpacing.small : AppSpacing.medium,
                  vertical: AppSpacing.small,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Text(
                  totalCount.toString(),
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (screenWidth >= 350)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.small),
                child: Icon(
                  FeatherIcons.arrowRight,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Shows the about dialog.
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        title: Row(
      children: [
        Container(
              padding: const EdgeInsets.all(AppSpacing.small),
          decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: const Icon(FeatherIcons.info, color: AppColors.primaryAccent, size: 24),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(child: Text(AppStrings.about)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.breatheFlowApp,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: AppSpacing.tiny),
            Text(
              AppStrings.version,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              AppStrings.aboutDescription,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              AppStrings.copyright,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
            child: Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  /// Favoriler ekranına yönlendir
  void _navigateToFavoritesScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FavoritesScreen(),
      ),
    );
  }

  /// Gizlilik Politikası dialog'u
  void _showPrivacyPolicy(BuildContext context) {
    showPrivacyPolicyDialog(context);
  }

  /// Kullanım Koşulları dialog'u
  void _showTermsOfService(BuildContext context) {
    showTermsOfUseDialog(context);
  }

  /// Sağlık Uyarısı dialog'u
  void _showHealthWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: const Icon(FeatherIcons.alertTriangle, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(child: Text(AppStrings.healthWarning)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.importantSafetyInfo,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                AppStrings.aboutBreathingExercises,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                AppStrings.breathingExercisesWarning,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                AppStrings.sideEffects,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              Container(
                padding: const EdgeInsets.all(AppSpacing.medium),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(FeatherIcons.alertCircle, color: Colors.red, size: 20),
                        const SizedBox(width: AppSpacing.small),
                        Text(
                          AppStrings.doNotUse,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      AppStrings.contraindicationsList,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                AppStrings.safeUsage,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                AppStrings.safeUsageTips,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              Container(
                padding: const EdgeInsets.all(AppSpacing.medium),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Text(
                  AppStrings.medicalToolDisclaimer,
                  style: AppTypography.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
            child: Text(AppStrings.understood),
          ),
        ],
      ),
    );
  }

  /// İletişim dialog'u
  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: const Icon(FeatherIcons.mail, color: AppColors.primaryAccent, size: 24),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(child: Text(AppStrings.contact)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.contactMessage,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.large),
            Row(
              children: [
                Icon(
                  FeatherIcons.mail,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    'dxdiag.app@gmail.com',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              AppStrings.feedbackValuable,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
            child: Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  /// 🚪 Çıkış onay dialog'u
  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Icon(FeatherIcons.logOut, color: AppColors.error, size: 24),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(child: Text(AppStrings.logout)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.logoutConfirmationTitle,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              AppStrings.logoutConfirmationDesc,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Çıkış yap
              await authProvider.signOut();
              
              // Bildirim göster
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('👋 ${AppStrings.logoutSuccess}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
            child: Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }

  /// 🗑️ Hesabı sil onay dialog'u
  void _showDeleteAccountConfirmation(BuildContext context, AuthProvider authProvider) {
    bool isLoading = false;
    String password = '';
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Icon(FeatherIcons.trash2, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Text(
                  AppStrings.deleteAccountTitle,
                  style: AppTypography.titleMedium.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.deleteAccountConfirmationDesc,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.large),
              Text(
                AppStrings.deleteAccountPasswordRequired,
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.small),
              TextField(
                obscureText: true,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: AppStrings.deleteAccountPasswordLabel,
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                  errorText: errorText,
                  filled: true,
                  fillColor: AppColors.background.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    borderSide: BorderSide(color: AppColors.primaryAccent.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    borderSide: BorderSide(color: AppColors.primaryAccent.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    borderSide: BorderSide(color: AppColors.primaryAccent),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    password = value;
                    errorText = null;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.deleteAccountCancel,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading || password.isEmpty
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                        errorText = null;
                      });

                      final success = await authProvider.deleteAccount(password);

                      if (success) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('👋 ${AppStrings.deleteAccountSuccess}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        setState(() {
                          isLoading = false;
                          errorText = authProvider.errorMessage ?? AppStrings.error;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(AppStrings.deleteAccountTitle),
            ),
          ],
        ),
      ),
    );
  }

  /// 🌍 Dil seçici dialog'u
  void _showLanguageSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: const Icon(FeatherIcons.globe, color: AppColors.primaryAccent, size: 24),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(child: Text('language'.tr())),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Türkçe
            _buildLanguageOption(
              context: context,
              dialogContext: dialogContext,
              locale: const Locale('tr', 'TR'),
              flag: '🇹🇷',
              name: 'Türkçe',
              isSelected: context.locale.languageCode == 'tr',
            ),
            const SizedBox(height: AppSpacing.small),
            // English
            _buildLanguageOption(
              context: context,
              dialogContext: dialogContext,
              locale: const Locale('en', 'US'),
              flag: '🇺🇸',
              name: 'English',
              isSelected: context.locale.languageCode == 'en',
            ),
            const SizedBox(height: AppSpacing.small),
            // Español
            _buildLanguageOption(
              context: context,
              dialogContext: dialogContext,
              locale: const Locale('es', 'ES'),
              flag: '🇪🇸',
              name: 'Español',
              isSelected: context.locale.languageCode == 'es',
            ),
            const SizedBox(height: AppSpacing.small),
            // Deutsch
            _buildLanguageOption(
              context: context,
              dialogContext: dialogContext,
              locale: const Locale('de', 'DE'),
              flag: '🇩🇪',
              name: 'Deutsch',
              isSelected: context.locale.languageCode == 'de',
            ),
          ],
        ),
      ),
    );
  }

  /// Dil seçeneği widget'ı
  Widget _buildLanguageOption({
    required BuildContext context,
    required BuildContext dialogContext,
    required Locale locale,
    required String flag,
    required String name,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        context.setLocale(locale);
        Navigator.of(dialogContext).pop();
        
        // Bildirim göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$flag $name'),
            duration: const Duration(seconds: 1),
          ),
        );
        
        // Sayfayı yenile
        setState(() {});
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primaryAccent.withOpacity(0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryAccent 
                : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Text(
                name,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primaryAccent : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                FeatherIcons.check,
                color: AppColors.primaryAccent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
  
  /// Avatar için varsayılan ikon oluştur
  Widget _buildAvatarIcon(String? email) {
    final initial = email?.isNotEmpty == true 
        ? email![0].toUpperCase() 
        : '?';
    return Center(
      child: Text(
        initial,
        style: AppTypography.headlineMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  /// Giriş yap/kayıt ol ekranına yönlendir
  void _showLoginPrompt(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const _LoginRedirectScreen(),
      ),
      (route) => false,
    );
  }
  
  /// 🔧 Premium debug dialog'u
  void _showPremiumDebug(BuildContext context) {
    final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(FeatherIcons.settings, color: AppColors.primaryAccent, size: 24),
            const SizedBox(width: 12),
            Text('Premium Debug', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium durumunu kontrol etmek için butona basın:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                premiumProvider.debugPremiumStatus();
                Navigator.pop(context);
              },
              icon: Icon(FeatherIcons.eye, size: 18),
              label: Text('Durumu Kontrol Et'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Kapat', style: TextStyle(color: AppColors.textTertiary)),
          ),
        ],
      ),
    );
  }
}

/// 🌌 Kozmik gradient arka plan painter — kartların birbirini tamamlayan bütünleşik efekti
class _CosmicGradientPainter extends CustomPainter {
  final double animationValue;
  final double verticalOffset;

  _CosmicGradientPainter({
    required this.animationValue,
    this.verticalOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Ana kozmik gradient — sıcak kahve tonları
    final baseGradient = LinearGradient(
      begin: Alignment(-0.5, -1.0 + verticalOffset * 0.001),
      end: Alignment(0.5, 1.0 + verticalOffset * 0.001),
      colors: [
        const Color(0xFF2A1F18),
        const Color(0xFF3D2B1E),
        const Color(0xFF4A3228),
        const Color(0xFF2E2118),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = baseGradient.createShader(rect));

    // Animasyonlu sıcak orb'lar
    final orbPaint = Paint()..style = PaintingStyle.fill;

    // Orb 1 — amber glow (sol üst)
    final orb1Center = Offset(
      size.width * (0.2 + 0.1 * math.sin(animationValue * 2 * math.pi)),
      size.height * (0.3 + 0.05 * math.cos(animationValue * 2 * math.pi)),
    );
    orbPaint.shader = RadialGradient(
      colors: [
        const Color(0xFFC4956A).withOpacity(0.15),
        const Color(0xFFC4956A).withOpacity(0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: orb1Center, radius: size.width * 0.5));
    canvas.drawCircle(orb1Center, size.width * 0.5, orbPaint);

    // Orb 2 — warm copper (sağ alt)
    final orb2Center = Offset(
      size.width * (0.8 - 0.08 * math.cos(animationValue * 2 * math.pi + 1.5)),
      size.height * (0.6 + 0.04 * math.sin(animationValue * 2 * math.pi + 1.5)),
    );
    orbPaint.shader = RadialGradient(
      colors: [
        const Color(0xFFD4A574).withOpacity(0.12),
        const Color(0xFFD4A574).withOpacity(0.04),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: orb2Center, radius: size.width * 0.4));
    canvas.drawCircle(orb2Center, size.width * 0.4, orbPaint);

    // Orb 3 — deep purple hint (orta)
    final orb3Center = Offset(
      size.width * (0.5 + 0.06 * math.sin(animationValue * 2 * math.pi + 3.0)),
      size.height * (0.4 - 0.03 * math.cos(animationValue * 2 * math.pi + 3.0)),
    );
    orbPaint.shader = RadialGradient(
      colors: [
        const Color(0xFFB8A0D4).withOpacity(0.08),
        const Color(0xFFB8A0D4).withOpacity(0.02),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: orb3Center, radius: size.width * 0.35));
    canvas.drawCircle(orb3Center, size.width * 0.35, orbPaint);

    // Yıldız parıltıları
    final starPaint = Paint()..color = Colors.white;
    final random = math.Random(42); // Sabit seed — her frame aynı pozisyon
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final baseOpacity = 0.1 + random.nextDouble() * 0.25;
      final twinkle = math.sin((animationValue * 2 * math.pi) + i * 0.7);
      final opacity = (baseOpacity * (0.5 + 0.5 * twinkle)).clamp(0.0, 1.0);
      final radius = 0.5 + random.nextDouble() * 1.0;
      starPaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicGradientPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Login ekranına yönlendirme için yardımcı widget
class _LoginRedirectScreen extends StatelessWidget {
  const _LoginRedirectScreen();

  @override
  Widget build(BuildContext context) {
    // AuthWrapper'a geri dön - login ekranını gösterecek
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          // Zaten giriş yapmış, ana ekrana git
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
              (route) => false,
            );
          });
          return const SizedBox.shrink();
        }
        // Login ekranını göster
        return const LoginScreen();
      },
    );
  }
}