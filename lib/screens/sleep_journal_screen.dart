import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../widgets/global_background.dart';
import '../widgets/professional_app_bar.dart';
import 'package:provider/provider.dart';
import '../providers/premium_provider.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import '../widgets/smart_premium_dialog.dart';
import '../models/premium_trigger.dart';
import '../ui/components/ad_container.dart';

/// 📝 Premium Uyku Günlüğü Ekranı
/// Kullanıcıların uyku notları, rüyalar ve gözlemlerini kaydetmesini sağlar
class SleepJournalScreen extends StatefulWidget {
  const SleepJournalScreen({super.key});

  @override
  State<SleepJournalScreen> createState() => _SleepJournalScreenState();
}

class _SleepJournalScreenState extends State<SleepJournalScreen> 
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _pulseAnimation;
  
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dreamController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedMood = 'neutral';
  int? _editingIndex; // Düzenleme modu için
  bool _isSaving = false;
  
  // Kalıcı kayıt listesi (SharedPreferences ile)
  List<Map<String, dynamic>> _journalEntries = [];
  
  final List<Map<String, dynamic>> _moods = [
    {'id': 'great', 'emoji': '😊', 'label': AppStrings.greatMoodText, 'color': AppColors.success},
    {'id': 'good', 'emoji': '🙂', 'label': AppStrings.goodMoodText, 'color': AppColors.primary},
    {'id': 'neutral', 'emoji': '😐', 'label': AppStrings.neutralMoodText, 'color': AppColors.focus},
    {'id': 'tired', 'emoji': '😴', 'label': AppStrings.tiredMoodText, 'color': AppColors.warning},
    {'id': 'bad', 'emoji': '😔', 'label': AppStrings.badMoodText, 'color': AppColors.error},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Animation Controllers
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutQuart),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Kayıtları yükle (local + Firestore)
    _loadJournalEntries();
    _syncFromJournalProvider(); // 🔄 Firestore'dan da çek
    
    // Start animations
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }
  
  /// 🔄 JournalProvider'dan (Firestore) kayıtları çek ve local ile birleştir
  Future<void> _syncFromJournalProvider() async {
    try {
      final journalProvider = context.read<JournalProvider>();
      
      // Önce Firestore'dan full sync yap
      await journalProvider.performFullSync();
      
      // JournalProvider'daki kayıtları al
      final providerEntries = journalProvider.entries;
      
      if (providerEntries.isEmpty) return;
      
      // Local'de olmayan kayıtları ekle
      bool hasNewEntries = false;
      for (final entry in providerEntries) {
        final existsLocally = _journalEntries.any((local) {
          final localDate = local['date'] as DateTime;
          return localDate.year == entry.date.year &&
                 localDate.month == entry.date.month &&
                 localDate.day == entry.date.day;
        });
        
        if (!existsLocally) {
          _journalEntries.add({
            'date': entry.date,
            'mood': entry.mood,
            'dream': entry.dream,
            'note': entry.note,
            'timestamp': entry.date,
          });
          hasNewEntries = true;
        }
      }
      
      if (hasNewEntries) {
        // Tarihe göre sırala (en yeni önce)
        _journalEntries.sort((a, b) => 
          (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        
        await _saveToStorage();
        if (mounted) setState(() {});
        if (kDebugMode) debugPrint('✅ JournalProvider → SleepJournal sync tamamlandı');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ JournalProvider → SleepJournal sync hatası: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _noteController.dispose();
    _dreamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Klavyeyi kapat
        FocusScope.of(context).unfocus();
      },
      child: GlobalBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: ProfessionalAppBar(
            scrollController: _scrollController,
            title: AppStrings.sleepJournalTitleText,
            actions: [
              IconButton(
                icon: Icon(FeatherIcons.list, color: Colors.white),
                onPressed: () => _showJournalHistory(context),
                tooltip: AppStrings.pastRecordsTitleText,
              ),
            ],
          ),
          body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.large,
                    MediaQuery.of(context).padding.top + kToolbarHeight + AppSpacing.large,
                    AppSpacing.large,
                    AppSpacing.large,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Premium Header
                      _buildPremiumHeader(),
                      
                      const SizedBox(height: AppSpacing.large),
                      
                      // 🔥 Streak + Mood İstatistikleri
                      _buildStreakCard(),
                      
                      const SizedBox(height: AppSpacing.large),
                      
                      // 💰 Banner Reklam - Natural placement (header sonrası)
                      // Kullanıcı engage olmuş, eCPM daha yüksek olacak
                      const AdContainer(
                        placement: 'sleep_journal',
                        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      ),
                      
                      const SizedBox(height: AppSpacing.large),
                      
                      // Date Selection
                      _buildDateSection(),
                      
                      const SizedBox(height: AppSpacing.large),
                      
                      // Mood Selection
                      _buildMoodSection(),
                      
                      const SizedBox(height: AppSpacing.large),
                      
                      // Dream Note
                      _buildDreamSection(),
                      
                      const SizedBox(height: AppSpacing.large),
                      
                      // General Note
                      _buildNoteSection(),
                      
                      const SizedBox(height: AppSpacing.large),
                      
                      // Tips Card
                      _buildTipsCard(),
                      
                      const SizedBox(height: AppSpacing.xLarge),
                      
                      // Save Button
                      _buildSaveButton(),
                      
                      const SizedBox(height: AppSpacing.large),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ),
      ),
    );
  }

  // 🌟 Kompakt Header — minimal, soft
  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1F1A),
            Color(0xFF1E1410),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFD4AF37).withOpacity(0.15),
            ),
            child: const Icon(
              FeatherIcons.bookOpen,
              color: Color(0xFFD4AF37),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.sleepJournalTitleText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.recordDreamsAndNotesText,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📅 Tarih Seçimi — minimal, soft
  Widget _buildDateSection() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: AppColors.primaryAccent.withOpacity(0.12),
              ),
              child: Icon(
                FeatherIcons.calendar,
                color: AppColors.primaryAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.dateLabelText,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(selectedDate),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              FeatherIcons.chevronRight,
              color: AppColors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // 😊 Mood Seçimi — minimal, soft
  Widget _buildMoodSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1F1A),
            Color(0xFF1E1410),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FeatherIcons.smile, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.howDidYouFeel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: _moods.map((mood) {
              final isSelected = selectedMood == mood['id'];
              final moodColor = mood['color'] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = mood['id'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? moodColor.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? moodColor.withOpacity(0.4)
                            : const Color(0xFFD4AF37).withOpacity(0.2),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          mood['emoji'],
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood['label'],
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected
                                ? moodColor
                                : AppColors.textTertiary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 💭 Rüya Notları — minimal, soft
  Widget _buildDreamSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1F1A),
            Color(0xFF1E1410),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FeatherIcons.cloud, color: AppColors.sleep, size: 16),
              const SizedBox(width: 8),
              Text(
                AppStrings.dreamNotesLabelText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dreamController,
            maxLines: null,
            minLines: 3,
            maxLength: 500,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.dreamNotesPlaceholderText,
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.sleep.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📝 Genel Notlar — minimal, soft
  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D1F1A),
            Color(0xFF1E1410),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FeatherIcons.edit3, color: AppColors.energy, size: 16),
              const SizedBox(width: 8),
              Text(
                AppStrings.generalNotesLabelText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: null,
            minLines: 3,
            maxLength: 500,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.generalNotesPlaceholderText,
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.energy.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // � Streak + Mood İstatistikleri
  Widget _buildStreakCard() {
    // Streak hesapla — bugünden geriye kaç gün üst üste kayıt var
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final hasEntry = _journalEntries.any((e) {
        final d = e['date'] as DateTime;
        return d.year == checkDate.year && d.month == checkDate.month && d.day == checkDate.day;
      });
      if (hasEntry) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    // Son 7 günün mood dağılımı
    final last7Days = _journalEntries.where((e) {
      final d = e['date'] as DateTime;
      return now.difference(d).inDays < 7;
    }).toList();

    final moodCounts = <String, int>{};
    for (final e in last7Days) {
      final m = e['mood'] as String;
      moodCounts[m] = (moodCounts[m] ?? 0) + 1;
    }

    // Motivasyon mesajı
    String motivation;
    IconData motivationIcon;
    Color motivationColor;
    if (streak >= 7) {
      motivation = AppStrings.streakGreatMsg(streak);
      motivationIcon = FeatherIcons.award;
      motivationColor = AppColors.success;
    } else if (streak >= 3) {
      motivation = AppStrings.streakGoodMsg(streak);
      motivationIcon = FeatherIcons.trendingUp;
      motivationColor = AppColors.focus;
    } else if (streak == 1) {
      motivation = AppStrings.streakDailyMsg;
      motivationIcon = FeatherIcons.star;
      motivationColor = AppColors.primary;
    } else {
      motivation = AppStrings.streakStartMsg;
      motivationIcon = FeatherIcons.edit3;
      motivationColor = AppColors.sleep;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            motivationColor.withOpacity(0.15),
            motivationColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: motivationColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      motivationColor.withOpacity(0.3),
                      motivationColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(motivationIcon, color: motivationColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      motivation,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (last7Days.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.last7DaysRecords(last7Days.length),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: motivationColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: motivationColor.withOpacity(0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FeatherIcons.zap, color: motivationColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: motivationColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // Mood dağılımı — son 7 gün
          if (moodCounts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: moodCounts.entries.map((entry) {
                  final mood = _moods.firstWhere(
                    (m) => m['id'] == entry.key,
                    orElse: () => _moods[2],
                  );
                  return Column(
                    children: [
                      Text(mood['emoji'], style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: mood['color'] as Color,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 💡 İpucu Kartı — minimal, soft
  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryAccent.withOpacity(0.08),
            AppColors.primaryAccent.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryAccent.withOpacity(0.10),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            FeatherIcons.info,
            color: AppColors.primaryAccent.withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.journalTipText,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💾 Kaydet Butonu — minimal, soft
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4AF37),
            Color(0xFFB8941F),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                _editingIndex != null ? FeatherIcons.check : FeatherIcons.save,
                color: Colors.white,
                size: 18,
              ),
        label: Text(
          _editingIndex != null ? AppStrings.saveChanges : AppStrings.saveJournalButtonText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isSaving ? null : _saveJournal,
      ),
    );
  }

  // Kayıtları yükle
  Future<void> _loadJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString('sleep_journal_entries');
    
    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      setState(() {
        _journalEntries = decoded.map((e) {
          return {
            'date': DateTime.parse(e['date']),
            'mood': e['mood'],
            'dream': e['dream'],
            'note': e['note'],
            'timestamp': DateTime.parse(e['timestamp']),
          };
        }).toList();
      });
    }
  }

  // Kayıtları kaydet
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> toSave = _journalEntries.map((e) {
      return {
        'date': e['date'].toIso8601String(),
        'mood': e['mood'],
        'dream': e['dream'],
        'note': e['note'],
        'timestamp': e['timestamp'].toIso8601String(),
      };
    }).toList();
    
    await prefs.setString('sleep_journal_entries', jsonEncode(toSave));
  }

  // Helper Methods
  String _formatDate(DateTime date) {
    // Lokalize ay isimleri
    final months = [
      'monthJanuary'.tr(), 'monthFebruary'.tr(), 'monthMarch'.tr(), 
      'monthApril'.tr(), 'monthMay'.tr(), 'monthJune'.tr(),
      'monthJuly'.tr(), 'monthAugust'.tr(), 'monthSeptember'.tr(), 
      'monthOctober'.tr(), 'monthNovember'.tr(), 'monthDecember'.tr()
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: context.locale, // Dinamik dil desteği
      confirmText: AppStrings.ok,
      cancelText: AppStrings.cancel,
      helpText: AppStrings.selectDateTitle,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveJournal() async {
    // 🔒 Premium olmayanlar için aylık 5 kayıt limiti
    final premiumProvider = context.read<PremiumProvider>();
    if (!premiumProvider.isPremiumUser) {
      final now = DateTime.now();
      final countThisMonth = _journalEntries.where((e) {
        final d = e['date'] as DateTime;
        return d.year == now.year && d.month == now.month;
      }).length;

      final isNewEntry = _editingIndex == null; // Yeni kayıt mı?
      // Premium kontrolü aktif - aylık 5 kayıt limiti
      if (isNewEntry && countThisMonth >= 5) {
        final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
          (t) => t.targetFeatures.contains(PremiumProvider.featureSleepJournal),
          orElse: () => PremiumTrigger.predefinedTriggers.first,
        );
        SmartPremiumDialog.show(context, trigger);
        return;
      }
    }
    if (_noteController.text.isEmpty && _dreamController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(FeatherIcons.alertCircle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(AppStrings.fillAtLeastOne),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Aynı tarihte kayıt var mı kontrol et (düzenleme modu değilse)
    if (_editingIndex == null) {
      final existingIndex = _journalEntries.indexWhere((e) {
        final entryDate = e['date'] as DateTime;
        return entryDate.year == selectedDate.year &&
               entryDate.month == selectedDate.month &&
               entryDate.day == selectedDate.day;
      });

      if (existingIndex != -1) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              AppStrings.recordExistsTitle,
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              AppStrings.journalRecordExistsMessage.replaceAll('{0}', _formatDate(selectedDate)),
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppStrings.cancel, style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppStrings.overwrite, style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        );

        if (confirmed != true) return;
        
        // Eski kaydı sil
        _journalEntries.removeAt(existingIndex);
      }
    }

    // Kayıt oluştur veya güncelle
    final entry = {
      'date': selectedDate,
      'mood': selectedMood,
      'dream': _dreamController.text,
      'note': _noteController.text,
      'timestamp': DateTime.now(),
    };
    
    setState(() {
      if (_editingIndex != null) {
        // Güncelleme modu
        _journalEntries[_editingIndex!] = entry;
      } else {
        // Yeni kayıt
        _journalEntries.insert(0, entry);
      }
    });
    
    // Kalıcı olarak kaydet
    await _saveToStorage();
    
    // 🔄 Firestore'a sync et (cross-device senkronizasyon)
    _syncToJournalProvider();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(FeatherIcons.checkCircle, color: Colors.white),
            const SizedBox(width: 12),
            Text(_editingIndex != null ? AppStrings.journalUpdated : AppStrings.journalSaved),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );

    // Clear fields
    _noteController.clear();
    _dreamController.clear();
    setState(() {
      selectedMood = 'neutral';
      _editingIndex = null; // Düzenleme modunu kapat
    });
  }
  
  /// 🔄 Tüm günlük kayıtlarını JournalProvider'a sync et (Firestore için)
  void _syncToJournalProvider() {
    try {
      final journalProvider = context.read<JournalProvider>();
      
      // Her local kaydı JournalProvider'a ekle
      for (final entry in _journalEntries) {
        final journalEntry = JournalEntry(
          date: entry['date'] as DateTime,
          mood: entry['mood'] as String,
          note: entry['note'] as String? ?? '',
          dream: entry['dream'] as String? ?? '',
        );
        
        // addOrUpdateEntry zaten Firestore'a sync ediyor
        journalProvider.addOrUpdateEntry(journalEntry);
      }
      
      if (kDebugMode) debugPrint('✅ SleepJournal → JournalProvider sync tamamlandı (${_journalEntries.length} kayıt)');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ SleepJournal → JournalProvider sync hatası: $e');
    }
  }

  void _showEntryDetail(BuildContext context, Map<String, dynamic> entry, int index) {
    final mood = _moods.firstWhere(
      (m) => m['id'] == entry['mood'],
      orElse: () => _moods[2],
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isLargeScreen = screenWidth > 600;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeScreen ? 500 : screenWidth * 0.95,
            maxHeight: MediaQuery.of(context).size.height * 0.75,
            minHeight: 200,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        mood['emoji'],
                        style: TextStyle(fontSize: isSmallScreen ? 24 : 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(entry['date']),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              mood['label'],
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: mood['color'] as Color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content (Scrollable)
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (entry['dream'].isNotEmpty) ...[
                          Text(
                            AppStrings.dreamNotesIcon,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.sleep,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          child: SelectableText(
                            entry['dream'],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                          const SizedBox(height: 16),
                        ],
                        if (entry['note'].isNotEmpty) ...[
                          Text(
                            AppStrings.generalNotesIcon,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.energy,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          child: SelectableText(
                            entry['note'],
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Actions
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _deleteEntry(index),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(FeatherIcons.trash2, color: AppColors.error, size: 16),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(AppStrings.deleteButton, style: TextStyle(color: AppColors.error, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _editEntry(entry, index),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(FeatherIcons.edit, color: AppColors.primary, size: 16),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(AppStrings.editButton, style: TextStyle(color: AppColors.primary, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(AppStrings.closeButton, style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editEntry(Map<String, dynamic> entry, int index) {
    // Tüm modal'ları kapat (detay + geçmiş kayıtlar)
    Navigator.pop(context); // Detay dialog
    Navigator.pop(context); // Geçmiş kayıtlar modal
    
    // Form alanlarını doldur
    _noteController.text = entry['note'];
    _dreamController.text = entry['dream'];
    setState(() {
      selectedDate = entry['date'];
      selectedMood = entry['mood'];
      _editingIndex = index; // Kayıt modunu düzenleme olarak işaretle
    });

    // Scroll to top
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(FeatherIcons.edit, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(AppStrings.editMode)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: AppStrings.ok,
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _deleteEntry(int index) async {
    // Önce detay modalını kapat
    Navigator.pop(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          AppStrings.deleteRecordTitle,
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          AppStrings.confirmDeleteJournal,
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel, style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.deleteButton, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Silinen kaydın tarihini al (JournalProvider'dan da silmek için)
      final deletedEntry = _journalEntries[index];
      final deletedDate = deletedEntry['date'] as DateTime;
      
      setState(() {
        _journalEntries.removeAt(index);
      });
      await _saveToStorage();
      
      // 🔄 JournalProvider'dan da sil (Firestore sync)
      try {
        final journalProvider = context.read<JournalProvider>();
        journalProvider.deleteEntry(deletedDate);
      } catch (e) {
        if (kDebugMode) debugPrint('❌ JournalProvider silme hatası: $e');
      }

      // Geçmiş kayıtlar modalını da kapat ve yenile
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(FeatherIcons.trash2, color: Colors.white),
              const SizedBox(width: 12),
              Text(AppStrings.recordDeleted),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _showJournalHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withOpacity(0.95),
                AppColors.surface.withOpacity(0.98),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        FeatherIcons.bookOpen,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.pastRecordsTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(FeatherIcons.x, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Kayıt Listesi
              Expanded(
                child: Builder(
                  builder: (context) {
                    final premiumProvider = context.read<PremiumProvider>();
                    final isPremium = premiumProvider.isPremiumUser;
                    final now = DateTime.now();
                    final threeDaysAgo = now.subtract(const Duration(days: 3));
                    
                    // Ücretsiz kullanıcılar için son 3 gün filtresi
                    final displayEntries = isPremium
                        ? _journalEntries
                        : _journalEntries.where((e) {
                            final d = e['date'] as DateTime;
                            return d.isAfter(threeDaysAgo);
                          }).toList();
                    final hasLockedEntries = !isPremium && _journalEntries.length > displayEntries.length;
                    
                    return _journalEntries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withOpacity(0.2),
                                    AppColors.primary.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Icon(
                                FeatherIcons.inbox,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppStrings.noRecordsYet,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.createFirstRecord,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayEntries.length + (hasLockedEntries ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Son item: Geçmiş Kilitli banner
                          if (hasLockedEntries && index == displayEntries.length) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
                                  (t) => t.targetFeatures.contains(PremiumProvider.featureSleepJournal),
                                  orElse: () => PremiumTrigger.predefinedTriggers.first,
                                );
                                SmartPremiumDialog.show(this.context, trigger);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.premium.withOpacity(0.15),
                                      AppColors.premium.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.premium.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.premium.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(FeatherIcons.lock, color: AppColors.premium, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppStrings.historyLockedTitle,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.premium,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                AppStrings.historyLockedDesc,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white.withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [AppColors.premium, AppColors.premium.withOpacity(0.8)],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.diamond, color: Colors.white, size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            AppStrings.unlockFullHistory,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
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
                          
                          final entry = displayEntries[index];
                          // Orijinal index'i bul (silme/düzenleme için)
                          final originalIndex = _journalEntries.indexOf(entry);
                          final mood = _moods.firstWhere(
                            (m) => m['id'] == entry['mood'],
                            orElse: () => _moods[2],
                          );
                          
                          return InkWell(
                            onTap: () => _showEntryDetail(context, entry, originalIndex),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    (mood['color'] as Color).withOpacity(0.15),
                                    (mood['color'] as Color).withOpacity(0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: (mood['color'] as Color).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        mood['emoji'],
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatDate(entry['date']),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              mood['label'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: mood['color'] as Color,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        FeatherIcons.chevronRight,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  if (entry['dream'].isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      '💭 ${entry['dream'].length > 50 ? entry['dream'].substring(0, 50) + '...' : entry['dream']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                  if (entry['note'].isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '📝 ${entry['note'].length > 50 ? entry['note'].substring(0, 50) + '...' : entry['note']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
