import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/journal_entry.dart';
import '../services/user_data_sync_service.dart';
import '../core/analytics/analytics_service.dart';

/// Uyku günlüğü provider'ı
class JournalProvider extends ChangeNotifier {
  // 🔄 Firestore sync servisi
  final UserDataSyncService _syncService = UserDataSyncService();
  bool _isSyncing = false;
  
  List<JournalEntry> _entries = [];
  
  // Getters
  List<JournalEntry> get entries => List.unmodifiable(_entries);
  
  JournalProvider() {
    _loadEntries();
  }
  
  /// Kayıtları yükle
  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('journal_entries') ?? [];
      
      _entries = entriesJson.map((jsonString) {
        final json = jsonDecode(jsonString);
        return JournalEntry.fromJson(json);
      }).toList();
      
      // Tarihe göre sırala (en yeni önce)
      _entries.sort((a, b) => b.date.compareTo(a.date));
      
      notifyListeners();
      
      // 🔄 Firestore'dan sync et (arka planda)
      if (_syncService.isUserLoggedIn) {
        _syncFromFirestore();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Journal load error: $e');
    }
  }
  
  /// Kayıtları kaydet
  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = _entries.map((entry) {
        return jsonEncode(entry.toJson());
      }).toList();
      
      await prefs.setStringList('journal_entries', entriesJson);
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Journal save error: $e');
    }
  }
  
  /// Yeni kayıt ekle veya güncelle
  Future<void> addOrUpdateEntry(JournalEntry entry) async {
    try {
      // Aynı gün için kayıt var mı kontrol et
      final existingIndex = _entries.indexWhere((e) =>
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day
      );
      
      if (existingIndex != -1) {
        // Güncelle
        _entries[existingIndex] = entry;
      } else {
        // Yeni ekle
        _entries.add(entry);
      }
      
      // Tarihe göre sırala
      _entries.sort((a, b) => b.date.compareTo(a.date));
      
      await _saveEntries();
      
      // Analytics
      await AnalyticsService.instance.logEvent('journal_entry_added', {
        'mood': entry.mood,
        'has_note': entry.note.isNotEmpty.toString(),
        'has_dream': entry.dream.isNotEmpty.toString(),
      });
      
      // 🔄 Firestore'a sync et
      _syncToFirestore();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Journal add error: $e');
    }
  }
  
  /// Kayıt sil
  Future<void> deleteEntry(DateTime date) async {
    try {
      _entries.removeWhere((entry) =>
        entry.date.year == date.year &&
        entry.date.month == date.month &&
        entry.date.day == date.day
      );
      
      await _saveEntries();
      
      // Analytics
      await AnalyticsService.instance.logEvent('journal_entry_deleted', {
        'deleted_date': date.toIso8601String(),
      });
      
      // 🔄 Firestore'a sync et
      _syncToFirestore();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Journal delete error: $e');
    }
  }
  
  /// Belirli bir gün için kayıt al
  JournalEntry? getEntryForDate(DateTime date) {
    return _entries.where((entry) =>
      entry.date.year == date.year &&
      entry.date.month == date.month &&
      entry.date.day == date.day
    ).firstOrNull;
  }
  
  // ================================
  // 🔄 FIRESTORE SYNC METODLARI
  // ================================
  
  /// Firestore'dan kayıtları yükle ve local ile birleştir
  Future<void> _syncFromFirestore() async {
    if (_isSyncing || !_syncService.isUserLoggedIn) return;
    _isSyncing = true;
    
    try {
      if (kDebugMode) debugPrint('🔄 Journal Firestore sync başlatılıyor...');
      
      final remoteEntries = await _syncService.loadJournalEntries();
      
      if (remoteEntries.isNotEmpty) {
        // Tarih bazlı birleştirme
        final entryMap = <String, JournalEntry>{};
        
        // Local kayıtları ekle
        for (final entry in _entries) {
          final key = entry.date.toIso8601String().split('T')[0];
          entryMap[key] = entry;
        }
        
        // Remote kayıtları ekle (local yoksa)
        for (final entry in remoteEntries) {
          final key = entry.date.toIso8601String().split('T')[0];
          if (!entryMap.containsKey(key)) {
            entryMap[key] = entry;
          }
          // Local öncelikli
        }
        
        _entries = entryMap.values.toList();
        _entries.sort((a, b) => b.date.compareTo(a.date));
        
        await _saveEntries();
        notifyListeners();
        
        if (kDebugMode) debugPrint('✅ Journal Firestore sync tamamlandı (${remoteEntries.length} kayıt)');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Journal Firestore sync hatası: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Kayıtları Firestore'a kaydet
  Future<void> _syncToFirestore() async {
    if (!_syncService.isUserLoggedIn) {
      if (kDebugMode) debugPrint('⚠️ Journal sync atlandı: Kullanıcı giriş yapmamış');
      return;
    }

    if (_entries.isEmpty) {
      if (kDebugMode) debugPrint('⚠️ Journal sync atlandı: Gönderilecek günlük kaydı yok (entries boş)');
      return;
    }

    if (kDebugMode) debugPrint('🔄 Journal Firestore sync başlatılıyor (${_entries.length} kayıt)...');

    // Arka planda sync et
    _syncService.syncJournalEntries(_entries).then((_) {
      if (kDebugMode) debugPrint('✅ Journal Firestore sync isteği gönderildi (${_entries.length} kayıt)');
    }).catchError((e) {
      if (kDebugMode) debugPrint('❌ Journal sync hatası: $e');
    });
  }
  
  /// Manuel full sync
  Future<void> performFullSync() async {
    if (kDebugMode) debugPrint('🔄 Journal full sync başlatılıyor...');
    
    await _syncFromFirestore();
    await _syncToFirestore();
    
    if (kDebugMode) debugPrint('✅ Journal full sync tamamlandı');
  }
  
  // ================================
  // 🚪 OTURUM KAPATMA - VERİ TEMİZLEME
  // ================================
  
  /// Oturum kapatıldığında TÜM günlük verilerini temizle
  /// Yeni kullanıcı giriş yaptığında Firestore'dan kendi verilerini çekecek
  Future<void> clearAllDataOnLogout() async {
    if (kDebugMode) debugPrint('🚪 Journal verileri temizleniyor...');
    
    // 1. Memory'deki verileri temizle
    _entries.clear();
    
    // 2. SharedPreferences'tan temizle
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('journal_entries');
      
      if (kDebugMode) debugPrint('✅ Journal SharedPreferences temizlendi');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Journal temizleme hatası: $e');
    }
    
    // 3. UI'ı güncelle
    notifyListeners();
    
    if (kDebugMode) debugPrint('✅ Journal verileri temizlendi');
  }
}
