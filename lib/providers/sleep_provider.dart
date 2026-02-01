import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../models/sleep_entry.dart';
import '../constants/app_strings.dart';
import '../core/analytics/analytics_service.dart';
import '../core/crashlytics/crashlytics_service.dart';
import '../services/user_data_sync_service.dart';

class SleepProvider extends ChangeNotifier {
  // 🔄 Firestore sync servisi
  final UserDataSyncService _syncService = UserDataSyncService();
  bool _isSyncing = false;
  
  List<SleepEntry> _sleepEntries = [];
  
  // Getters
  List<SleepEntry> get sleepEntries => List.unmodifiable(_sleepEntries);
  
  SleepProvider() {
    _loadSleepData();
  }
  
  /// Verileri yükle
  Future<void> _loadSleepData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final entriesJson = prefs.getStringList('sleep_entries') ?? [];
      _sleepEntries = entriesJson.map((jsonString) {
        final json = jsonDecode(jsonString);
        return SleepEntry.fromJson(json);
      }).toList();
      
      // Tarihe göre sırala (en yeni önce)
      _sleepEntries.sort((a, b) => b.date.compareTo(a.date));
      
      notifyListeners();
      
      // 🔄 Firestore'dan sync et (arka planda)
      if (_syncService.isUserLoggedIn) {
        _syncFromFirestore();
      }
    } catch (e, stackTrace) {
      await CrashlyticsService.instance.recordError(
        e,
        stackTrace,
        reason: 'Sleep Data Load Failed',
        additionalData: {
          'component': 'SleepProvider',
          'method': '_loadSleepData',
        },
      );
      debugPrint('🚨 Sleep data load error: $e');
    }
  }
  
  /// Verileri kaydet
  Future<void> _saveSleepData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final entriesJson = _sleepEntries.map((entry) {
        return jsonEncode(entry.toJson());
      }).toList();
      
      await prefs.setStringList('sleep_entries', entriesJson);
    } catch (e, stackTrace) {
      await CrashlyticsService.instance.recordError(
        e,
        stackTrace,
        reason: 'Sleep Data Save Failed',
        additionalData: {
          'component': 'SleepProvider',
          'method': '_saveSleepData',
          'entries_count': _sleepEntries.length.toString(),
        },
      );
      debugPrint('🚨 Sleep data save error: $e');
    }
  }
  
  /// Yeni uyku verisi ekle
  Future<void> addSleepEntry(SleepEntry entry) async {
    try {
      // Aynı gün için zaten veri varsa, güncelle
      final existingIndex = _sleepEntries.indexWhere((e) => 
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day
      );
      
      final isUpdate = existingIndex != -1;
      
      if (isUpdate) {
        _sleepEntries[existingIndex] = entry;
      } else {
        _sleepEntries.add(entry);
      }
      
      // Tarihe göre sırala
      _sleepEntries.sort((a, b) => b.date.compareTo(a.date));
      
      await _saveSleepData();
      
      // Analytics event - Uyku kaydı eklendi
      await AnalyticsService.instance.logSleepEntryAdded();
      
      // Analytics event - Uyku analizi tamamlandı
      await AnalyticsService.instance.logEvent('sleep_analysis_completed', {
        'sleep_duration_hours': (entry.actualSleep.inMinutes / 60).toString(),
        'sleep_debt_minutes': entry.sleepDebt.inMinutes.toString(),
        'is_update': isUpdate.toString(),
        'bedtime': entry.bedTime.toIso8601String(),
        'wake_time': entry.wakeTime.toIso8601String(),
      });
      
      // 🔄 Firestore'a sync et
      _syncToFirestore();
      
      notifyListeners();
    } catch (e, stackTrace) {
      await CrashlyticsService.instance.recordError(
        e,
        stackTrace,
        reason: 'Sleep Entry Add Failed',
        additionalData: {
          'component': 'SleepProvider',
          'method': 'addSleepEntry',
          'entry_date': entry.date.toIso8601String(),
          'sleep_duration': entry.actualSleep.inMinutes.toString(),
        },
      );
      debugPrint('🚨 Sleep entry add error: $e');
    }
  }
  
  /// Belirli bir gün için uyku verisi al
  SleepEntry? getSleepEntryForDate(DateTime date) {
    return _sleepEntries.where((entry) =>
      entry.date.year == date.year &&
      entry.date.month == date.month &&
      entry.date.day == date.day
    ).firstOrNull;
  }
  
  /// Uyku kaydını sil
  Future<void> deleteSleepEntry(DateTime date) async {
    try {
      _sleepEntries.removeWhere((entry) =>
        entry.date.year == date.year &&
        entry.date.month == date.month &&
        entry.date.day == date.day
      );
      
      await _saveSleepData();
      
      // Analytics event - Uyku kaydı silindi
      await AnalyticsService.instance.logEvent('sleep_entry_deleted', {
        'deleted_date': date.toIso8601String(),
        'remaining_entries': _sleepEntries.length.toString(),
      });
      
      // 🔄 Firestore'a sync et
      _syncToFirestore();
      
      notifyListeners();
    } catch (e, stackTrace) {
      await CrashlyticsService.instance.recordError(
        e,
        stackTrace,
        reason: 'Sleep Entry Delete Failed',
        additionalData: {
          'component': 'SleepProvider',
          'method': 'deleteSleepEntry',
          'delete_date': date.toIso8601String(),
        },
      );
      debugPrint('🚨 Sleep entry delete error: $e');
    }
  }
  
  /// ✅ DÜZELTME: Bu haftanın uyku borcu (Pazartesi-Pazar)
  Duration get weeklyDebt {
    final now = DateTime.now();
    
    // ✅ DÜZELTME: Pazartesi'yi hafta başı olarak al
    // weekday: 1=Pazartesi, 7=Pazar
    final daysToSubtract = now.weekday - 1;
    final startOfWeek = now.subtract(Duration(days: daysToSubtract));
    Duration totalDebt = Duration.zero;
    
    // Pazartesi'den bugüne kadar
    for (int i = 0; i < now.weekday; i++) {
      final date = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).add(Duration(days: i));
      final entry = getSleepEntryForDate(date);
      
      // Sadece veri girilen günleri hesapla
      if (entry != null && entry.actualSleep > Duration.zero) {
        totalDebt += entry.sleepDebt;
      }
    }
    
    return totalDebt;
  }

  /// ✅ DÜZELTME: Bu haftada veri girilen gün sayısı (Pazartesi-Pazar)
  int get daysWithDataCount {
    final now = DateTime.now();
    
    // ✅ DÜZELTME: Pazartesi'yi hafta başı olarak al
    final daysToSubtract = now.weekday - 1;
    final startOfWeek = now.subtract(Duration(days: daysToSubtract));
    int count = 0;
    
    // Pazartesi'den bugüne kadar
    for (int i = 0; i < now.weekday; i++) {
      final date = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).add(Duration(days: i));
      final entry = getSleepEntryForDate(date);
      
      if (entry != null && entry.actualSleep > Duration.zero) {
        count++;
      }
    }
    
    return count;
  }
  
  /// Haftalık ortalama uyku süresi (Pzt-Paz)
  /// weeklyEntries ile aynı mantık - grafikteki günlerle tutarlı
  Duration get weeklyAverageSleep {
    final entries = weeklyEntries.where((e) => e.actualSleep > Duration.zero).toList();
    
    if (entries.isEmpty) return Duration.zero;
    
    int totalMinutes = 0;
    for (var entry in entries) {
      totalMinutes += entry.actualSleep.inMinutes;
    }
    
    final averageMinutes = totalMinutes ~/ entries.length;
    return Duration(minutes: averageMinutes);
  }
  
  /// Aylık ortalama uyku süresi (son 30 gün)
  Duration get monthlyAverageSleep {
    final now = DateTime.now();
    int totalMinutes = 0;
    int daysWithData = 0;
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final entry = getSleepEntryForDate(date);
      
      if (entry != null && entry.actualSleep > Duration.zero) {
        totalMinutes += entry.actualSleep.inMinutes;
        daysWithData++;
      }
    }
    
    if (daysWithData == 0) return Duration.zero;
    
    final averageMinutes = totalMinutes ~/ daysWithData;
    return Duration(minutes: averageMinutes);
  }
  
  /// Aylık veri girilen gün sayısı
  int get monthlyDaysWithDataCount {
    final now = DateTime.now();
    int count = 0;
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final entry = getSleepEntryForDate(date);
      
      if (entry != null && entry.actualSleep > Duration.zero) {
        count++;
      }
    }
    
    return count;
  }
  
  /// Ortalama uyku kalitesi skoru (0-100).
  /// Bu skor, hedeflenen uyku süresine ne kadar yaklaşıldığına göre hesaplanır.
  int get sleepQualityScore {
    try {
      if (sleepEntries.isEmpty) return 0;

      // Sadece veri olan günleri al
      final entriesWithData = weeklyEntries.where((e) => e.actualSleep > Duration.zero).toList();
      if (entriesWithData.isEmpty) return 0;

      double totalScore = 0;
      for (var entry in entriesWithData) {
        final targetMinutes = entry.targetSleep.inMinutes;
        final actualMinutes = entry.actualSleep.inMinutes;
        
        if (targetMinutes == 0) continue; // Hedef yoksa puanlama yapma

        // Hedefe olan uzaklık (dakika cinsinden)
        final difference = (targetMinutes - actualMinutes).abs();

        // Skoru hesapla: 30 dakikaya kadar olan sapmalar tam puan (100) alır.
        // Sonraki her 15 dakikalık sapma için 10 puan düşülür.
        double score = 100.0 - ((difference - 30) / 15) * 10;

        // Skorun 0'ın altına düşmesini ve 100'ü aşmasını engelle
        totalScore += score.clamp(0, 100);
      }

      // Ortalamayı al ve tam sayıya yuvarla
      return (totalScore / entriesWithData.length).round();
    } catch (e, stackTrace) {
      // Error handling - Crashlytics'e gönder
      CrashlyticsService.instance.recordError(
        e,
        stackTrace,
        reason: 'Sleep Quality Score Calculation Failed',
        additionalData: {
          'component': 'SleepProvider',
          'method': 'sleepQualityScore',
          'entries_count': sleepEntries.length.toString(),
        },
      );
      debugPrint('🚨 Sleep quality score calculation error: $e');
      return 0; // Fallback değer
    }
  }
  
  /// ✅ DÜZELTME: Haftalık uyku verileri (Pazartesi-Pazar)
  List<SleepEntry> get weeklyEntries {
    final now = DateTime.now();
    
    // ✅ DÜZELTME: Pazartesi'yi hafta başı olarak al
    final daysToSubtract = now.weekday - 1;
    final startOfWeek = now.subtract(Duration(days: daysToSubtract));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    final entries = <SleepEntry>[];
    
    // Pazartesi'den Pazar'a kadar 7 gün (henüz gelmemiş günler de dahil)
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      
      // Gelecek günleri gösterme
      if (date.isAfter(now)) {
        break;
      }
      
      final entry = getSleepEntryForDate(date);
      
      // Grafik için veri olmasa bile günü temsil eden bir entry ekle
      entries.add(entry ?? SleepEntry(
        date: date,
        bedTime: date, // Uyunmamış gün için sıfır süreli
        wakeTime: date,
      ));
    }
    
    return entries;
  }

  /// Haftalık grafik için maksimum Y ekseni değerini hesaplar.
  double get maxSleepForChart {
    final entries = weeklyEntries;
    if (entries.isEmpty) return 10.0; // 8 + 2 saat

    double maxHours = 8.0; // Standart hedef
    for (var entry in entries) {
      if (entry.actualSleep.inHours > maxHours) {
        maxHours = entry.actualSleep.inHours.toDouble();
      }
    }
    // Grafiğin üstünde biraz boşluk bırakmak için 2 saat ekle
    return (maxHours.ceil() + 2).toDouble();
  }

  /// Haftalık grafik verileri
  List<FlSpot> get weeklyChartData {
    final entries = weeklyEntries;
    final chartData = <FlSpot>[];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final hours = entry.actualSleep.inHours.toDouble();
      chartData.add(FlSpot(i.toDouble(), hours));
    }

    return chartData;
  }

  /// Uyku borcunu formatla (lokalize)
  String formatSleepDebt(Duration debt) {
    if (debt.isNegative) {
      final positive = -debt;
      final hours = positive.inHours;
      final minutes = positive.inMinutes % 60;
      
      final duration = hours > 0 
          ? AppStrings.hoursMinFormat(hours, minutes)
          : '${minutes}m';
      return AppStrings.deficitFormat(duration);
    } else if (debt.inMinutes > 0) {
      final hours = debt.inHours;
      final minutes = debt.inMinutes % 60;
      
      final duration = hours > 0 
          ? AppStrings.hoursMinFormat(hours, minutes)
          : '${minutes}m';
      return AppStrings.surplusFormat(duration);
    } else {
      return AppStrings.onTargetText;
    }
  }
  
  /// Uyku süresini formatla (lokalize)
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return AppStrings.hoursMinFormat(hours, minutes);
    } else {
      // Sadece dakika için
      final locale = 'tr'.tr(); // Locale kontrolü
      return locale.startsWith('tr') ? '${minutes}dk' : '${minutes}m';
    }
  }
  
  // ================================
  // 🔄 FIRESTORE SYNC METODLARI
  // ================================
  
  /// Firestore'dan uyku verilerini yükle ve local ile birleştir
  Future<void> _syncFromFirestore() async {
    if (_isSyncing || !_syncService.isUserLoggedIn) return;
    _isSyncing = true;
    
    try {
      debugPrint('🔄 Sleep Firestore sync başlatılıyor...');
      
      final remoteEntries = await _syncService.loadSleepEntries();
      
      if (remoteEntries.isNotEmpty) {
        // Tarih bazlı birleştirme
        final entryMap = <String, SleepEntry>{};
        
        // Local kayıtları ekle
        for (final entry in _sleepEntries) {
          final key = entry.date.toIso8601String().split('T')[0];
          entryMap[key] = entry;
        }
        
        // Remote kayıtları ekle/güncelle
        for (final entry in remoteEntries) {
          final key = entry.date.toIso8601String().split('T')[0];
          if (!entryMap.containsKey(key)) {
            // Yeni kayıt
            entryMap[key] = entry;
          }
          // Eğer varsa local'i koruyoruz (local öncelikli)
        }
        
        _sleepEntries = entryMap.values.toList();
        _sleepEntries.sort((a, b) => b.date.compareTo(a.date));
        
        await _saveSleepData();
        notifyListeners();
        
        debugPrint('✅ Sleep Firestore sync tamamlandı (${remoteEntries.length} kayıt)');
      }
    } catch (e) {
      debugPrint('❌ Sleep Firestore sync hatası: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Uyku verilerini Firestore'a kaydet
  Future<void> _syncToFirestore() async {
    if (!_syncService.isUserLoggedIn) return;
    
    // Arka planda sync et
    _syncService.syncSleepEntries(_sleepEntries).catchError((e) {
      debugPrint('❌ Sleep sync hatası: $e');
    });
  }
  
  /// Manuel full sync (kullanıcı giriş yaptığında çağrılır)
  Future<void> performFullSync() async {
    debugPrint('🔄 Sleep full sync başlatılıyor...');
    
    // Önce Firestore'dan yükle
    await _syncFromFirestore();
    
    // Sonra local verileri Firestore'a gönder
    await _syncToFirestore();
    
    debugPrint('✅ Sleep full sync tamamlandı');
  }
  
  // ================================
  // 🚪 OTURUM KAPATMA - VERİ TEMİZLEME
  // ================================
  
  /// Oturum kapatıldığında TÜM uyku verilerini temizle
  /// Yeni kullanıcı giriş yaptığında Firestore'dan kendi verilerini çekecek
  Future<void> clearAllDataOnLogout() async {
    debugPrint('🚪 Sleep verileri temizleniyor...');
    
    // 1. Memory'deki verileri temizle
    _sleepEntries.clear();
    
    // 2. SharedPreferences'tan temizle
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sleep_entries');
      
      debugPrint('✅ Sleep SharedPreferences temizlendi');
    } catch (e) {
      debugPrint('❌ Sleep temizleme hatası: $e');
    }
    
    // 3. UI'ı güncelle
    notifyListeners();
    
    debugPrint('✅ Sleep verileri temizlendi');
  }
} 