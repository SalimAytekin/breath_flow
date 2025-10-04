import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
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
  
  /// Son 7 günün uyku borcu toplamı (sadece veri girilen günler)
  Duration get weeklyDebt {
    final now = DateTime.now();
    Duration totalDebt = Duration.zero;
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final entry = getSleepEntryForDate(date);
      
      // Sadece veri girilen günleri hesapla
      if (entry != null && entry.actualSleep > Duration.zero) {
        totalDebt += entry.sleepDebt;
      }
      // Veri girilmeyen günleri hesaplamaya dahil etme
    }
    
    return totalDebt;
  }

  /// Veri girilen gün sayısı (son 7 gün)
  int get daysWithDataCount {
    final now = DateTime.now();
    int count = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final entry = getSleepEntryForDate(date);
      
      if (entry != null && entry.actualSleep > Duration.zero) {
        count++;
      }
    }
    
    return count;
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
  
  /// Ortalama uyku kalitesi skoru (0-100).
  /// Bu skor, hedeflenen uyku süresine ne kadar yaklaşıldığına göre hesaplanır.
  int get sleepQualityScore {
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
  }
  
  /// Haftalık uyku verileri (grafik için)
  List<SleepEntry> get weeklyEntries {
    final now = DateTime.now();
    final entries = <SleepEntry>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final entry = getSleepEntryForDate(date);
      
      // Grafik için veri olmasa bile günü temsil eden bir entry ekle
      entries.add(entry ?? SleepEntry(
        date: date,
        bedTime: date, // Uyunmamış gün için sıfır süreli
        wakeTime: date,
        targetHours: _defaultTargetHours,
      ));
    }
    
    return entries;
  }

  /// Haftalık grafik için maksimum Y ekseni değerini hesaplar.
  double get maxSleepForChart {
    final entries = weeklyEntries;
    if (entries.isEmpty) return (_defaultTargetHours + 2).toDouble();

    double maxHours = _defaultTargetHours.toDouble();
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