import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../providers/theme_provider.dart';

/// 🌓 Theme Toggle Widget
/// Beautiful animated theme switcher with Deep Night Serenity styling
class ThemeToggleWidget extends StatefulWidget {
  final ThemeToggleStyle style;
  final bool showLabel;
  final String? customLabel;

  const ThemeToggleWidget({
    super.key,
    this.style = ThemeToggleStyle.toggle,
    this.showLabel = true,
    this.customLabel,
  });

  @override
  State<ThemeToggleWidget> createState() => _ThemeToggleWidgetState();
}

class _ThemeToggleWidgetState extends State<ThemeToggleWidget>
    with TickerProviderStateMixin {
  late AnimationController _toggleController;
  late AnimationController _iconController;
  late Animation<double> _toggleAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    
    _toggleController = AnimationController(
      duration: AppSpacing.animationMedium,
      vsync: this,
    );
    
    _iconController = AnimationController(
      duration: AppSpacing.animationFast,
      vsync: this,
    );
    
    _toggleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _toggleController,
      curve: AppSpacing.easeOutQuart,
    ));
    
    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));
    
    // Set initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      if (themeProvider.isDarkMode) {
        _toggleController.value = 1.0;
      }
    });
  }

  @override
  void dispose() {
    _toggleController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.getCurrentBrightness(context) == Brightness.dark;
        
        switch (widget.style) {
          case ThemeToggleStyle.toggle:
            return _buildToggleSwitch(themeProvider, isDark);
          case ThemeToggleStyle.button:
            return _buildButton(themeProvider, isDark);
          case ThemeToggleStyle.icon:
            return _buildIconButton(themeProvider, isDark);
          case ThemeToggleStyle.card:
            return _buildCard(themeProvider, isDark);
        }
      },
    );
  }

  Widget _buildToggleSwitch(ThemeProvider themeProvider, bool isDark) {
    return AnimatedBuilder(
      animation: _toggleAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _handleToggle(themeProvider),
          child: Container(
            width: 56,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark 
                  ? AppColors.primaryAccent.withOpacity(0.3)
                  : LightAppColors.primaryAccent.withOpacity(0.3),
              border: Border.all(
                color: isDark 
                    ? AppColors.primaryAccent.withOpacity(0.5)
                    : LightAppColors.primaryAccent.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: AppSpacing.animationMedium,
                  curve: AppSpacing.easeOutQuart,
                  left: isDark ? 26 : 2,
                  top: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isDark 
                          ? AppColors.primaryAccent
                          : LightAppColors.primaryAccent,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppColors.shadowMedium : LightAppColors.shadowMedium)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: AppSpacing.animationFast,
                      child: Icon(
                        isDark ? FeatherIcons.moon : FeatherIcons.sun,
                        key: ValueKey(isDark),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(ThemeProvider themeProvider, bool isDark) {
    return AnimatedContainer(
      duration: AppSpacing.animationMedium,
      curve: AppSpacing.easeOutQuart,
      child: ElevatedButton.icon(
        onPressed: () => _handleToggle(themeProvider),
        icon: AnimatedSwitcher(
          duration: AppSpacing.animationFast,
          child: Icon(
            isDark ? FeatherIcons.moon : FeatherIcons.sun,
            key: ValueKey(isDark),
            size: 20,
          ),
        ),
        label: Text(
          widget.customLabel ?? (isDark ? 'Koyu Tema' : 'Açık Tema'),
          style: AppTypography.labelMedium,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark 
              ? AppColors.surfaceElevated
              : LightAppColors.surfaceElevated,
          foregroundColor: isDark 
              ? AppColors.textPrimary
              : LightAppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            side: BorderSide(
              color: isDark 
                  ? AppColors.border
                  : LightAppColors.border,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.large,
            vertical: AppSpacing.medium,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(ThemeProvider themeProvider, bool isDark) {
    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_iconAnimation.value * 0.1),
          child: IconButton(
            onPressed: () => _handleToggle(themeProvider),
            icon: AnimatedSwitcher(
              duration: AppSpacing.animationFast,
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: animation,
                  child: child,
                );
              },
              child: Icon(
                isDark ? FeatherIcons.moon : FeatherIcons.sun,
                key: ValueKey(isDark),
                color: isDark 
                    ? AppColors.primaryAccent
                    : LightAppColors.primaryAccent,
                size: 24,
              ),
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark 
                  ? AppColors.surfaceElevated
                  : LightAppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                side: BorderSide(
                  color: isDark 
                      ? AppColors.border
                      : LightAppColors.border,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.medium),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(ThemeProvider themeProvider, bool isDark) {
    return AnimatedContainer(
      duration: AppSpacing.animationMedium,
      curve: AppSpacing.easeOutQuart,
      padding: AppSpacing.cardPaddingAll,
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.cardBackground
            : LightAppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: isDark 
              ? AppColors.border
              : LightAppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.shadowLight : LightAppColors.shadowLight)
                .withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _handleToggle(themeProvider),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.small),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: AppSpacing.animationFast,
                child: Icon(
                  isDark ? FeatherIcons.moon : FeatherIcons.sun,
                  key: ValueKey(isDark),
                  color: isDark 
                      ? AppColors.primaryAccent
                      : LightAppColors.primaryAccent,
                  size: 20,
                ),
              ),
              if (widget.showLabel) ...[
                const SizedBox(width: AppSpacing.small),
                Text(
                  widget.customLabel ?? (isDark ? 'Koyu Tema' : 'Açık Tema'),
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark 
                        ? AppColors.textPrimary
                        : LightAppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleToggle(ThemeProvider themeProvider) {
    _iconController.forward().then((_) {
      _iconController.reverse();
    });
    
    themeProvider.toggleTheme();
  }
}

/// 🎨 Theme Toggle Styles
enum ThemeToggleStyle {
  toggle,
  button,
  icon,
  card,
}

/// 🌓 Theme Selection Dialog
class ThemeSelectionDialog extends StatelessWidget {
  const ThemeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.getCurrentBrightness(context) == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark 
              ? AppColors.cardBackground
              : LightAppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            side: BorderSide(
              color: isDark 
                  ? AppColors.border
                  : LightAppColors.border,
              width: 1,
            ),
          ),
          title: Text(
            'Tema Seçimi',
            style: AppTypography.headlineSmall.copyWith(
              color: isDark 
                  ? AppColors.textPrimary
                  : LightAppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.light,
                'Açık Tema',
                FeatherIcons.sun,
                isDark,
              ),
              const SizedBox(height: AppSpacing.small),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.dark,
                'Koyu Tema',
                FeatherIcons.moon,
                isDark,
              ),
              const SizedBox(height: AppSpacing.small),
              _buildThemeOption(
                context,
                themeProvider,
                ThemeMode.system,
                'Sistem Ayarı',
                FeatherIcons.smartphone,
                isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    String title,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    
    return AnimatedContainer(
      duration: AppSpacing.animationMedium,
      curve: AppSpacing.easeOutQuart,
      decoration: BoxDecoration(
        color: isSelected 
            ? (isDark ? AppColors.primaryAccent.withOpacity(0.1) : LightAppColors.primaryAccent.withOpacity(0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: isSelected 
              ? (isDark ? AppColors.primaryAccent : LightAppColors.primaryAccent)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
              ? (isDark ? AppColors.primaryAccent : LightAppColors.primaryAccent)
              : (isDark ? AppColors.textSecondary : LightAppColors.textSecondary),
        ),
        title: Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected 
                ? (isDark ? AppColors.primaryAccent : LightAppColors.primaryAccent)
                : (isDark ? AppColors.textPrimary : LightAppColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isSelected 
            ? Icon(
                FeatherIcons.check,
                color: isDark ? AppColors.primaryAccent : LightAppColors.primaryAccent,
                size: 20,
              )
            : null,
        onTap: () {
          themeProvider.setThemeMode(mode);
          Navigator.of(context).pop();
        },
      ),
    );
  }
} 