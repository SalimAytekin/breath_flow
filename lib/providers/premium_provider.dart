import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/premium_trigger.dart';

class PremiumProvider extends ChangeNotifier {
  bool _isPremiumUser = false;
  DateTime? _premiumExpiryDate;
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
  bool get isPremiumUser => _isPremiumUser;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;
  Map<String, dynamic> get userContext => _userContext;
  PremiumTrigger? get currentActiveTrigger => _currentActiveTrigger;
  Map<String, dynamic> get analyticsData => _analyticsData;

  PremiumProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadPremiumStatus();
    await _loadUserContext();
    await _loadAnalyticsData();
    await _loadTriggerData();
    notifyListeners();
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremiumUser = prefs.getBool('is_premium_user') ?? false;
      
      final expiryString = prefs.getString('premium_expiry_date');
      if (expiryString != null) {
        _premiumExpiryDate = DateTime.parse(expiryString);
        
        // Süre dolmuşsa premium'u iptal et
        if (_premiumExpiryDate!.isBefore(DateTime.now())) {
          _isPremiumUser = false;
          await _savePremiumStatus();
        }
      }
    } catch (e) {
      debugPrint('Premium durumu yüklenirken hata: $e');
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
    if (_isPremiumUser) return; // Premium kullanıcılara gösterme

    // Kullanıcı bağlamını analytics ile birleştir
    final fullContext = Map<String, dynamic>.from(_userContext);
    fullContext.addAll(_analyticsData);

    for (final trigger in PremiumTrigger.predefinedTriggers) {
      // Cooldown kontrolü
      if (_triggerCooldowns.containsKey(trigger.id)) {
        final cooldownEnd = _triggerCooldowns[trigger.id]!;
        if (DateTime.now().isBefore(cooldownEnd)) continue;
      }

      // Dismissed kontrolü
      if (_dismissedTriggers.contains(trigger.id)) continue;

      // Show count kontrolü (aynı tetikleyiciyi çok gösterme)
      final showCount = _triggerShowCounts[trigger.id] ?? 0;
      if (showCount >= 3) continue;

      // Koşulları kontrol et
      if (trigger.checkConditions(fullContext)) {
        _currentActiveTrigger = trigger;
        _triggerShowCounts[trigger.id] = showCount + 1;
        await _saveTriggerData();
        notifyListeners();
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
      default:
        _premiumExpiryDate = DateTime.now().add(const Duration(days: 30));
        break;
    }
    
    await _savePremiumStatus();
    
    // Aktif tetikleyiciyi temizle
    _currentActiveTrigger = null;
    
    notifyListeners();
  }

  // Premium özellik erişim kontrolü
  bool canAccessFeature(String featureId) {
    if (_isPremiumUser) return true;
    
    // Ücretsiz özellikler listesi
    const freeFeatures = [
      'basic_breathing',
      'basic_sounds',
      'basic_sleep',
      'basic_journal',
      'basic_hrv',
      'free_stories',
    ];
    
    return freeFeatures.contains(featureId);
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