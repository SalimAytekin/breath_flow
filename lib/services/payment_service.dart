import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/premium_trigger.dart';

/// Gerçek ödeme sistemi servisi
/// Google Play Billing ve App Store Connect entegrasyonu
class PaymentService {
  static PaymentService? _instance;
  static PaymentService get instance => _instance ??= PaymentService._();
  PaymentService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  // Premium ürün ID'leri
  static const String _premiumMonthlyId = 'premium_monthly';
  static const String _premiumYearlyId = 'premium_yearly';
  static const String _premiumTrialId = 'premium_trial';
  
  // Ürün bilgileri
  Set<String> _productIds = {
    _premiumMonthlyId,
    _premiumYearlyId,
    _premiumTrialId,
  };
  
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  String? _queryProductError;

  // Premium durumu
  bool _isPremiumActive = false;
  DateTime? _premiumExpiryDate;
  String? _activeSubscriptionId;
  String? _purchaseOwnerUserId; // 🔐 Satın almayı yapan kullanıcı ID'si
  
  // 🔔 Premium süresi doldu flag'i
  bool _premiumExpired = false;
  bool get premiumExpired => _premiumExpired;
  
  // Restore için Completer
  Completer<bool>? _restoreCompleter;
  
  // 🔔 Satın alma başarılı callback'i - PremiumProvider bu callback'i dinleyecek
  Function(PurchaseDetails)? onPurchaseSuccess;
  
  // 🔔 Premium süresi doldu callback'i
  Function()? onPremiumExpired;
  
  // 🔐 Mevcut kullanıcı ID'si (AuthProvider'dan set edilecek)
  String? _currentUserId;
  
  /// Mevcut kullanıcı ID'sini ayarla
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
    if (kDebugMode) print('🔐 PaymentService kullanıcı ID: $userId');
  }
  
  /// Satın almayı yapan kullanıcı ID'si
  String? get purchaseOwnerUserId => _purchaseOwnerUserId;
  
  /// Mevcut kullanıcı ID'si
  String? get currentUserId => _currentUserId;

  // Getters
  bool get isPremiumActive => _isPremiumActive;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;
  String? get activeSubscriptionId => _activeSubscriptionId;
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  List<ProductDetails> get products => _products;
  String? get queryProductError => _queryProductError;

  /// Ödeme sistemini başlat
  Future<void> initialize() async {
    try {
      // Platform desteği kontrolü
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        if (kDebugMode) print('❌ In-App Purchase mevcut değil');
        return;
      }

      // Satın alma durumu dinleyicisi
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdated,
        onDone: () => _subscription.cancel(),
        onError: (error) {
          if (kDebugMode) print('❌ Purchase stream error: $error');
        },
      );

      // Ürünleri sorgula
      await _queryProducts();
      
      // Mevcut satın almaları kontrol et
      await _restorePurchases();
      
      if (kDebugMode) print('✅ Payment Service başarıyla başlatıldı');
    } catch (e) {
      if (kDebugMode) print('❌ Payment Service başlatma hatası: $e');
    }
  }

  /// Ürünleri sorgula
  Future<void> _queryProducts() async {
    try {
      if (kDebugMode) print('🔍 Ürün sorgusu başlatılıyor: $_productIds');
      
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      
      if (kDebugMode) {
        print('📋 Sorgu sonucu:');
        print('   - Bulunan: ${response.productDetails.length}');
        print('   - Bulunamayan: ${response.notFoundIDs}');
      }
      
      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) print('⚠️ Bulunamayan ürünler: ${response.notFoundIDs}');
      }
      
      if (response.error != null) {
        _queryProductError = response.error!.message;
        if (kDebugMode) print('❌ Ürün sorgulama hatası: ${response.error}');
        return;
      }
      
      _products = response.productDetails;
      if (kDebugMode) {
        print('✅ ${_products.length} ürün bulundu');
        
        // Ürün bilgilerini yazdır
        for (final product in _products) {
          print('📦 ${product.id}: ${product.title} - ${product.price}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Ürün sorgulama hatası: $e');
    }
  }

  /// Mevcut satın almaları geri yükle (private)
  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      if (kDebugMode) print('✅ Satın almalar geri yüklendi');
    } catch (e) {
      if (kDebugMode) print('❌ Satın alma geri yükleme hatası: $e');
    }
  }
  
  /// 🔐 Retry mekanizması ile restore
  /// Returns:
  /// - true: Aktif abonelik bulundu
  /// - false: Başarıyla kontrol edildi, abonelik YOK
  /// - null: Hata/Timeout (Kontrol edilemedi)
  Future<bool?> restoreWithRetry({int maxRetries = 3}) async {
    for (int i = 0; i < maxRetries; i++) {
            try {
        _restoreCompleter = Completer<bool>();
        await _restorePurchases();
        
        // ⏱️ Timeout süresini kısalttık: 3 + i*2 saniye (toplam ~10-15sn beklesin yeter)
        // Çünkü purchase yoksa stream hiç tetiklenmez ve boşuna bekleriz.
        final result = await _restoreCompleter!.future.timeout(
          Duration(seconds: 3 + i * 2), 
        );
        
        _restoreCompleter = null;
        if (kDebugMode) print('✅ Restore başarılı (deneme ${i + 1})');
        return result;
      } catch (e) {
        _restoreCompleter = null;
        if (i == maxRetries - 1) {
          if (kDebugMode) print('❌ Restore denemeleri başarısız: $e');
          return null; // 🚨 NULL = Hata/Timeout
        }
        if (kDebugMode) print('⚠️ Restore deneme ${i + 1} timeout, tekrar deneniyor...');
        await Future.delayed(const Duration(seconds: 3)); // Bekleme süresini artır
      }
    }
    return null;
  }
  
  /// 🔄 Public: Satın almaları geri yükle ve premium durumunu senkronize et
  Future<bool> restoreAndSyncPurchases() async {
    try {
      if (kDebugMode) print('🔄 Satın almalar geri yükleniyor...');
      
      // Premium expired flag'ini sıfırla
      _premiumExpired = false;
      
      // Önce local durumu yükle
      await loadPremiumStatus();
      
      // 📌 Önceki premium durumunu kaydet (karşılaştırma için)
      final bool wasPremiumBefore = _isPremiumActive;
      final String? previousOwnerId = _purchaseOwnerUserId;
      
      if (kDebugMode) {
        print('📊 Önceki durum: isPremium=$wasPremiumBefore, owner=$previousOwnerId');
      }
      
      // 🔄 HER ZAMAN Google Play'i sorgula (local cache'e güvenme!)
      // Retry mekanizması ile restore yap
      // Sonuç: true (var), false (yok), null (hata)
      bool? restoreResult = await restoreWithRetry(maxRetries: 3);
      
      // 🔔 MANTIK: 
      // 1. result == true  -> Premium AKTİF (Bulundu)
      // 2. result == false -> Premium İPTAL (Bulunamadı - Kesin bilgi)
      // 3. result == null  -> Premium KORU (Hata/Timeout - İnternet yok vs.)
      
      if (restoreResult == true) {
         // Zaten _handlePurchase içinde aktif edildi
         if (kDebugMode) print('✅ Premium doğrulandı');
      } 
      else if (restoreResult == false) {
        // ❌ KESİN BİLGİ: Abonelik yok
        if (kDebugMode) print('⚠️ Aktif abonelik bulunamadı - Premium iptal ediliyor');
        
        // Premium'u kapat
        _isPremiumActive = false;
        _activeSubscriptionId = null;
        _premiumExpiryDate = null;
        await _savePremiumStatus();
        
        // Expired flag'i set et - Sadece önceden premium ise
        if (wasPremiumBefore && previousOwnerId == _currentUserId) {
          _premiumExpired = true;
          if (kDebugMode) print('🔔 Premium süresi doldu - kullanıcıya bildirilecek');
          onPremiumExpired?.call();
        }
      }
      else {
        // ⚠️ HATA / TIMEOUT DURUMU (restoreResult == null)
        // Kullanıcı isteği üzerine: İnternet hatası varsa premium devam etsin
        if (wasPremiumBefore && previousOwnerId == _currentUserId) {
           if (kDebugMode) print('🚨 Bağlantı/Timeout hatası - Premium durumu GEÇİCİ OLARAK KORUNUYOR');
           // Premium'u iptal etmiyoruz!
           // _isPremiumActive hala true (loadPremiumStatus'dan geldi)
           return true; 
        }
      }
      
      // Durumu tekrar yükle (değişiklikleri al)
      await loadPremiumStatus();
      
      if (kDebugMode) {
        print('📊 Güncel durum: isPremium=$_isPremiumActive, subscription=$_activeSubscriptionId');
      }
      
      return _isPremiumActive;
    } catch (e) {
      if (kDebugMode) print('❌ Restore & sync hatası: $e');
      return false;
    }
  }
  
  /// Premium expired flag'ini sıfırla
  void clearPremiumExpiredFlag() {
    _premiumExpired = false;
  }

  /// Satın alma güncellemelerini dinle
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    // 🔔 KRİTİK DÜZELTME: Liste boşsa "Abonelik Yok" demektir!
    if (purchaseDetailsList.isEmpty) {
      if (kDebugMode) print('ℹ️ Restore listesi boş geldi - Abonelik yok');
      if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
        _restoreCompleter!.complete(false); // FALSE = Bulunamadı
      }
      return;
    }

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Satın alma işlemini yönet
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
        if (kDebugMode) print('⏳ Satın alma bekleniyor: ${purchaseDetails.productID}');
        return;
      }

      if (purchaseDetails.status == PurchaseStatus.error) {
        _purchasePending = false;
        if (kDebugMode) print('❌ Satın alma hatası: ${purchaseDetails.error}');
        return;
      }

      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        
        final isRestore = purchaseDetails.status == PurchaseStatus.restored;
        
        if (isRestore) {
          // 🔐 RESTORE durumunda: Sahiplik kontrolü yap
          if (kDebugMode) {
            print('🔄 Restore algılandı: ${purchaseDetails.productID}');
            print('   Mevcut sahip: $_purchaseOwnerUserId');
            print('   Mevcut kullanıcı: $_currentUserId');
          }
          
          // 🚫 Kullanıcı giriş yapmamışsa restore işlemi YAPMA
          // Böylece sahipsiz premium oluşmaz
          if (_currentUserId == null) {
            if (kDebugMode) print('⚠️ Restore: Kullanıcı giriş yapmamış - işlem atlanıyor');
            // Sadece satın alma işlemini tamamla ama premium aktifleştirme
            if (purchaseDetails.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(purchaseDetails);
            }
            return;
          }
          
          // Eğer zaten bir sahip varsa ve mevcut kullanıcı değilse, sahipliği DEĞİŞTİRME
          if (_purchaseOwnerUserId != null && _purchaseOwnerUserId != _currentUserId) {
            if (kDebugMode) print('⚠️ Restore: Farklı kullanıcı - sahiplik değiştirilmedi');
            // Premium durumunu güncelle ama sahipliği değiştirme
            _isPremiumActive = true;
            _activeSubscriptionId = purchaseDetails.productID;
            await _savePremiumStatus();
          } else {
            // Sahip yok veya mevcut kullanıcı sahip - normal işle
            await _processSuccessfulPurchase(purchaseDetails);
          }
        } else {
          // YENİ SATIN ALMA: Normal işle
          await _processSuccessfulPurchase(purchaseDetails);
        }
        
        // Satın alma işlemini tamamla
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        
        _purchasePending = false;
        if (kDebugMode) print('✅ Satın alma başarılı: ${purchaseDetails.productID}');
        
        // 🔔 Callback'i çağır - PremiumProvider anında bilgilendirilecek
        if (onPurchaseSuccess != null) {
          onPurchaseSuccess!(purchaseDetails);
        }
        
        // 🔄 Restore Completer'ı tamamla
        if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
          _restoreCompleter!.complete(true);
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Satın alma işleme hatası: $e');
      _purchasePending = false;
    }
  }

  /// Başarılı satın almayı işle
  Future<void> _processSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    
    // 🔐 Satın almayı yapan kullanıcıyı kaydet
    _purchaseOwnerUserId = _currentUserId;
    
    // Premium durumunu güncelle
    _isPremiumActive = true;
    _activeSubscriptionId = productId;
    
    // Süre hesapla
    switch (productId) {
      case _premiumMonthlyId:
        _premiumExpiryDate = DateTime.now().add(const Duration(days: 30));
        break;
      case _premiumYearlyId:
        _premiumExpiryDate = DateTime.now().add(const Duration(days: 365));
        break;
      case _premiumTrialId:
        _premiumExpiryDate = DateTime.now().add(const Duration(days: 7));
        break;
    }
    
    // Durumu kaydet
    await _savePremiumStatus();
    
    if (kDebugMode) print('🎉 Premium aktifleştirildi: $productId (Kullanıcı: $_purchaseOwnerUserId)');
  }

  /// Premium durumunu kaydet
  Future<void> _savePremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium_active', _isPremiumActive);
    await prefs.setString('active_subscription_id', _activeSubscriptionId ?? '');
    
    if (_premiumExpiryDate != null) {
      await prefs.setString('premium_expiry_date', _premiumExpiryDate!.toIso8601String());
    }
    
    // 🔐 Satın almayı yapan kullanıcı ID'sini kaydet
    if (_purchaseOwnerUserId != null) {
      await prefs.setString('purchase_owner_user_id', _purchaseOwnerUserId!);
    }
  }

  /// Premium durumunu yükle
  Future<void> loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremiumActive = prefs.getBool('is_premium_active') ?? false;
      _activeSubscriptionId = prefs.getString('active_subscription_id');
      _purchaseOwnerUserId = prefs.getString('purchase_owner_user_id');
      
      final expiryString = prefs.getString('premium_expiry_date');
      if (expiryString != null) {
        _premiumExpiryDate = DateTime.parse(expiryString);
        
        // Süre dolmuş mu kontrol et
        if (_premiumExpiryDate!.isBefore(DateTime.now())) {
          _isPremiumActive = false;
          _activeSubscriptionId = null;
          _premiumExpiryDate = null;
          _purchaseOwnerUserId = null;
          await _savePremiumStatus();
        }
      }
      
      if (kDebugMode) {
        print('📱 Premium durumu yüklendi:');
        print('   _isPremiumActive: $_isPremiumActive');
        print('   _purchaseOwnerUserId: $_purchaseOwnerUserId');
        print('   _currentUserId: $_currentUserId');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Premium durumu yükleme hatası: $e');
    }
  }
  
  /// 🔐 Mevcut kullanıcı satın almanın sahibi mi?
  bool isCurrentUserPurchaseOwner() {
    // Kullanıcı giriş yapmamışsa veya satın alma yoksa false
    if (_currentUserId == null || _purchaseOwnerUserId == null) {
      return false;
    }
    return _currentUserId == _purchaseOwnerUserId;
  }
  
  /// 🔐 Kullanıcı bazlı premium durumu
  /// Bu metod sadece mevcut kullanıcı satın alma sahibiyse true döner
  bool isPremiumForCurrentUser() {
    if (kDebugMode) {
      print('🔐 isPremiumForCurrentUser kontrolü:');
      print('   _isPremiumActive: $_isPremiumActive');
      print('   _currentUserId: $_currentUserId');
      print('   _purchaseOwnerUserId: $_purchaseOwnerUserId');
    }
    
    // Premium aktif değilse false
    if (!_isPremiumActive) {
      if (kDebugMode) print('   ❌ Sonuç: Premium aktif değil');
      return false;
    }
    
    // Kullanıcı giriş yapmamışsa → premium geçersiz
    if (_currentUserId == null) {
      if (kDebugMode) print('   ❌ Sonuç: Kullanıcı giriş yapmamış');
      return false;
    }
    
    // Satın alma sahibi yoksa → bu yeni bir satın alma, mevcut kullanıcı sahip olacak
    if (_purchaseOwnerUserId == null) {
      if (kDebugMode) print('   ⚠️ Satın alma sahibi yok - mevcut kullanıcı sahip olacak');
      // Mevcut kullanıcıyı sahip olarak kaydet
      _purchaseOwnerUserId = _currentUserId;
      _savePremiumStatus();
      if (kDebugMode) print('   ✅ Sonuç: Yeni sahip atandı');
      return true;
    }
    
    // Sadece satın alan kullanıcı premium olabilir
    final isOwner = _currentUserId == _purchaseOwnerUserId;
    if (kDebugMode) print('   ${isOwner ? "✅" : "❌"} Sonuç: Sahip kontrolü = $isOwner');
    return isOwner;
  }

  /// Premium satın al
  Future<bool> purchasePremium(PremiumOfferType offerType) async {
    if (!_isAvailable || _products.isEmpty) {
      if (kDebugMode) print('❌ Satın alma mevcut değil');
      return false;
    }

    String productId;
    switch (offerType) {
      case PremiumOfferType.trialOffer:
        productId = _premiumTrialId;
        break;
      case PremiumOfferType.bundleOffer:
        productId = _premiumYearlyId;
        break;
      default:
        productId = _premiumMonthlyId;
        break;
    }
    
    if (kDebugMode) {
      print('🛒 Satın alma isteği: offerType=$offerType, productId=$productId');
      print('📦 Mevcut ürünler: ${_products.map((p) => '${p.id}: ${p.price}').toList()}');
    }

    // Ürünü bul
    ProductDetails? product;
    try {
      product = _products.firstWhere((p) => p.id == productId);
      if (kDebugMode) print('✅ Ürün bulundu: ${product.id} - ${product.price}');
    } catch (e) {
      if (kDebugMode) print('⚠️ Ürün bulunamadı: $productId, fallback kullanılacak');
      if (_products.isNotEmpty) {
        product = _products.first; // Fallback
        if (kDebugMode) print('⚠️ Fallback ürün: ${product.id} - ${product.price}');
      } else {
        if (kDebugMode) print('❌ Hiç ürün yok!');
        return false;
      }
    }

    try {
      _purchasePending = true;
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null, // Kullanıcı adı (opsiyonel)
      );

      final bool success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      if (!success) {
        _purchasePending = false;
        if (kDebugMode) print('❌ Satın alma başlatılamadı');
        return false;
      }

      if (kDebugMode) print('🛒 Satın alma başlatıldı: ${product.title}');
      return true;
    } catch (e) {
      _purchasePending = false;
      if (kDebugMode) print('❌ Satın alma hatası: $e');
      return false;
    }
  }

  /// Premium özellik erişim kontrolü
  bool canAccessFeature(String featureId) {
    if (_isPremiumActive) return true;
    
    // Ücretsiz özellikler
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

  /// Premium durumunu kontrol et
  bool isPremiumExpired() {
    if (!_isPremiumActive || _premiumExpiryDate == null) return true;
    return _premiumExpiryDate!.isBefore(DateTime.now());
  }

  /// Kalan gün sayısını al
  int getRemainingDays() {
    if (!_isPremiumActive || _premiumExpiryDate == null) return 0;
    
    final now = DateTime.now();
    final difference = _premiumExpiryDate!.difference(now);
    return difference.inDays;
  }

  /// Premium durumunu temizle (çıkış yapıldığında)
  /// NOT: Sahip bilgisi korunur - böylece aynı kullanıcı tekrar giriş yaptığında premium durumu geri gelir
  Future<void> clearPremiumStatus() async {
    // Sadece aktif durumu sıfırla, sahip bilgisini KORU
    _isPremiumActive = false;
    _activeSubscriptionId = null;
    _premiumExpiryDate = null;
    // _purchaseOwnerUserId KORUNUYOR - bu kritik!
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium_active', false);
    await prefs.remove('active_subscription_id');
    await prefs.remove('premium_expiry_date');
    // purchase_owner_user_id KORUNUYOR
    
    if (kDebugMode) {
      print('🧹 Premium durumu temizlendi');
      print('   Sahip bilgisi korundu: $_purchaseOwnerUserId');
    }
  }

  /// Servisi kapat
  void dispose() {
    _subscription.cancel();
  }
}

/// Premium durumu provider'ı
class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService.instance;
  
  bool get isPremiumActive => _paymentService.isPremiumActive;
  DateTime? get premiumExpiryDate => _paymentService.premiumExpiryDate;
  String? get activeSubscriptionId => _paymentService.activeSubscriptionId;
  bool get isAvailable => _paymentService.isAvailable;
  bool get purchasePending => _paymentService.purchasePending;
  List<ProductDetails> get products => _paymentService.products;
  String? get queryProductError => _paymentService.queryProductError;

  PaymentProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _paymentService.initialize();
    await _paymentService.loadPremiumStatus();
    notifyListeners();
  }

  Future<bool> purchasePremium(PremiumOfferType offerType) async {
    final success = await _paymentService.purchasePremium(offerType);
    notifyListeners();
    return success;
  }

  bool canAccessFeature(String featureId) {
    return _paymentService.canAccessFeature(featureId);
  }

  int getRemainingDays() {
    return _paymentService.getRemainingDays();
  }

  Future<void> restorePurchases() async {
    await _paymentService._restorePurchases();
    notifyListeners();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }
}
