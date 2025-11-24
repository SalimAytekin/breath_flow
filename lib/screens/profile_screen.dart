import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../providers/user_preferences_provider.dart';
import '../widgets/professional_card.dart';
import '../widgets/global_background.dart';
import '../screens/favorites_screen.dart';
import '../services/notification_service.dart';

/// 👤 Professional Profile Screen
/// Redesigned with Deep Night Serenity theme system
/// Simplified - No authentication needed (local-only data)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayarlar',
                        style: AppTypography.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        'Uygulama ayarlarınızı ve tercihlerinizi düzenleyin',
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxLarge),
                
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
                  child: ProfessionalCard(
                    cardType: CardType.glass,
                    padding: AppSpacing.cardPaddingAll,
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
                              'Ayarlar',
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
                              title: 'Bildirimler',
                              subtitle: userPrefs.notificationsEnabled ? 'Hatırlatmalar açık' : 'Hatırlatmalar kapalı',
                              onTap: () {
                                _showNotificationSettings(context, userPrefs);
                              },
                            );
                          },
                        ),
                        const Divider(height: AppSpacing.large),
                        _buildSettingItem(
                          icon: FeatherIcons.alertTriangle,
                          title: 'Sağlık Uyarısı',
                          subtitle: 'Önemli güvenlik bilgileri',
                          onTap: () {
                            _showHealthWarning(context);
                          },
                        ),
                        const Divider(height: AppSpacing.large),
                        _buildSettingItem(
                          icon: FeatherIcons.shield,
                          title: 'Gizlilik Politikası',
                          subtitle: 'Verilerinizi nasıl koruyoruz',
                          onTap: () {
                            _showPrivacyPolicy(context);
                          },
                        ),
                        const Divider(height: AppSpacing.large),
                        _buildSettingItem(
                          icon: FeatherIcons.fileText,
                          title: 'Kullanım Koşulları',
                          subtitle: 'Hizmet şartları ve kurallar',
                          onTap: () {
                            _showTermsOfService(context);
                          },
                        ),
                        const Divider(height: AppSpacing.large),
                        _buildSettingItem(
                          icon: FeatherIcons.mail,
                          title: 'İletişim',
                          subtitle: 'Bize ulaşın',
                          onTap: () {
                            _showContactDialog(context);
                          },
                        ),
                        const Divider(height: AppSpacing.large),
                        _buildSettingItem(
                          icon: FeatherIcons.info,
                          title: 'Hakkında',
                          subtitle: 'Versiyon 1.0.0',
                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
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
              const Expanded(child: Text('Bildirim Ayarları')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Günlük nefes egzersizi hatırlatmaları alın.',
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
                        title: 'Breathe Flow',
                        body: 'Bildirimler aktif! Nefes egzersizi hatırlatıcıları için hazırız 🫁',
                      );
                    }
                  } else {
                    // Bildirimleri kapat
                    await NotificationService.instance.cancelAllReminders();
                  }
                },
                title: Text(
                  'Hatırlatmalar',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  userPrefs.notificationsEnabled
                      ? 'Günlük hatırlatmalar aktif'
                      : 'Bildirimler kapalı',
                  style: AppTypography.caption,
                ),
                activeColor: AppColors.primaryAccent,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Bildirimleri açtığınızda günlük hatırlatmalar alacaksınız.',
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
              child: const Text('Tamam'),
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
              child: Text('Favorilerim', style: AppTypography.headlineMedium),
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
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.large),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryAccent.withOpacity(0.8),
              AppColors.primary.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
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
                    'Favori Ses ve Egzersizler',
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
                        ? '$soundsCount ses, $exercisesCount egzersiz' 
                        : 'Henüz favori içerik yok',
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
            const Expanded(child: Text('Hakkında')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breathe Flow',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: AppSpacing.tiny),
            Text(
              'Versiyon 1.0.0',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              'Breathe Flow, nefes egzersizleri, meditasyon ve uyku kalitesini artırmak için tasarlanmış kapsamlı bir zihinsel sağlık uygulamasıdır.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              '© 2024 Breathe Flow. Tüm hakları saklıdır.',
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
            child: const Text('Tamam'),
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
              child: const Icon(FeatherIcons.shield, color: AppColors.primaryAccent, size: 24),
            ),
            const SizedBox(width: AppSpacing.medium),
            const Expanded(child: Text('Gizlilik Politikası')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Veri Toplama ve Kullanımı',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Breathe Flow uygulaması, tüm verilerinizi cihazınızda yerel olarak saklar. Kişisel verileriniz hiçbir sunucuya gönderilmez veya üçüncü taraflarla paylaşılmaz.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Saklanan Veriler',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                '• Nefes egzersizi geçmişi\n• Uyku takip verileri\n• Favori ses ve egzersizler\n• Uygulama tercihleri',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Bildirimler',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Bildirim izni verdiğinizde, sadece yerel hatırlatmalar gönderilir. Bildirimleriniz cihazınızda oluşturulur ve hiçbir veri dışarı çıkmaz.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Reklamlar',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Uygulama, Google AdMob üzerinden reklamlar gösterir. AdMob\'un gizlilik politikası için: https://policies.google.com/privacy',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
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
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Kullanım Koşulları dialog'u
  void _showTermsOfService(BuildContext context) {
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
              child: const Icon(FeatherIcons.fileText, color: AppColors.primaryAccent, size: 24),
            ),
            const SizedBox(width: AppSpacing.medium),
            const Expanded(child: Text('Kullanım Koşulları')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hizmet Kullanımı',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Breathe Flow uygulamasını kullanarak, aşağıdaki koşulları kabul etmiş olursunuz:',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                '1. Uygulama Amacı',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Bu uygulama, zihinsel rahatlama ve nefes egzersizleri için tasarlanmıştır. Tıbbi bir tedavi aracı değildir.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                '2. Sorumluluk Reddi',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Ciddi sağlık sorunlarınız varsa, lütfen bir sağlık uzmanına danışın. Uygulama geliştiricileri, kullanımdan kaynaklanan herhangi bir zarardan sorumlu değildir.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                '3. İçerik Kullanımı',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Uygulamadaki tüm içerikler telif hakkı ile korunmaktadır. İçeriklerin izinsiz kopyalanması veya dağıtılması yasaktır.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                '4. Premium Abonelik',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Premium özellikler, uygulama içi satın alma ile aktif edilir. İptal ve iade politikası, Google Play Store kurallarına tabidir.',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
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
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
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
            const Expanded(child: Text('Sağlık Uyarısı')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ Önemli Güvenlik Bilgileri',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Nefes Egzersizleri Hakkında',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Nefes egzersizleri güçlü tekniklerdir ve bazı kişilerde yan etkiler oluşturabilir:',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                '• Baş dönmesi\n• Hafif sersemlik hissi\n• Karıncalanma\n• Geçici görme bulanıklığı\n• Kalp çarpıntısı',
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
                          'Bu Durumlarda KULLANMAYIN',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      '• Hamilelik\n• Epilepsi\n• Yüksek/düşük tansiyon\n• Kalp rahatsızlıkları\n• Solunum sistemi hastalıkları\n• Panik atak geçmişi\n• Ciddi anksiyete bozuklukları',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Güvenli Kullanım İçin',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                '✓ İlk kez yapıyorsanız oturarak başlayın\n✓ Baş dönmesi hissederseniz hemen durun\n✓ Normal nefes alıp verin\n✓ Araç kullanırken ASLA yapmayın\n✓ Ayakta veya yüksekte yapmayın\n✓ Rahatsızlık hissederseniz doktora danışın',
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
                  '💡 Bu uygulama tıbbi bir tedavi aracı değildir. Ciddi sağlık sorunlarınız varsa mutlaka bir sağlık uzmanına danışın.',
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
            child: const Text('Anladım'),
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
            const Expanded(child: Text('İletişim')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sorularınız veya önerileriniz için bizimle iletişime geçebilirsiniz:',
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
              'Geri bildirimleriniz bizim için çok değerli!',
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
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

}