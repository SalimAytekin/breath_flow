import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/journal_entry.dart';

class JournalProvider extends ChangeNotifier {
  List<JournalEntry> _entries = [];
  Map<String, int> _weeklyMoodCounts = {};
  Map<String, List<String>> _activityMoodMap = {};
  
  // Getters
  List<JournalEntry> get entries => List.unmodifiable(_entries);
  Map<String, int> get weeklyMoodCounts => Map.unmodifiable(_weeklyMoodCounts);
  
  JournalProvider() {
    _loadJournalData();
  }
  
  /// Verileri yükle
  Future<void> _loadJournalData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final entriesJson = prefs.getStringList('journal_entries') ?? [];
    _entries = entriesJson.map((jsonString) {
      final json = jsonDecode(jsonString);
      return JournalEntry.fromJson(json);
    }).toList();
    
    // Tarihe göre sırala (en yeni önce)
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    _updateAnalytics();
    notifyListeners();
  }
  
  /// Verileri kaydet
  Future<void> _saveJournalData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final entriesJson = _entries.map((entry) {
      return jsonEncode(entry.toJson());
    }).toList();
    
    await prefs.setStringList('journal_entries', entriesJson);
  }
  
  /// Yeni günlük girişi ekle
  Future<void> addEntry(JournalEntry entry) async {
    _entries.insert(0, entry); // En başa ekle (en yeni)
    await _saveJournalData();
    _updateAnalytics();
    notifyListeners();
  }
  
  /// Seans feedback'i ekle
  Future<void> addSessionFeedback(SessionFeedback feedback) async {
    final entry = feedback.toJournalEntry();
    await addEntry(entry);
  }
  
  /// Günlük girişi güncelle
  Future<void> updateEntry(JournalEntry updatedEntry) async {
    final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      await _saveJournalData();
      _updateAnalytics();
      notifyListeners();
    }
  }
  
  /// Günlük girişi sil
  Future<void> deleteEntry(String entryId) async {
    _entries.removeWhere((e) => e.id == entryId);
    await _saveJournalData();
    _updateAnalytics();
    notifyListeners();
  }
  
  /// Belirli bir tarih için girişleri al
  List<JournalEntry> getEntriesForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    
    return _entries.where((entry) =>
      entry.timestamp.isAfter(dayStart) && entry.timestamp.isBefore(dayEnd)
    ).toList();
  }
  
  /// Son N günün girişlerini al
  List<JournalEntry> getRecentEntries(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _entries.where((entry) => entry.timestamp.isAfter(cutoffDate)).toList();
  }
  
  /// Belirli tip girişleri al
  List<JournalEntry> getEntriesByType(JournalEntryType type) {
    return _entries.where((entry) => entry.type == type).toList();
  }
  
  /// Son 7 günün ruh hali ortalaması
  double get weeklyMoodAverage {
    final recentEntries = getRecentEntries(7);
    if (recentEntries.isEmpty) return 3.0; // Nötr
    
    final sum = recentEntries.map((e) => e.mood.value).reduce((a, b) => a + b);
    return sum / recentEntries.length;
  }
  
  /// En çok kullanılan ruh hali (son 30 gün)
  MoodLevel? get mostCommonMood {
    final recentEntries = getRecentEntries(30);
    if (recentEntries.isEmpty) return null;
    
    final moodCounts = <MoodLevel, int>{};
    for (final entry in recentEntries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    
    return moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// Bugün kaç giriş yapılmış
  int get todayEntryCount {
    return getEntriesForDate(DateTime.now()).length;
  }
  
  /// Toplam giriş sayısı
  int get totalEntryCount => _entries.length;
  
  /// En uzun streak (günlük giriş yapma)
  int get longestStreak {
    if (_entries.isEmpty) return 0;
    
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;
    
    // Günlük benzersiz tarihler al
    final uniqueDates = _entries
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // En yeni önce
    
    for (final date in uniqueDates) {
      if (lastDate == null || date.difference(lastDate).inDays == -1) {
        currentStreak++;
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
      } else if (date.difference(lastDate).inDays < -1) {
        currentStreak = 1;
      }
      lastDate = date;
    }
    
    return maxStreak;
  }
  
  /// Mevcut streak
  int get currentStreak {
    if (_entries.isEmpty) return 0;
    
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    int streak = 0;
    
    for (int i = 0; i < 365; i++) { // Max 1 yıl geriye git
      final checkDate = todayStart.subtract(Duration(days: i));
      final dayEntries = getEntriesForDate(checkDate);
      
      if (dayEntries.isNotEmpty) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  /// Haftalık mood trendini hesapla
  List<double> get weeklyMoodTrend {
    final List<double> trends = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayEntries = getEntriesForDate(date);
      
      if (dayEntries.isNotEmpty) {
        final dayAverage = dayEntries.map((e) => e.mood.value).reduce((a, b) => a + b) / dayEntries.length;
        trends.add(dayAverage);
      } else {
        trends.add(3.0); // Nötr değer
      }
    }
    
    return trends;
  }
  
  /// En verimli gün (en çok pozitif mood)
  String get mostProductiveDay {
    final dayMoods = <String, List<int>>{};
    final weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    
    for (final entry in getRecentEntries(30)) {
      final dayName = weekdays[entry.timestamp.weekday - 1];
      dayMoods[dayName] = (dayMoods[dayName] ?? [])..add(entry.mood.value);
    }
    
    String? bestDay;
    double bestAverage = 0;
    
    dayMoods.forEach((day, moods) {
      if (moods.isNotEmpty) {
        final average = moods.reduce((a, b) => a + b) / moods.length;
        if (average > bestAverage) {
          bestAverage = average;
          bestDay = day;
        }
      }
    });
    
    return bestDay ?? 'Henüz veri yok';
  }
  
  /// En sevilen aktivite
  String get favoriteActivity {
    final activityMoods = <String, List<int>>{};
    
    for (final entry in getRecentEntries(30)) {
      if (entry.sessionType != null) {
        activityMoods[entry.sessionType!] = (activityMoods[entry.sessionType!] ?? [])..add(entry.mood.value);
      }
    }
    
    String? bestActivity;
    double bestAverage = 0;
    
    activityMoods.forEach((activity, moods) {
      if (moods.isNotEmpty) {
        final average = moods.reduce((a, b) => a + b) / moods.length;
        if (average > bestAverage) {
          bestAverage = average;
          bestActivity = activity;
        }
      }
    });
    
    return bestActivity ?? 'Henüz veri yok';
  }
  
  /// İçgörü mesajları
  List<String> get insights {
    final insights = <String>[];
    
    // Mood trendi
    final weeklyTrend = weeklyMoodTrend;
    if (weeklyTrend.length >= 2) {
      final firstHalf = weeklyTrend.take(3).reduce((a, b) => a + b) / 3;
      final secondHalf = weeklyTrend.skip(4).reduce((a, b) => a + b) / 3;
      
      if (secondHalf > firstHalf + 0.5) {
        insights.add('Bu hafta ruh halin giderek iyileşiyor! 📈');
      } else if (firstHalf > secondHalf + 0.5) {
        insights.add('Bu hafta biraz yorgun görünüyorsun. Kendine zaman ayır. 💙');
      }
    }
    
    // Streak
    if (currentStreak >= 7) {
      insights.add('Harika! ${currentStreak} gündür günlüğünü tutuyorsun! 🔥');
    }
    
    // En verimli gün
    final productiveDay = mostProductiveDay;
    if (productiveDay != 'Henüz veri yok') {
      insights.add('$productiveDay günleri sana daha iyi geliyor gibi! 🌟');
    }
    
    // Favori aktivite
    final favActivity = favoriteActivity;
    if (favActivity != 'Henüz veri yok') {
      insights.add('$favActivity senin favorin! Bu aktiviteyi daha sık yapabilirsin. ✨');
    }
    
    // Mood ortalaması
    if (weeklyMoodAverage >= 4.0) {
      insights.add('Bu hafta harika geçiyor! Bu pozitif enerjiyi sürdür! 😄');
    } else if (weeklyMoodAverage <= 2.5) {
      insights.add('Bu hafta zor geçti. Kendine şefkatli ol ve destek al. 🤗');
    }
    
    return insights.isEmpty ? ['Daha fazla veri topladıkça sana özel içgörüler sunacağız! 📊'] : insights;
  }
  
  /// Analytics güncelle
  void _updateAnalytics() {
    _weeklyMoodCounts.clear();
    _activityMoodMap.clear();
    
    final recentEntries = getRecentEntries(7);
    
    // Haftalık mood sayıları
    for (final entry in recentEntries) {
      final moodName = entry.mood.name;
      _weeklyMoodCounts[moodName] = (_weeklyMoodCounts[moodName] ?? 0) + 1;
    }
    
    // Aktivite-mood haritası
    for (final entry in getRecentEntries(30)) {
      if (entry.sessionType != null) {
        _activityMoodMap[entry.sessionType!] = (_activityMoodMap[entry.sessionType!] ?? [])
          ..add(entry.mood.name);
      }
    }
  }
  
  /// Tüm verileri sıfırla
  Future<void> clearAllData() async {
    _entries.clear();
    _weeklyMoodCounts.clear();
    _activityMoodMap.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('journal_entries');
    
    notifyListeners();
  }
  
  /// Export data (gelecekte CSV/JSON export için)
  String exportToJson() {
    return jsonEncode({
      'exportDate': DateTime.now().toIso8601String(),
      'entries': _entries.map((e) => e.toJson()).toList(),
    });
  }
} 