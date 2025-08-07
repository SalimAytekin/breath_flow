import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sleep_entry.dart';

class SleepProvider extends ChangeNotifier {
  List<SleepEntry> _sleepEntries = [];
  int _defaultTargetHours = 8;
  
  // Getters
  List<SleepEntry> get sleepEntries => List.unmodifiable(_sleepEntries);
  int get defaultTargetHours => _defaultTargetHours;
  
  SleepProvider() {
    _loadSleepData();
  }
  
  /// Verileri yükle
  Future<void> _loadSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _defaultTargetHours = prefs.getInt('default_target_hours') ?? 8;
    
    final entriesJson = prefs.getStringList('sleep_entries') ?? [];
    _sleepEntries = entriesJson.map((jsonString) {
      final json = jsonDecode(jsonString);
      return SleepEntry.fromJson(json);
    }).toList();
    
    // Tarihe göre sırala (en yeni önce)
    _sleepEntries.sort((a, b) => b.date.compareTo(a.date));
    
    notifyListeners();
  }
  
  /// Verileri kaydet
  Future<void> _saveSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('default_target_hours', _defaultTargetHours);
    
    final entriesJson = _sleepEntries.map((entry) {
      return jsonEncode(entry.toJson());
    }).toList();
    
    await prefs.setStringList('sleep_entries', entriesJson);
  }
  
  /// Hedef uyku saatini ayarla
  Future<void> setDefaultTargetHours(int hours) async {
    _defaultTargetHours = hours;
    await _saveSleepData();
    notifyListeners();
  }
  
  /// Yeni uyku verisi ekle
  Future<void> addSleepEntry(SleepEntry entry) async {
    // Aynı gün için zaten veri varsa, güncelle
    final existingIndex = _sleepEntries.indexWhere((e) => 
      e.date.year == entry.date.year &&
      e.date.month == entry.date.month &&
      e.date.day == entry.date.day
    );
    
    if (existingIndex != -1) {
      _sleepEntries[existingIndex] = entry;
    } else {
      _sleepEntries.add(entry);
    }
    
    // Tarihe göre sırala
    _sleepEntries.sort((a, b) => b.date.compareTo(a.date));
    
    await _saveSleepData();
    notifyListeners();
  }
  
  /// Belirli bir gün için uyku verisi al
  SleepEntry? getSleepEntryForDate(DateTime date) {
    return _sleepEntries.where((entry) =>
      entry.date.year == date.year &&
      entry.date.month == date.month &&
      entry.date.day == date.day
    ).firstOrNull;
  }
  
  /// Son 7 günün uyku borcu toplamı
  Duration get weeklyDebt {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    Duration totalDebt = Duration.zero;
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final entry = getSleepEntryForDate(date);
      
      if (entry != null) {
        totalDebt += entry.sleepDebt;
      } else {
        // Veri yoksa hedef uyku kadar borç ekle
        totalDebt -= Duration(hours: _defaultTargetHours);
      }
    }
    
    return totalDebt;
  }
  
  /// Son 7 günün ortalama uyku süresi
  Duration get weeklyAverageSleep {
    final now = DateTime.now();
    int totalMinutes = 0;
    int daysWithData = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final entry = getSleepEntryForDate(date);
      
      if (entry != null) {
        totalMinutes += entry.actualSleep.inMinutes;
        daysWithData++;
      }
    }
    
    if (daysWithData == 0) return Duration.zero;
    
    final averageMinutes = totalMinutes ~/ daysWithData;
    return Duration(minutes: averageMinutes);
  }
  
  /// Son 30 günün uyku kalitesi skoru (0-100)
  int get sleepQualityScore {
    final now = DateTime.now();
    int totalScore = 0;
    int daysWithData = 0;
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final entry = getSleepEntryForDate(date);
      
      if (entry != null) {
        // Uyku kalitesi = hedefe ne kadar yakın olduğu (100 = mükemmel)
        final target = entry.targetSleep.inMinutes;
        final actual = entry.actualSleep.inMinutes;
        final difference = (actual - target).abs();
        
        // 0-60 dk fark = 100 puan, 60+ dk fark = azalan puan
        int dayScore = 100;
        if (difference > 60) {
          dayScore = (100 - (difference - 60) * 2).clamp(0, 100);
        } else if (difference > 30) {
          dayScore = 90 - difference;
        }
        
        totalScore += dayScore;
        daysWithData++;
      }
    }
    
    if (daysWithData == 0) return 0;
    
    return totalScore ~/ daysWithData;
  }
  
  /// Haftalık uyku verileri (grafik için)
  List<SleepEntry> get weeklyEntries {
    final now = DateTime.now();
    final entries = <SleepEntry>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final entry = getSleepEntryForDate(date);
      
      if (entry != null) {
        entries.add(entry);
      } else {
        // Veri yoksa varsayılan entry oluştur
        entries.add(SleepEntry(
          date: date,
          bedTime: date.add(const Duration(hours: 23)),
          wakeTime: date.add(const Duration(hours: 7)),
          targetHours: _defaultTargetHours,
        ));
      }
    }
    
    return entries;
  }
  
  /// Uyku borcunu formatla
  String formatSleepDebt(Duration debt) {
    if (debt.isNegative) {
      final positive = -debt;
      final hours = positive.inHours;
      final minutes = positive.inMinutes % 60;
      
      if (hours > 0) {
        return '${hours}s ${minutes}dk eksik';
      } else {
        return '${minutes}dk eksik';
      }
    } else if (debt.inMinutes > 0) {
      final hours = debt.inHours;
      final minutes = debt.inMinutes % 60;
      
      if (hours > 0) {
        return '${hours}s ${minutes}dk fazla';
      } else {
        return '${minutes}dk fazla';
      }
    } else {
      return 'Hedefinde';
    }
  }
  
  /// Uyku süresini formatla
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    } else {
      return '${minutes}dk';
    }
  }
} 