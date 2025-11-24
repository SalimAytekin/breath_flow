import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import '../models/premium_trigger.dart';

class PremiumProvider extends ChangeNotifier {
  // Ana premium durumu
  bool _isPremiumUser = false;
  DateTime? _premiumExpiryDate;
  
  // Test modu kontrolü
  bool _testMode = true; // Premium sistemi askıya alındı - herkes ücretsiz erişim
  
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
      // Debug log kaldırıldı - çok fazla spam yapıyordu
      return _isPremiumUser;
    }
    // Production modunda gerçek premium durumunu kontrol et
    return _isPremiumUser && !_isPremiumExpired();
  }
  
  bool get isTestMode => _testMode;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;
  Map<String, dynamic> get userContext => _userContext;
  PremiumTrigger? get currentActiveTrigger => _currentActiveTrigger;
  Map<String, dynamic> get analyticsData => _analyticsData;
  
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
  }

  Future<void> _initializeData() async {
    await _loadPremiumStatus();
    await _loadUserContext();
    await _loadAnalyticsData();
    await _loadTriggerData();
    // Çevrimiçi senkronizasyon (claim/Firestore) — sessiz çalışır
    await synchronizePremiumStatus();
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
        if (kDebugMode) print('🚨 TEST: Premium durumu sıfırlandı (Test modu aktif)');
      } else {
        // Production modunda gerçek premium durumunu yükle
        _isPremiumUser = prefs.getBool('is_premium_user') ?? false;
        
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
      }
    } catch (e) {
      debugPrint('Premium durumu kaydedilirken hata: $e');
    }
  }

  // Firebase Auth custom claim'lerinden premium durumunu yenile
  Future<void> refreshFromAuthClaims() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final tokenResult = await user.getIdTokenResult(true); // force refresh
      final claims = tokenResult.claims ?? {};

      final bool claimPremium = (claims['isPremium'] == true);
      DateTime? claimExpiry;
      if (claims['premium_exp'] is int) {
        // Saniye timestamp bekleniyor
        claimExpiry = DateTime.fromMillisecondsSinceEpoch((claims['premium_exp'] as int) * 1000);
      } else if (claims['premium_exp'] is String) {
        claimExpiry = DateTime.tryParse(claims['premium_exp']);
      }

      if (claimPremium != _isPremiumUser || (claimExpiry ?? _premiumExpiryDate) != _premiumExpiryDate) {
        _isPremiumUser = claimPremium;
        _premiumExpiryDate = claimExpiry;
        await _savePremiumStatus();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Auth claim yenileme hatası: $e');
    }
  }

  // Firestore yedeği: users/{uid} dokümanından premium bilgisi oku
  Future<void> refreshFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) return;
      final data = doc.data();
      if (data == null) return;

      final bool fsPremium = (data['isPremium'] == true);
      DateTime? fsExpiry;
      if (data['premiumExpiry'] is Timestamp) {
        fsExpiry = (data['premiumExpiry'] as Timestamp).toDate();
      } else if (data['premiumExpiry'] is String) {
        fsExpiry = DateTime.tryParse(data['premiumExpiry']);
      }

      if (fsPremium != _isPremiumUser || (fsExpiry ?? _premiumExpiryDate) != _premiumExpiryDate) {
        _isPremiumUser = fsPremium;
        _premiumExpiryDate = fsExpiry;
        await _savePremiumStatus();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Firestore premium yenileme hatası: $e');
    }
  }

  // Tek giriş noktası: önce Auth claims, sonra Firestore fallback
  Future<void> synchronizePremiumStatus() async {
    await refreshFromAuthClaims();
    // Claims gelmediyse veya premium değilse Firestore ile doğrula
    if (!_isPremiumUser || _premiumExpiryDate == null) {
      await refreshFromFirestore();
    }
  }

  // Token geçerliliğini garanti altına al (expire edge-case)
  Future<void> ensureValidToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await user.getIdToken(true);
    } catch (e) {
      debugPrint('Token yenileme hatası: $e');
    }
  }

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
  Future<void> setPremiumStatus(bool isPremium, {DateTime? expiryDate}) async {
    _isPremiumUser = isPremium;
    _premiumExpiryDate = expiryDate;
    await _savePremiumStatus();
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

  // Premium satın alma simülasyonu
  Future<void> purchasePremium(PremiumOfferType offerType) async {
    _isPremiumUser = true;
    
    // Offer tipine göre süre belirle
    switch (offerType) {
      case PremiumOfferType.trialOffer:
        _premiumExpiryDate = DateTime.now().add(const Duration(days: 7));
        break;
      case PremiumOfferType.bundleOffer:
        _premiumExpiryDate = DateTime.now().add(const Duration(days: 365));
        break;
      case PremiumOfferType.discountOffer:
        _premiumExpiryDate = DateTime.now().add(const Duration(days: 30));
        break;
      default:
        _premiumExpiryDate = DateTime.now().add(const Duration(days: 30));
        break;
    }
    
    await _savePremiumStatus();
    
    // Aktif tetikleyiciyi temizle
    _currentActiveTrigger = null;
    
    // Premium satın alma analitiği
    await trackUserAction('premium_purchased', {
      'offerType': offerType.name,
      'expiryDate': _premiumExpiryDate?.toIso8601String(),
    });
    
    if (kDebugMode) print('🎉 Premium satın alındı: ${offerType.name}');
    notifyListeners();
  }
  
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

  // Merkezi premium özellik erişim kontrolü
  bool canAccessFeature(String featureId) {
    // Test modunda reklam özelliği için özel kontrol
    if (_testMode && featureId == 'ad_free') {
      // Debug log kaldırıldı - çok fazla spam yapıyordu
      return false; // Test modunda da reklamları göster
    }
    
    // Premium sistemi askıya alındı - diğer özellikler için herkes erişebilir
    if (_testMode) {
      if (kDebugMode) print('🚨 DEBUG: Premium sistemi askıya alındı - ${featureId} özelliğine erişim verildi');
      return true;
    }
    
    // Premium kullanıcılar tüm özelliklere erişebilir
    if (isPremiumUser) return true;
    
    // Ücretsiz özellikler listesi
    const freeFeatures = [
      'basic_breathing',
      'basic_sounds',
      'basic_sleep',
      'basic_journal',
      'basic_hrv',
      'free_stories',
      'sound_mixing', // Mix limiti var ama erişilebilir
      'ad_free', // Premium kullanıcılar için reklamsız deneyim
    ];
    
    return freeFeatures.contains(featureId);
  }
  
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
} 