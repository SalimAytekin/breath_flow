import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:convert';
import '../services/user_data_sync_service.dart';
import '../services/payment_service.dart';
import '../core/analytics/analytics_service.dart';
import '../models/premium_trigger.dart';

class PremiumProvider extends ChangeNotifier {
  // 🔄 Firestore sync servisi
  final UserDataSyncService _syncService = UserDataSyncService();
  final PaymentService _paymentService = PaymentService.instance;
  // 🔒 Sync bayrağı
  bool _isSyncing = false;
  
  // 🔒 Dialog gösterildi bayrağı
  bool _hasShownExpiredDialog = false;
  
  // Ana premium durumu
  bool _isPremiumUser = false;
  DateTime? _premiumExpiryDate;
  String? _purchaseToken; // Google Play satın alma token'ı
  String? _productId; // Satın alınan ürün ID'si
  
  // 🔔 Satın alma başarılı bildirimi için
  bool _justPurchased = false;
  bool get justPurchased => _justPurchased;
  
  /// Satın alma bildirimini temizle (UI gösterdikten sonra çağrılmalı)
  void clearPurchaseNotification() {
    _justPurchased = false;
  }
  
  // Test modu kontrolü
  bool _testMode = false; // 🔥 GERÇEK PREMIUM SİSTEMİ AKTİF!
  
  // Kullanıcı analitikleri ve tetikleyici sistemi
  Map<String, dynamic> _userContext = {};
  Map<String, DateTime> _triggerCooldowns = {};
  List<String> _dismissedTriggers = [];
  PremiumTrigger? _currentActiveTrigger;
  Map<String, int> _triggerShowCounts = {};
  
  // Analytics veriler
  Map<String, dynamic> _analyticsData = {
    'totalSessions': 0,
    'breathingSessionsCompleted': 0,
    'differentTechniquesUsed': 0,
    'savedMixesCount': 0,
    'dailyUsageDays': 0,
    'weeklyGoalCompletion': 0.0,
    'consecutiveWeeks': 0,
    'featuresUsed': 0,
    'measurementCount': 0,
    'lastUsageDate': null,
  };

  // Getters
  bool get isPremiumUser {
    if (_testMode) {
      return _isPremiumUser;
    }
    // Production modunda: Local premium durumu + süre kontrolü
    // NOT: Kullanıcı bazlı kontrol _syncFromFirestore ve callback'te yapılıyor
    return _isPremiumUser && !_isPremiumExpired();
  }
  
  bool get isTestMode => _testMode;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;
  Map<String, dynamic> get userContext => _userContext;
  PremiumTrigger? get currentActiveTrigger => _currentActiveTrigger;
  Map<String, dynamic> get analyticsData => _analyticsData;
  
  // ============================================
  // 🎯 MERKEZİ PREMIUM KONTROL SİSTEMİ
  // ============================================
  
  /// Premium özellik ID'leri
  static const String featureUnlimitedMixes = 'unlimited_mixes';
  static const String featurePremiumSounds = 'premium_sounds';
  static const String featurePremiumExercises = 'premium_exercises';
  static const String featureSleepAnalytics = 'sleep_analytics';
  static const String featureSleepJournal = 'sleep_journal';
  static const String featureAdvancedStats = 'advanced_stats';
  static const String featureNoAds = 'ad_free';
  
  /// Mix limiti (ücretsiz kullanıcılar için)
  static const int freeMixLimit = 3;
  
  /// Belirli bir özelliğe erişim var mı?
  bool canAccessFeature(String featureId) {
    // Premium kullanıcılar her şeye erişebilir
    if (isPremiumUser) return true;
    
    // Ücretsiz kullanıcılar için kısıtlamalar
    switch (featureId) {
      case featureUnlimitedMixes:
      case featurePremiumSounds:
      case featurePremiumExercises:
      case featureSleepAnalytics:
      case featureSleepJournal:
      case featureAdvancedStats:
      case featureNoAds:
        return false;
      default:
        return true; // Bilinmeyen özellikler varsayılan olarak açık
    }
  }
  
  /// Premium içerik mi kontrol et (ses, egzersiz vb.)
  bool canAccessPremiumContent(bool isContentPremium) {
    if (!isContentPremium) return true; // Ücretsiz içerik
    return isPremiumUser; // Premium içerik için premium gerekli
  }
  
  /// Mix limiti kontrolü
  bool canAddToMix(int currentMixCount) {
    if (isPremiumUser) return true;
    return currentMixCount < freeMixLimit;
  }
  
  /// Kalan mix hakkı
  int getRemainingMixSlots(int currentMixCount) {
    if (isPremiumUser) return 999; // Sınırsız
    return (freeMixLimit - currentMixCount).clamp(0, freeMixLimit);
  }
  
  // Premium süresi dolmuş mu kontrol et
  bool _isPremiumExpired() {
    if (_premiumExpiryDate == null) return false;
    return _premiumExpiryDate!.isBefore(DateTime.now());
  }
  
  // Test modunu aç/kapat
  void setTestMode(bool enabled) {
    _testMode = enabled;
    if (kDebugMode) print('🚨 DEBUG: Test modu ${enabled ? 'açıldı' : 'kapatıldı'}');
    notifyListeners();
  }

  PremiumProvider() {
    _initializeData();
    _setupPaymentServiceCallback();
  }
  
  /// 🔔 PaymentService callback'ini ayarla
  /// Satın alma başarılı olduğunda anında bilgilendirilecek
  void _setupPaymentServiceCallback() {
    _paymentService.onPurchaseSuccess = (purchaseDetails) async {
      final isRestore = purchaseDetails.status == PurchaseStatus.restored;
      
      if (kDebugMode) debugPrint('🎉 Satın alma callback tetiklendi: ${purchaseDetails.productID} (restore: $isRestore)');
      
      // 🔐 YENİ SATIN ALMA: Mevcut kullanıcı yeni sahip olacak
      // Callback sadece BAŞARILI satın alma sonrası tetiklenir
      // Bu yüzden mevcut kullanıcıyı sahip olarak kabul ediyoruz
      final currentUserId = _paymentService.currentUserId;
      
      if (kDebugMode) {
        debugPrint('🔐 Callback - Satın alma:');
        debugPrint('   currentUserId: $currentUserId');
        debugPrint('   productId: ${purchaseDetails.productID}');
        debugPrint('   isRestore: $isRestore');
      }
      
      // Kullanıcı giriş yapmamışsa işleme
      if (currentUserId == null) {
        if (kDebugMode) debugPrint('⚠️ Kullanıcı giriş yapmamış - callback atlanıyor');
        return;
      }
      
      // PaymentService'ten güncel durumu al
      _isPremiumUser = true;
      _premiumExpiryDate = _paymentService.premiumExpiryDate;
      _productId = _paymentService.activeSubscriptionId;
      
      // 🔔 Satın alma başarılı bildirimini SADECE YENİ SATIN ALMADA göster
      // Restore durumunda gösterme (her girişte tetiklenir)
      if (!isRestore) {
        _justPurchased = true;
      }
      
      // Local'e kaydet
      await _savePremiumStatus();
      
      // Firestore'a sync et - SADECE bu kullanıcı için
      await _syncPremiumToFirestore();
      
      // Analytics - sadece yeni satın alma için
      if (!isRestore) {
        AnalyticsService.instance.logEvent('premium_purchase_success', {
          'product_id': purchaseDetails.productID,
        }).catchError((e) => debugPrint('Analytics hatası: $e'));
      }
      
      // 🚨 UI'I ANİNDA GÜNCELLE
      notifyListeners();
      
      if (kDebugMode) debugPrint('✅ Premium ${isRestore ? "restore edildi" : "aktifleştirildi"}!');
    };
  }

  Future<void> _initializeData() async {
    await _loadPremiumStatus();
    await _loadUserContext();
    await _loadAnalyticsData();
    await _loadTriggerData();
    
    // 🔄 Firestore'dan sync et (arka planda)
    if (_syncService.isUserLoggedIn) {
      _syncFromFirestore();
    }
    
    notifyListeners();
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_testMode) {
        // Test modunda premium durumunu sıfırla
        _isPremiumUser = false;
        await prefs.setBool('is_premium_user', false);
        await prefs.remove('premium_expiry_date');
        await prefs.remove('purchase_token');
        await prefs.remove('product_id');
        if (kDebugMode) print('🚨 TEST: Premium durumu sıfırlandı (Test modu aktif)');
      } else {
        // Production modunda gerçek premium durumunu yükle
        _isPremiumUser = prefs.getBool('is_premium_user') ?? false;
        _purchaseToken = prefs.getString('purchase_token');
        _productId = prefs.getString('product_id');
        
        final expiryString = prefs.getString('premium_expiry_date');
        if (expiryString != null && expiryString.isNotEmpty) {
          try {
            _premiumExpiryDate = DateTime.parse(expiryString);
            
            // Süre dolmuşsa premium'u iptal et
            if (_isPremiumExpired()) {
              _isPremiumUser = false;
              await _savePremiumStatus();
              if (kDebugMode) print('🚨 Premium süresi dolmuş, iptal edildi');
            }
          } catch (e) {
            debugPrint('Tarih parsing hatası: $e');
            _premiumExpiryDate = null;
          }
        }
      }
    } catch (e) {
      debugPrint('Premium durumu yüklenirken hata: $e');
      // Fallback değerler
      _isPremiumUser = false;
      _premiumExpiryDate = null;
    }
  }

  Future<void> _savePremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium_user', _isPremiumUser);
      
      if (_premiumExpiryDate != null) {
        await prefs.setString('premium_expiry_date', _premiumExpiryDate!.toIso8601String());
      } else {
        await prefs.remove('premium_expiry_date');
      }
      
      if (_purchaseToken != null) {
        await prefs.setString('purchase_token', _purchaseToken!);
      } else {
        await prefs.remove('purchase_token');
      }
      
      if (_productId != null) {
        await prefs.setString('product_id', _productId!);
      } else {
        await prefs.remove('product_id');
      }
    } catch (e) {
      debugPrint('Premium durumu kaydedilirken hata: $e');
    }
  }

  // ⚠️ ESKİ METODLAR KALDIRILDI - Artık UserDataSyncService kullanılıyor
  // refreshFromAuthClaims(), refreshFromFirestore(), synchronizePremiumStatus()
  // yerine _syncFromFirestore() ve performFullSync() kullanılıyor

  Future<void> _loadUserContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contextJson = prefs.getString('user_context');
      if (contextJson != null) {
        _userContext = Map<String, dynamic>.from(json.decode(contextJson));
      }
    } catch (e) {
      debugPrint('Kullanıcı bağlamı yüklenirken hata: $e');
    }
  }

  Future<void> _saveUserContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_context', json.encode(_userContext));
    } catch (e) {
      debugPrint('Kullanıcı bağlamı kaydedilirken hata: $e');
    }
  }

  Future<void> _loadAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyticsJson = prefs.getString('analytics_data');
      if (analyticsJson != null) {
        final loadedData = Map<String, dynamic>.from(json.decode(analyticsJson));
        _analyticsData.addAll(loadedData);
      }
    } catch (e) {
      debugPrint('Analitik veriler yüklenirken hata: $e');
    }
  }

  Future<void> _saveAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('analytics_data', json.encode(_analyticsData));
    } catch (e) {
      debugPrint('Analitik veriler kaydedilirken hata: $e');
    }
  }

  Future<void> _loadTriggerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cooldown verilerini yükle
      final cooldownJson = prefs.getString('trigger_cooldowns');
      if (cooldownJson != null) {
        final cooldownData = Map<String, dynamic>.from(json.decode(cooldownJson));
        _triggerCooldowns = cooldownData.map((key, value) => 
          MapEntry(key, DateTime.parse(value)));
      }
      
      // Dismissed triggers
      _dismissedTriggers = prefs.getStringList('dismissed_triggers') ?? [];
      
      // Show counts
      final showCountsJson = prefs.getString('trigger_show_counts');
      if (showCountsJson != null) {
        _triggerShowCounts = Map<String, int>.from(json.decode(showCountsJson));
      }
    } catch (e) {
      debugPrint('Tetikleyici verileri yüklenirken hata: $e');
    }
  }

  Future<void> _saveTriggerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cooldown verilerini kaydet
      final cooldownData = _triggerCooldowns.map((key, value) => 
        MapEntry(key, value.toIso8601String()));
      await prefs.setString('trigger_cooldowns', json.encode(cooldownData));
      
      // Dismissed triggers
      await prefs.setStringList('dismissed_triggers', _dismissedTriggers);
      
      // Show counts
      await prefs.setString('trigger_show_counts', json.encode(_triggerShowCounts));
    } catch (e) {
      debugPrint('Tetikleyici verileri kaydedilirken hata: $e');
    }
  }

  // Premium durumu güncelle
  Future<void> setPremiumStatus(
    bool isPremium, {
    DateTime? expiryDate,
    String? purchaseToken,
    String? productId,
  }) async {
    _isPremiumUser = isPremium;
    _premiumExpiryDate = expiryDate;
    _purchaseToken = purchaseToken;
    _productId = productId;
    
    await _savePremiumStatus();
    
    // 🔄 Firestore'a sync et
    _syncPremiumToFirestore();
    
    notifyListeners();
  }

  // Kullanıcı davranışını takip et
  Future<void> trackUserAction(String action, Map<String, dynamic> data) async {
    // Analytics verilerini güncelle
    switch (action) {
      case 'session_completed':
        _analyticsData['totalSessions'] = (_analyticsData['totalSessions'] ?? 0) + 1;
        break;
      case 'breathing_session_completed':
        _analyticsData['breathingSessionsCompleted'] = 
          (_analyticsData['breathingSessionsCompleted'] ?? 0) + 1;
        break;
      case 'technique_used':
        final techniques = Set<String>.from(_userContext['usedTechniques'] ?? []);
        techniques.add(data['technique'] ?? '');
        _userContext['usedTechniques'] = techniques.toList();
        _analyticsData['differentTechniquesUsed'] = techniques.length;
        break;
      case 'mix_saved':
        _analyticsData['savedMixesCount'] = (_analyticsData['savedMixesCount'] ?? 0) + 1;
        break;
      case 'hrv_measurement':
        _analyticsData['measurementCount'] = (_analyticsData['measurementCount'] ?? 0) + 1;
        break;
      case 'daily_usage':
        _updateDailyUsage();
        break;
      case 'weekly_goal_completed':
        _analyticsData['weeklyGoalCompletion'] = data['completion'] ?? 1.0;
        _analyticsData['consecutiveWeeks'] = (_analyticsData['consecutiveWeeks'] ?? 0) + 1;
        break;
      case 'feature_used':
        final features = Set<String>.from(_userContext['usedFeatures'] ?? []);
        features.add(data['feature'] ?? '');
        _userContext['usedFeatures'] = features.toList();
        _analyticsData['featuresUsed'] = features.length;
        break;
    }

    // Kullanıcı bağlamını güncelle
    _userContext.addAll(data);
    _userContext['lastAction'] = action;
    _userContext['lastActionTime'] = DateTime.now().toIso8601String();

    await _saveUserContext();
    await _saveAnalyticsData();

    // Tetikleyicileri kontrol et
    await _checkTriggers();
  }

  void _updateDailyUsage() {
    final now = DateTime.now();
    final lastUsage = _analyticsData['lastUsageDate'];
    
    if (lastUsage == null || 
        DateTime.parse(lastUsage).day != now.day) {
      _analyticsData['dailyUsageDays'] = (_analyticsData['dailyUsageDays'] ?? 0) + 1;
      _analyticsData['lastUsageDate'] = now.toIso8601String();
    }
  }

  // Tetikleyicileri kontrol et
  Future<void> _checkTriggers() async {
    // Premium sistemi askıya alındı - tetikleyici gösterme
    if (_testMode) {
      return;
    }
    
    if (isPremiumUser) return; // Premium kullanıcılara gösterme

    // Kullanıcı bağlamını analytics ile birleştir
    final fullContext = Map<String, dynamic>.from(_userContext);
    fullContext.addAll(_analyticsData);

    // Tetikleyicileri önceliğe göre sırala
    final sortedTriggers = List<PremiumTrigger>.from(PremiumTrigger.predefinedTriggers);
    sortedTriggers.sort((a, b) => b.priority.compareTo(a.priority));

    for (final trigger in sortedTriggers) {
      // Cooldown kontrolü
      if (_triggerCooldowns.containsKey(trigger.id)) {
        final cooldownEnd = _triggerCooldowns[trigger.id]!;
        if (DateTime.now().isBefore(cooldownEnd)) continue;
      }

      // Dismissed kontrolü
      if (_dismissedTriggers.contains(trigger.id)) continue;

      // Show count kontrolü (daha esnek limit)
      final showCount = _triggerShowCounts[trigger.id] ?? 0;
      if (showCount >= 5) continue; // 3 yerine 5

      // Koşulları kontrol et
      if (trigger.checkConditions(fullContext)) {
        _currentActiveTrigger = trigger;
        _triggerShowCounts[trigger.id] = showCount + 1;
        await _saveTriggerData();
        notifyListeners();
        if (kDebugMode) print('🚨 DEBUG: Tetikleyici gösterildi: ${trigger.id}');
        break; // Sadece bir tetikleyici göster
      }
    }
  }

  // Tetikleyiciyi göster
  void showTrigger(PremiumTrigger trigger) {
    _currentActiveTrigger = trigger;
    notifyListeners();
  }

  // Tetikleyiciyi dismiss et
  Future<void> dismissTrigger(String triggerId, {bool permanent = false}) async {
    _currentActiveTrigger = null;
    
    if (permanent) {
      _dismissedTriggers.add(triggerId);
    } else {
      // Cooldown uygula
      final trigger = PremiumTrigger.predefinedTriggers
        .firstWhere((t) => t.id == triggerId);
      _triggerCooldowns[triggerId] = DateTime.now().add(trigger.cooldown);
    }
    
    await _saveTriggerData();
    notifyListeners();
  }

  // ESKİ METOD SİLİNDİ - Yeni purchasePremium metodu aşağıda (satır 745)
  
  // Test için premium durumunu manuel ayarla
  Future<void> setTestPremiumStatus(bool isPremium, {Duration? duration}) async {
    if (!_testMode) {
      if (kDebugMode) print('⚠️ Test modu kapalı, premium durumu değiştirilemez');
      return;
    }
    
    _isPremiumUser = isPremium;
    if (isPremium && duration != null) {
      _premiumExpiryDate = DateTime.now().add(duration);
    } else if (!isPremium) {
      _premiumExpiryDate = null;
    }
    
    await _savePremiumStatus();
    if (kDebugMode) print('🚨 TEST: Premium durumu manuel olarak ayarlandı: $isPremium');
    notifyListeners();
  }

  // NOT: canAccessFeature metodu yukarıda merkezi sistem olarak tanımlandı
  
  // Premium gerektiren özellikler
  bool isPremiumFeature(String featureId) {
    // Premium sistemi askıya alındı - hiçbir özellik premium değil
    if (_testMode) {
      return false;
    }
    
    const premiumFeatures = [
      'premium_sounds',
      'advanced_breathing',
      'advanced_hrv',
      'expert_content',
      'premium_stories',
      'unlimited_mixes',
      'hd_sounds',
      'custom_programs',
      'personalized_insights',
      'advanced_journeys',
    ];
    
    return premiumFeatures.contains(featureId);
  }
  
  // Özellik limiti kontrolü
  bool checkFeatureLimit(String featureId, int currentUsage, int maxFreeUsage) {
    // Premium sistemi askıya alındı - limit yok
    if (_testMode) {
      return true;
    }
    
    if (isPremiumUser) return true;
    return currentUsage < maxFreeUsage;
  }

  // Premium gerektiren özellik kullanımında tetikleyici göster
  void showFeatureLimitTrigger(String featureId) {
    final trigger = PremiumTrigger.predefinedTriggers.firstWhere(
      (t) => t.targetFeatures.contains(featureId),
      orElse: () => PremiumTrigger.predefinedTriggers.first,
    );
    
    showTrigger(trigger);
  }

  // A/B test için tetikleyici varyantları
  PremiumTrigger? getOptimalTrigger(String context) {
    if (_isPremiumUser) return null;
    
    final availableTriggers = PremiumTrigger.predefinedTriggers.where((trigger) {
      // Cooldown ve dismiss kontrolü
      if (_triggerCooldowns.containsKey(trigger.id)) {
        final cooldownEnd = _triggerCooldowns[trigger.id]!;
        if (DateTime.now().isBefore(cooldownEnd)) return false;
      }
      
      if (_dismissedTriggers.contains(trigger.id)) return false;
      
      // Show count kontrolü
      final showCount = _triggerShowCounts[trigger.id] ?? 0;
      if (showCount >= 3) return false;
      
      return true;
    }).toList();
    
    if (availableTriggers.isEmpty) return null;
    
    // Önceliğe göre sırala
    availableTriggers.sort((a, b) => b.priority.compareTo(a.priority));
    
    return availableTriggers.first;
  }

  // Premium dönüşüm analitikleri
  Map<String, dynamic> getConversionAnalytics() {
    return {
      'totalTriggersShown': _triggerShowCounts.values.fold(0, (a, b) => a + b),
      'dismissedCount': _dismissedTriggers.length,
      'averageShowsPerTrigger': _triggerShowCounts.isEmpty 
        ? 0 
        : _triggerShowCounts.values.fold(0, (a, b) => a + b) / _triggerShowCounts.length,
      'mostShownTrigger': _triggerShowCounts.entries
        .fold<MapEntry<String, int>?>(null, (prev, curr) => 
          prev == null || curr.value > prev.value ? curr : prev)?.key,
      'conversionRate': _isPremiumUser ? 1.0 : 0.0,
    };
  }

  // Debug için manuel tetikleyici test
  void debugTrigger(String triggerId) {
    final trigger = PremiumTrigger.predefinedTriggers
      .firstWhere((t) => t.id == triggerId);
    showTrigger(trigger);
  }
  
  // Debug için tetikleyici verilerini sıfırla
  Future<void> resetTriggerData() async {
    _triggerCooldowns.clear();
    _dismissedTriggers.clear();
    _triggerShowCounts.clear();
    _currentActiveTrigger = null;
    await _saveTriggerData();
    if (kDebugMode) print('🚨 DEBUG: Tetikleyici verileri sıfırlandı');
    notifyListeners();
  }
  
  // Premium durumu hakkında detaylı bilgi
  Map<String, dynamic> getPremiumStatusInfo() {
    return {
      'isPremiumUser': isPremiumUser,
      'isTestMode': _testMode,
      'premiumExpiryDate': _premiumExpiryDate?.toIso8601String(),
      'isExpired': _isPremiumExpired(),
      'remainingDays': _premiumExpiryDate != null 
        ? _premiumExpiryDate!.difference(DateTime.now()).inDays 
        : 0,
      'activeTriggers': _currentActiveTrigger?.id,
      'totalTriggersShown': _triggerShowCounts.values.fold(0, (a, b) => a + b),
      'dismissedTriggers': _dismissedTriggers.length,
    };
  }

  // Kullanıcı journey'ini takip et
  void trackUserJourney(String milestone) {
    final journeys = List<String>.from(_userContext['userJourneys'] ?? []);
    journeys.add('${DateTime.now().toIso8601String()}: $milestone');
    _userContext['userJourneys'] = journeys;
    _saveUserContext();
  }

  // Premium özellik kullanım istatistikleri
  Map<String, dynamic> getPremiumUsageStats() {
    return {
      'premiumSoundsUsed': _userContext['premiumSoundsUsed'] ?? 0,
      'advancedBreathingUsed': _userContext['advancedBreathingUsed'] ?? 0,
      'expertContentAccessed': _userContext['expertContentAccessed'] ?? 0,
      'premiumStoriesListened': _userContext['premiumStoriesListened'] ?? 0,
      'advancedHRVUsed': _userContext['advancedHRVUsed'] ?? 0,
    };
  }
  
  // ================================
  // � YARDIMCI METODLAR
  // ================================
  
  /// 🔐 Firestore'dan direkt premium verisi oku (race condition önlemek için)
  Future<Map<String, dynamic>?> _getFirestorePremiumDataDirect() async {
    if (!_syncService.isUserLoggedIn) return null;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return null;
      
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('premium')
          .doc('status')
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'isPremium': data['isPremium'] ?? false,
          'expiryDate': data['expiryDate'] != null 
              ? (data['expiryDate'] as Timestamp).toDate() 
              : null,
          'purchaseToken': data['purchaseToken'],
          'productId': data['productId'],
        };
      }
    } catch (e) {
      debugPrint('❌ Firestore direkt okuma hatası: $e');
    }
    return null;
  }
  
  /// 🔐 Firestore'daki purchase token'ı doğrula
  Future<bool> _verifyPurchaseTokenInFirestore() async {
    final firestoreData = await _getFirestorePremiumDataDirect();
    if (firestoreData == null) return false;
    
    final firestoreToken = firestoreData['purchaseToken'] as String?;
    final localToken = _purchaseToken;
    
    return firestoreToken != null && 
           localToken != null && 
           firestoreToken == localToken;
  }
  
  /// 🔐 İnternet bağlantısı kontrolü
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('connection_test')
          .doc('ping')
          .get()
          .timeout(const Duration(seconds: 3));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 🔐 Retry mekanizması ile restore (PaymentService üzerinden)
  Future<bool> _restoreWithRetry({int maxRetries = 3}) async {
    return await _paymentService.restoreWithRetry(maxRetries: maxRetries);
  }
  
  // ================================
  // � FIRESTORE SYNC METODLARI
  // ================================
  
  /// Firestore'dan premium durumunu yükle ve local ile birleştir
  Future<void> _syncFromFirestore() async {
    if (_isSyncing || !_syncService.isUserLoggedIn) return;
    _isSyncing = true;
    
    try {
      debugPrint('🔄 Premium Firestore sync başlatılıyor...');
      
      final remotePremium = await _syncService.loadPremiumStatus();
      
      if (remotePremium != null) {
        final remoteIsPremium = remotePremium['isPremium'] as bool;
        final remoteExpiry = remotePremium['expiryDate'] as DateTime?;
        final remotePurchaseToken = remotePremium['purchaseToken'] as String?;
        final remoteProductId = remotePremium['productId'] as String?;
        
        // 🔐 Firestore'daki premium durumunu kullan (kullanıcıya özgü)
        // Local premium durumu önceki kullanıcıdan kalma olabilir, güvenme!
        _isPremiumUser = remoteIsPremium;
        _premiumExpiryDate = remoteExpiry;
        _purchaseToken = remotePurchaseToken;
        _productId = remoteProductId;
        
        await _savePremiumStatus();
        debugPrint('✅ Premium durumu Firestore\'dan yüklendi: isPremium=$remoteIsPremium');
        
        notifyListeners();
      }
      
      debugPrint('✅ Premium Firestore sync tamamlandı');
    } catch (e) {
      debugPrint('❌ Premium Firestore sync hatası: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Premium durumunu Firestore'a kaydet
  Future<void> _syncPremiumToFirestore() async {
    if (!_syncService.isUserLoggedIn) return;
    
    // Arka planda sync et
    _syncService.syncPremiumStatus(
      isPremium: _isPremiumUser,
      expiryDate: _premiumExpiryDate,
      purchaseToken: _purchaseToken,
      productId: _productId,
    ).catchError((e) {
      debugPrint('❌ Premium sync hatası: $e');
    });
  }
  
  /// Manuel full sync (kullanıcı giriş yaptığında çağrılır)
  Future<void> performFullSync() async {
    // 🔒 Race condition önleme: Sync zaten devam ediyorsa bekle
    if (_isSyncing) {
      debugPrint('⚠️ Premium sync zaten devam ediyor, atlanıyor');
      return;
    }
    
    _isSyncing = true;
    debugPrint('🔄 Premium full sync başlatılıyor...');
    
    try {
      // 🔐 ÖNCELİKLE: Local premium durumunu sıfırla
      _isPremiumUser = false;
      _premiumExpiryDate = null;
      _purchaseToken = null;
      _productId = null;
      _justPurchased = false;
      
      // 📌 Offline kontrolü
      final hasInternet = await _hasInternetConnection();
      if (!hasInternet) {
        debugPrint('📴 Offline - cache kullanılıyor');
        await _syncFromFirestore(); // Cache'den yükle
        return;
      }
      
      // � GÜVENLİK: Önce Firestore'dan kontrol et, sonra restore yap
      // Böylece restore timeout olsa bile premium kullanıcılar engellenmez
      final firestoreData = await _getFirestorePremiumDataDirect();
      final bool firestorePremium = firestoreData?['isPremium'] ?? false;
      final DateTime? firestoreExpiry = firestoreData?['expiryDate'];
      
      debugPrint('📊 Öncelik kontrolü: Firestore premium=$firestorePremium, expiry=$firestoreExpiry');
      
      // Eğer Firestore'da premium varsa ve süresi dolmamışsa, öncelikle bunu kabul et
      if (firestorePremium && firestoreExpiry != null && firestoreExpiry.isAfter(DateTime.now())) {
        debugPrint('✅ Firestore\'da premium aktif tespit edildi - Google Play sorgusu atlanıyor');
        _isPremiumUser = true;
        _premiumExpiryDate = firestoreExpiry;
        _purchaseToken = firestoreData?['purchaseToken'];
        _productId = firestoreData?['productId'];
        
        // Local'e kaydet ve çık
        await _savePremiumStatus();
        debugPrint('✅ Premium full sync tamamlandı (isPremium: $_isPremiumUser)');
        return;
      }
      
      //  Local'e Firestore verisini yükle
      _isPremiumUser = firestorePremium;
      _premiumExpiryDate = firestoreExpiry;
      _purchaseToken = firestoreData?['purchaseToken'];
      _productId = firestoreData?['productId'];
      
      // 🔄 Google Play'den retry mekanizması ile restore yap
      final googlePlayPremium = await _restoreWithRetry(maxRetries: 5);
      
      // 🎯 ÖNCelik Sırası: Google Play > Firestore > Varsayılan
      if (googlePlayPremium) {
        // Google Play aktif = kesinlikle premium
        debugPrint('✅ Google Play aktif - premium onaylandı');
        _isPremiumUser = true;
        _premiumExpiryDate = _paymentService.premiumExpiryDate;
        _productId = _paymentService.activeSubscriptionId;
      } else if (firestorePremium && firestoreExpiry != null) {
        // Google Play aktif değil ama Firestore'da premium var
        if (firestoreExpiry.isAfter(DateTime.now())) {
          debugPrint('⚠️ Google Play timeout ama Firestore\'da premium aktif - durum korunuyor');
          // Firestore durumunu koru
          _isPremiumUser = true;
          // _premiumExpiryDate ve _purchaseToken zaten yüklendi
        } else {
          debugPrint('⚠️ Firestore\'da premium süresi dolmuş - premium iptal ediliyor');
          _isPremiumUser = false;
          _premiumExpiryDate = null;
          _purchaseToken = null;
          _productId = null;
          
          // Firestore'u güncelle
          await _syncPremiumToFirestore();
        }
      } else {
        // 🔔 YENİ KURAL: Google Play timeout olursa varsayılan olarak Firestore'a güven
        // Eğer Firestore'da premium varsa (expiry kontrolü yapıldı), koru
        if (firestorePremium) {
          debugPrint('⚠️ Google Play timeout ama Firestore\'da premium var - varsayılan olarak korunuyor');
          // Firestore durumunu koru (_premiumExpiryDate zaten yüklü)
          _isPremiumUser = true;
        } else {
          debugPrint('❌ Premium bulunamadı - kullanıcı premium değil');
          _isPremiumUser = false;
          _premiumExpiryDate = null;
          _purchaseToken = null;
          _productId = null;
        }
      }
      
      // 💾 Local'e kaydet
      await _savePremiumStatus();
      
      debugPrint('✅ Premium full sync tamamlandı (isPremium: $_isPremiumUser)');
      
    } catch (e) {
      debugPrint('❌ Premium full sync hatası: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Premium durumunu gerçek zamanlı dinle (opsiyonel)
  void startListeningToPremiumChanges() {
    if (!_syncService.isUserLoggedIn) return;
    
    _syncService.watchPremiumStatus().listen((status) {
      if (status != null) {
        final remoteIsPremium = status['isPremium'] as bool;
        final remoteExpiry = status['expiryDate'] as DateTime?;
        
        // Sadece değişiklik varsa güncelle
        if (remoteIsPremium != _isPremiumUser || 
            remoteExpiry != _premiumExpiryDate) {
          _isPremiumUser = remoteIsPremium;
          _premiumExpiryDate = remoteExpiry;
          _purchaseToken = status['purchaseToken'] as String?;
          _productId = status['productId'] as String?;
          
          _savePremiumStatus();
          notifyListeners();
          
          debugPrint('🔄 Premium durumu real-time güncellendi');
        }
      }
    });
  }
  
  // ================================
  // 💳 SATIN ALMA METODLARI
  // ================================
  
  /// Premium satın al
  Future<bool> purchasePremium(PremiumOfferType offerType) async {
    try {
      // PaymentService üzerinden satın alma başlat
      final success = await _paymentService.purchasePremium(offerType);
      
      if (success) {
        // Analytics
        AnalyticsService.instance.logEvent('premium_purchase_initiated', {
          'offer_type': offerType.toString(),
        }).catchError((e) => debugPrint('Analytics hatası: $e'));
      }
      
      return success;
    } catch (e) {
      debugPrint('❌ Premium satın alma hatası: $e');
      return false;
    }
  }
  
  /// 🔄 Manuel premium aktivasyonu (satın alma sonrası çağrılabilir)
  Future<void> activatePremiumNow() async {
    if (kDebugMode) debugPrint('🔄 Manuel premium aktivasyonu başlatılıyor...');
    
    // PaymentService'ten güncel durumu al
    _isPremiumUser = _paymentService.isPremiumActive;
    _premiumExpiryDate = _paymentService.premiumExpiryDate;
    _productId = _paymentService.activeSubscriptionId;
    
    // Eğer PaymentService'te premium aktifse
    if (_isPremiumUser) {
      await _savePremiumStatus();
      await _syncPremiumToFirestore();
      notifyListeners();
      if (kDebugMode) debugPrint('✅ Premium manuel olarak aktifleştirildi!');
    } else {
      if (kDebugMode) debugPrint('⚠️ PaymentService\'te premium aktif değil');
    }
  }
  
  /// Satın almaları geri yükle (Google Play'den çeker)
  Future<bool> restorePurchases() async {
    try {
      if (kDebugMode) debugPrint('🔄 Premium restore başlatılıyor...');
      
      // PaymentService'ten Google Play'den restore et
      await _paymentService.restoreAndSyncPurchases();
      
      // 🔐 KULLANICI BAZLI KONTROL: Sadece bu kullanıcı satın aldıysa premium yap
      final isPremiumForThisUser = _paymentService.isPremiumForCurrentUser();
      
      if (isPremiumForThisUser) {
        // Bu kullanıcı satın almış - premium yap
        _isPremiumUser = true;
        _premiumExpiryDate = _paymentService.premiumExpiryDate;
        _productId = _paymentService.activeSubscriptionId;
        
        await _savePremiumStatus();
        
        // 🔄 Firestore'a sync et
        await _syncPremiumToFirestore();
        
        if (kDebugMode) debugPrint('✅ Premium restore: Bu kullanıcı premium!');
      } else {
        // Bu kullanıcı satın almamış - premium yapma
        _isPremiumUser = false;
        _premiumExpiryDate = null;
        _productId = null;
        
        await _savePremiumStatus();
        
        if (kDebugMode) debugPrint('ℹ️ Premium restore: Bu kullanıcı premium değil');
      }
      
      notifyListeners();
      
      return _isPremiumUser;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Premium restore hatası: $e');
      return false;
    }
  }
  
  /// PaymentService'ten premium durumunu senkronize et
  Future<void> syncWithPaymentService() async {
    final wasPremium = _isPremiumUser;
    
    _isPremiumUser = _paymentService.isPremiumActive;
    _premiumExpiryDate = _paymentService.premiumExpiryDate;
    _productId = _paymentService.activeSubscriptionId;
    
    if (wasPremium != _isPremiumUser) {
      await _savePremiumStatus();
      await _syncPremiumToFirestore();
      notifyListeners();
      
      debugPrint('🔄 Premium durumu PaymentService ile senkronize edildi');
    }
  }
  
  // ================================
  // 🚪 OTURUM KAPATMA - VERİ TEMİZLEME
  // ================================
  
  /// Oturum kapatıldığında TÜM premium verilerini temizle
  /// Bu metod AuthProvider.signOut() sonrası çağrılmalı
  Future<void> clearAllDataOnLogout() async {
    if (kDebugMode) debugPrint('🚪 Oturum kapatılıyor - Premium verileri temizleniyor...');
    
    // 1. Memory'deki verileri temizle
    _isPremiumUser = false;
    _premiumExpiryDate = null;
    _purchaseToken = null;
    _productId = null;
    _justPurchased = false;
    
    // 2. Tetikleyici verilerini temizle
    _triggerCooldowns.clear();
    _dismissedTriggers.clear();
    _triggerShowCounts.clear();
    _currentActiveTrigger = null;
    
    // 3. Kullanıcı bağlamını temizle
    _userContext.clear();
    
    // 4. Analytics verilerini sıfırla
    _analyticsData = {
      'totalSessions': 0,
      'breathingSessionsCompleted': 0,
      'differentTechniquesUsed': 0,
      'savedMixesCount': 0,
      'dailyUsageDays': 0,
      'weeklyGoalCompletion': 0.0,
      'consecutiveWeeks': 0,
      'featuresUsed': 0,
      'measurementCount': 0,
      'lastUsageDate': null,
    };
    
    // 5. SharedPreferences'tan temizle
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Premium verileri
      await prefs.remove('is_premium_user');
      await prefs.remove('premium_expiry_date');
      await prefs.remove('purchase_token');
      await prefs.remove('product_id');
      
      // Tetikleyici verileri
      await prefs.remove('trigger_cooldowns');
      await prefs.remove('dismissed_triggers');
      await prefs.remove('trigger_show_counts');
      
      // Kullanıcı bağlamı ve analytics
      await prefs.remove('user_context');
      await prefs.remove('analytics_data');
      
      if (kDebugMode) debugPrint('✅ SharedPreferences premium verileri temizlendi');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ SharedPreferences temizleme hatası: $e');
    }
    
    // 6. PaymentService'teki verileri de temizle
    await _paymentService.clearPremiumStatus();
    
    // 7. UI'ı güncelle
    notifyListeners();
    
    if (kDebugMode) debugPrint('✅ Tüm premium verileri temizlendi - Yeni kullanıcı için hazır');
  }
  
  /// Sadece premium durumunu temizle (tetikleyici ve analytics verilerini koru)
  /// Test veya debug için kullanılabilir
  Future<void> clearPremiumStatusOnly() async {
    _isPremiumUser = false;
    _premiumExpiryDate = null;
    _purchaseToken = null;
    _productId = null;
    
    await _savePremiumStatus();
    await _paymentService.clearPremiumStatus();
    
    notifyListeners();
    
    if (kDebugMode) debugPrint('🧹 Premium durumu temizlendi');
  }
  
  /// 🔧 Debug: Premium durumunu kontrol et ve logla
  void debugPremiumStatus() {
    if (!kDebugMode) return;
    
    debugPrint('🔍 PREMIUM DURUMU DEBUG:');
    debugPrint('   PremiumProvider.isPremiumUser: $_isPremiumUser');
    debugPrint('   PremiumProvider.isPremiumExpired: ${_isPremiumExpired()}');
    debugPrint('   PremiumProvider.premiumExpiryDate: $_premiumExpiryDate');
    debugPrint('   PaymentService.isPremiumActive: ${_paymentService.isPremiumActive}');
    debugPrint('   PaymentService.premiumExpired: ${_paymentService.premiumExpired}');
    debugPrint('   PaymentService.isPremiumForCurrentUser: ${_paymentService.isPremiumForCurrentUser()}');
    debugPrint('   PaymentService.currentUserId: ${_paymentService.currentUserId}');
    debugPrint('   PaymentService.purchaseOwnerUserId: ${_paymentService.purchaseOwnerUserId}');
    debugPrint('   Sonuç: isPremiumUser getter = ${isPremiumUser}');
  }
} 