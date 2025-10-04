import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../widgets/global_background.dart';
import '../widgets/professional_app_bar.dart';
import '../providers/sleep_provider.dart';

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
  
  // Kalıcı kayıt listesi (SharedPreferences ile)
  List<Map<String, dynamic>> _journalEntries = [];
  
  final List<Map<String, dynamic>> _moods = [
    {'id': 'great', 'emoji': '😊', 'label': 'Harika', 'color': AppColors.success},
    {'id': 'good', 'emoji': '🙂', 'label': 'İyi', 'color': AppColors.primary},
    {'id': 'neutral', 'emoji': '😐', 'label': 'Normal', 'color': AppColors.focus},
    {'id': 'tired', 'emoji': '😴', 'label': 'Yorgun', 'color': AppColors.warning},
    {'id': 'bad', 'emoji': '😔', 'label': 'Kötü', 'color': AppColors.error},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Animation Controllers
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    
    // Kayıtları yükle
    _loadJournalEntries();
    
    // Start animations
    _animationController.forward();
    _pulseController.repeat(reverse: true);
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
    return GlobalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: ProfessionalAppBar(
          scrollController: _scrollController,
          title: 'Uyku Günlüğü',
          actions: [
            IconButton(
              icon: Icon(FeatherIcons.list, color: Colors.white),
              onPressed: () => _showJournalHistory(context),
              tooltip: 'Geçmiş Kayıtlar',
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
                      
                      const SizedBox(height: AppSpacing.xLarge),
                      
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
    );
  }

  // 🌟 Premium Header
  Widget _buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.2),
            AppColors.primaryAccent.withOpacity(0.15),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    FeatherIcons.bookOpen,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uyku Günlüğü',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rüyalarını ve uyku notlarını kaydet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
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

  // 📅 Date Section
  Widget _buildDateSection() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                FeatherIcons.calendar,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarih',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
      ),
    );
  }

  // 😊 Mood Section
  Widget _buildMoodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.focus.withOpacity(0.15),
            AppColors.focus.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.focus.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.focus.withOpacity(0.3),
                      AppColors.focus.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FeatherIcons.smile,
                  color: AppColors.focus,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Uyandığında Nasıl Hissettin?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _moods.map((mood) {
              final isSelected = selectedMood == mood['id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMood = mood['id'];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              (mood['color'] as Color).withOpacity(0.3),
                              (mood['color'] as Color).withOpacity(0.15),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? (mood['color'] as Color).withOpacity(0.5)
                          : Colors.white.withOpacity(0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        mood['emoji'],
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['label'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? mood['color'] as Color
                              : Colors.white.withOpacity(0.6),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 💭 Dream Section
  Widget _buildDreamSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.sleep.withOpacity(0.15),
            AppColors.sleep.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.sleep.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.sleep.withOpacity(0.3),
                      AppColors.sleep.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FeatherIcons.cloud,
                  color: AppColors.sleep,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Rüya Notları',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dreamController,
            maxLines: null,
            minLines: 4,
            maxLength: 500,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Rüyanı buraya yaz...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.sleep.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📝 Note Section
  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.energy.withOpacity(0.15),
            AppColors.energy.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.energy.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.energy.withOpacity(0.3),
                      AppColors.energy.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  FeatherIcons.edit3,
                  color: AppColors.energy,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Genel Notlar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: null,
            minLines: 4,
            maxLength: 500,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Uyku kaliteni, gece uyanma sayını veya diğer gözlemlerini yaz...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.energy.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💡 Tips Card
  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            FeatherIcons.info,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'İpucu: Düzenli günlük tutmak uyku kaliteni anlamana yardımcı olur',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💾 Save Button
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryAccent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(
          _editingIndex != null ? FeatherIcons.check : FeatherIcons.save,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          _editingIndex != null ? 'Değişiklikleri Kaydet' : 'Günlüğü Kaydet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
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
        onPressed: _saveJournal,
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
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: Colors.white,
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
    if (_noteController.text.isEmpty && _dreamController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(FeatherIcons.alertCircle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Lütfen rüya veya genel notlardan en az birini doldurun'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(FeatherIcons.checkCircle, color: Colors.white),
            const SizedBox(width: 12),
            Text(_editingIndex != null ? 'Günlük güncellendi! ✏️' : 'Günlük kaydedildi! 📝'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
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

  void _showEntryDetail(BuildContext context, Map<String, dynamic> entry, int index) {
    final mood = _moods.firstWhere(
      (m) => m['id'] == entry['mood'],
      orElse: () => _moods[2],
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
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
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      mood['emoji'],
                      style: TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(entry['date']),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            mood['label'],
                            style: TextStyle(
                              fontSize: 14,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (entry['dream'].isNotEmpty) ...[
                        Text(
                          '💭 Rüya Notları',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.sleep,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry['dream'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (entry['note'].isNotEmpty) ...[
                        Text(
                          '📝 Genel Notlar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.energy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry['note'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: Icon(FeatherIcons.trash2, color: AppColors.error, size: 18),
                      label: Text('Sil', style: TextStyle(color: AppColors.error)),
                      onPressed: () => _deleteEntry(index),
                    ),
                    TextButton.icon(
                      icon: Icon(FeatherIcons.edit, color: AppColors.primary, size: 18),
                      label: Text('Düzenle', style: TextStyle(color: AppColors.primary)),
                      onPressed: () => _editEntry(entry, index),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Kapat', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editEntry(Map<String, dynamic> entry, int index) {
    // Önce modal'ı kapat
    Navigator.pop(context);
    
    // Form alanlarını doldur
    _noteController.text = entry['note'];
    _dreamController.text = entry['dream'];
    setState(() {
      selectedDate = entry['date'];
      selectedMood = entry['mood'];
      _editingIndex = index; // Kayıt modunu düzenleme olarak işaretle
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(FeatherIcons.edit, color: Colors.white),
            const SizedBox(width: 12),
            Text('Düzenleme modu - Değişiklikleri kaydet'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
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
          'Kaydı Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bu günlük kaydını silmek istediğinize emin misiniz?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _journalEntries.removeAt(index);
      });
      await _saveToStorage();

      // Geçmiş kayıtlar modalını da kapat ve yenile
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(FeatherIcons.trash2, color: Colors.white),
              const SizedBox(width: 12),
              Text('Kayıt silindi'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
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
                        'Geçmiş Kayıtlar',
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
                child: _journalEntries.isEmpty
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
                              'Henüz Kayıt Yok',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'İlk günlük kaydını oluştur',
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
                        itemCount: _journalEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _journalEntries[index];
                          final mood = _moods.firstWhere(
                            (m) => m['id'] == entry['mood'],
                            orElse: () => _moods[2],
                          );
                          
                          return InkWell(
                            onTap: () => _showEntryDetail(context, entry, index),
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
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
