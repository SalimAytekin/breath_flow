import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_preferences_data.dart';
import '../models/user_stats_data.dart';
import '../models/user_favorites_data.dart';
import '../models/weekly_activity.dart';
import '../models/sleep_entry.dart';
import '../models/journal_entry.dart';

/// Merkezi kullanıcı verisi senkronizasyon servisi
/// 
/// Bu servis tüm provider'ların verilerini Firestore ile senkronize eder.
/// Offline-first yaklaşım: Önce local'e yaz, sonra arka planda sync et.
class UserDataSyncService {
  static final UserDataSyncService _instance = UserDataSyncService._internal();
  factory UserDataSyncService() => _instance;
  UserDataSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Kullanıcı koleksiyonu referansı
  CollectionReference get _usersRef => _firestore.collection('users');

  /// Mevcut kullanıcının UID'si
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Kullanıcı giriş yapmış mı?
  bool get isUserLoggedIn => _currentUserId != null;

  // ================================
  // PREFERENCES SYNC
  // ================================

  /// Kullanıcı tercihlerini Firestore'a kaydet
  Future<void> syncPreferences(UserPreferencesData data) async {
    if (!isUserLoggedIn) {
      debugPrint('⚠️ Sync atlandı: Kullanıcı giriş yapmamış');
      return;
    }

    try {
      await _usersRef
          .doc(_currentUserId)
          .collection('preferences')
          .doc('current')
          .set(data.toFirestore(), SetOptions(merge: true));
      
      debugPrint('✅ Tercihler senkronize edildi');
    } catch (e) {
      debugPrint('❌ Tercih senkronizasyon hatası: $e');
      // Hata durumunda sessizce devam et (offline-first)
    }
  }

  /// Kullanıcı tercihlerini Firestore'dan yükle
  Future<UserPreferencesData?> loadPreferences() async {
    if (!isUserLoggedIn) return null;

    try {
      final doc = await _usersRef
          .doc(_currentUserId)
          .collection('preferences')
          .doc('current')
          .get();

      if (doc.exists && doc.data() != null) {
        return UserPreferencesData.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Tercih yükleme hatası: $e');
      return null;
    }
  }

  /// Tercihleri gerçek zamanlı dinle
  Stream<UserPreferencesData?> watchPreferences() {
    if (!isUserLoggedIn) return Stream.value(null);

    return _usersRef
        .doc(_currentUserId)
        .collection('preferences')
        .doc('current')
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserPreferencesData.fromFirestore(doc.data()!);
      }
      return null;
    });
  }

  // ================================
  // STATS SYNC
  // ================================

  /// İstatistikleri Firestore'a kaydet
  Future<void> syncStats(UserStatsData data) async {
    if (!isUserLoggedIn) return;

    try {
      await _usersRef
          .doc(_currentUserId)
          .collection('stats')
          .doc('current')
          .set(data.toFirestore(), SetOptions(merge: true));
      
      debugPrint('✅ İstatistikler senkronize edildi');
    } catch (e) {
      debugPrint('❌ İstatistik senkronizasyon hatası: $e');
    }
  }

  /// İstatistikleri Firestore'dan yükle
  Future<UserStatsData?> loadStats() async {
    if (!isUserLoggedIn) return null;

    try {
      final doc = await _usersRef
          .doc(_currentUserId)
          .collection('stats')
          .doc('current')
          .get();

      if (doc.exists && doc.data() != null) {
        return UserStatsData.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ İstatistik yükleme hatası: $e');
      return null;
    }
  }

  // ================================
  // FAVORITES SYNC
  // ================================

  /// Favorileri Firestore'a kaydet
  Future<void> syncFavorites(UserFavoritesData data) async {
    if (!isUserLoggedIn) return;

    try {
      await _usersRef
          .doc(_currentUserId)
          .collection('favorites')
          .doc('current')
          .set(data.toFirestore(), SetOptions(merge: true));
      
      debugPrint('✅ Favoriler senkronize edildi');
    } catch (e) {
      debugPrint('❌ Favori senkronizasyon hatası: $e');
    }
  }

  /// Favorileri Firestore'dan yükle
  Future<UserFavoritesData?> loadFavorites() async {
    if (!isUserLoggedIn) return null;

    try {
      final doc = await _usersRef
          .doc(_currentUserId)
          .collection('favorites')
          .doc('current')
          .get();

      if (doc.exists && doc.data() != null) {
        return UserFavoritesData.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Favori yükleme hatası: $e');
      return null;
    }
  }

  // ================================
  // WEEKLY ACTIVITIES SYNC
  // ================================

  /// Haftalık aktiviteleri Firestore'a kaydet
  Future<void> syncWeeklyActivities(List<WeeklyActivity> activities) async {
    if (!isUserLoggedIn) return;

    try {
      final batch = _firestore.batch();
      final activitiesRef = _usersRef
          .doc(_currentUserId)
          .collection('activities');

      // Her aktiviteyi ayrı dokümana kaydet (tarih bazlı)
      for (final activity in activities) {
        final docId = activity.date.toIso8601String().split('T')[0]; // YYYY-MM-DD
        final docRef = activitiesRef.doc(docId);
        batch.set(docRef, activity.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('✅ Haftalık aktiviteler senkronize edildi (${activities.length} kayıt)');
    } catch (e) {
      debugPrint('❌ Aktivite senkronizasyon hatası: $e');
    }
  }

  /// Haftalık aktiviteleri Firestore'dan yükle (son 30 gün)
  Future<List<WeeklyActivity>> loadWeeklyActivities() async {
    if (!isUserLoggedIn) return [];

    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final startDate = thirtyDaysAgo.toIso8601String().split('T')[0];

      final querySnapshot = await _usersRef
          .doc(_currentUserId)
          .collection('activities')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDate)
          .get();

      final activities = querySnapshot.docs
          .map((doc) => WeeklyActivity.fromJson(doc.data()))
          .toList();

      debugPrint('✅ Haftalık aktiviteler yüklendi (${activities.length} kayıt)');
      return activities;
    } catch (e) {
      debugPrint('❌ Aktivite yükleme hatası: $e');
      return [];
    }
  }

  // ================================
  // SLEEP ENTRIES SYNC
  // ================================

  /// Uyku kayıtlarını Firestore'a kaydet
  Future<void> syncSleepEntries(List<SleepEntry> entries) async {
    if (!isUserLoggedIn) return;

    try {
      final batch = _firestore.batch();
      final sleepRef = _usersRef
          .doc(_currentUserId)
          .collection('sleep_entries');

      // Her uyku kaydını ayrı dokümana kaydet (tarih bazlı)
      for (final entry in entries) {
        final docId = entry.date.toIso8601String().split('T')[0]; // YYYY-MM-DD
        final docRef = sleepRef.doc(docId);
        batch.set(docRef, entry.toJson(), SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('✅ Uyku kayıtları senkronize edildi (${entries.length} kayıt)');
    } catch (e) {
      debugPrint('❌ Uyku senkronizasyon hatası: $e');
    }
  }

  /// Uyku kayıtlarını Firestore'dan yükle (son 30 gün)
  Future<List<SleepEntry>> loadSleepEntries() async {
    if (!isUserLoggedIn) return [];

    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final startDate = thirtyDaysAgo.toIso8601String().split('T')[0];

      final querySnapshot = await _usersRef
          .doc(_currentUserId)
          .collection('sleep_entries')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDate)
          .get();

      final entries = querySnapshot.docs
          .map((doc) => SleepEntry.fromJson(doc.data()))
          .toList();

      debugPrint('✅ Uyku kayıtları yüklendi (${entries.length} kayıt)');
      return entries;
    } catch (e) {
      debugPrint('❌ Uyku yükleme hatası: $e');
      return [];
    }
  }

  // ================================
  // PREMIUM STATUS SYNC
  // ================================

  /// Premium durumunu Firestore'a kaydet
  Future<void> syncPremiumStatus({
    required bool isPremium,
    DateTime? expiryDate,
    String? purchaseToken,
    String? productId,
  }) async {
    if (!isUserLoggedIn) return;

    try {
      final data = {
        'isPremium': isPremium,
        'premiumExpiryDate': expiryDate != null 
            ? Timestamp.fromDate(expiryDate)
            : null,
        'purchaseToken': purchaseToken,
        'productId': productId,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // 1️⃣ Premium subcollection'a yaz
      await _usersRef
          .doc(_currentUserId)
          .collection('premium')
          .doc('status')
          .set(data, SetOptions(merge: true));
      
      // 2️⃣ Ana user dokümanını da güncelle (isPremium field)
      await _usersRef
          .doc(_currentUserId)
          .update({
            'isPremium': isPremium,
            'premiumExpiryDate': expiryDate != null 
                ? Timestamp.fromDate(expiryDate)
                : null,
          });

      if (kDebugMode) debugPrint('✅ Premium durumu senkronize edildi');
    } catch (e) {
      debugPrint('❌ Premium senkronizasyon hatası: $e');
    }
  }

  /// Premium durumunu Firestore'dan yükle
  Future<Map<String, dynamic>?> loadPremiumStatus() async {
    if (!isUserLoggedIn) return null;

    try {
      final doc = await _usersRef
          .doc(_currentUserId)
          .collection('premium')
          .doc('status')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'isPremium': data['isPremium'] ?? false,
          'expiryDate': data['premiumExpiryDate'] != null
              ? (data['premiumExpiryDate'] as Timestamp).toDate()
              : null,
          'purchaseToken': data['purchaseToken'],
          'productId': data['productId'],
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ Premium yükleme hatası: $e');
      return null;
    }
  }

  /// Premium durumunu gerçek zamanlı dinle
  Stream<Map<String, dynamic>?> watchPremiumStatus() {
    if (!isUserLoggedIn) return Stream.value(null);

    return _usersRef
        .doc(_currentUserId)
        .collection('premium')
        .doc('status')
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'isPremium': data['isPremium'] ?? false,
          'expiryDate': data['premiumExpiryDate'] != null
              ? (data['premiumExpiryDate'] as Timestamp).toDate()
              : null,
          'purchaseToken': data['purchaseToken'],
          'productId': data['productId'],
        };
      }
      return null;
    });
  }

  // ================================
  // FULL SYNC (İlk giriş veya restore)
  // ================================

  /// Tüm kullanıcı verilerini Firestore'a yükle (Backup)
  Future<void> fullBackup({
    UserPreferencesData? preferences,
    UserStatsData? stats,
    UserFavoritesData? favorites,
    List<WeeklyActivity>? activities,
    List<SleepEntry>? sleepEntries,
  }) async {
    if (!isUserLoggedIn) {
      debugPrint('⚠️ Full backup atlandı: Kullanıcı giriş yapmamış');
      return;
    }

    debugPrint('🔄 Full backup başlatılıyor...');

    try {
      // Paralel olarak tüm verileri sync et
      await Future.wait([
        if (preferences != null) syncPreferences(preferences),
        if (stats != null) syncStats(stats),
        if (favorites != null) syncFavorites(favorites),
        if (activities != null) syncWeeklyActivities(activities),
        if (sleepEntries != null) syncSleepEntries(sleepEntries),
      ]);

      debugPrint('✅ Full backup tamamlandı');
    } catch (e) {
      debugPrint('❌ Full backup hatası: $e');
    }
  }

  /// Tüm kullanıcı verilerini Firestore'dan yükle (Restore)
  Future<Map<String, dynamic>> fullRestore() async {
    if (!isUserLoggedIn) {
      debugPrint('⚠️ Full restore atlandı: Kullanıcı giriş yapmamış');
      return {};
    }

    debugPrint('🔄 Full restore başlatılıyor...');

    try {
      // Paralel olarak tüm verileri yükle
      final results = await Future.wait([
        loadPreferences(),
        loadStats(),
        loadFavorites(),
        loadWeeklyActivities(),
        loadSleepEntries(),
        loadPremiumStatus(),
      ]);

      final data = {
        'preferences': results[0],
        'stats': results[1],
        'favorites': results[2],
        'activities': results[3],
        'sleepEntries': results[4],
        'premium': results[5],
      };

      debugPrint('✅ Full restore tamamlandı');
      return data;
    } catch (e) {
      debugPrint('❌ Full restore hatası: $e');
      return {};
    }
  }

  // ================================
  // JOURNAL ENTRIES SYNC
  // ================================

  /// Günlük kayıtlarını Firestore'a kaydet
  Future<void> syncJournalEntries(List<JournalEntry> entries) async {
    if (!isUserLoggedIn) return;

    try {
      final batch = _firestore.batch();
      final journalRef = _usersRef
          .doc(_currentUserId)
          .collection('journal_entries');

      // Her kaydı ayrı dokümana kaydet (tarih bazlı)
      for (final entry in entries) {
        final docId = entry.date.toIso8601String().split('T')[0]; // YYYY-MM-DD
        final docRef = journalRef.doc(docId);
        batch.set(docRef, entry.toFirestore(), SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('✅ Günlük kayıtları senkronize edildi (${entries.length} kayıt)');
    } catch (e) {
      debugPrint('❌ Günlük senkronizasyon hatası: $e');
    }
  }

  /// Günlük kayıtlarını Firestore'dan yükle (son 90 gün)
  Future<List<JournalEntry>> loadJournalEntries() async {
    if (!isUserLoggedIn) return [];

    try {
      final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
      final startDate = ninetyDaysAgo.toIso8601String().split('T')[0];

      final querySnapshot = await _usersRef
          .doc(_currentUserId)
          .collection('journal_entries')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDate)
          .get();

      final entries = querySnapshot.docs
          .map((doc) => JournalEntry.fromFirestore(doc.data()))
          .toList();

      debugPrint('✅ Günlük kayıtları yüklendi (${entries.length} kayıt)');
      return entries;
    } catch (e) {
      debugPrint('❌ Günlük yükleme hatası: $e');
      return [];
    }
  }

  // ================================
  // CONFLICT RESOLUTION
  // ================================

  /// Veri çakışması durumunda en güncel olanı seç
  /// (Server timestamp'e göre)
  T resolveConflict<T>({
    required T localData,
    required T remoteData,
    required DateTime? localTimestamp,
    required DateTime? remoteTimestamp,
  }) {
    if (localTimestamp == null) return remoteData;
    if (remoteTimestamp == null) return localData;
    
    // En yeni veriyi kullan
    return remoteTimestamp.isAfter(localTimestamp) 
        ? remoteData 
        : localData;
  }
}
