import 'dart:async';
import 'dart:io';
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
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) print('❌ Bulunamayan ürünler: ${response.notFoundIDs}');
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

  /// Mevcut satın almaları geri yükle
  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      if (kDebugMode) print('✅ Satın almalar geri yüklendi');
    } catch (e) {
      if (kDebugMode) print('❌ Satın alma geri yükleme hatası: $e');
    }
  }

  /// Satın alma güncellemelerini dinle
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
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
        
        // Satın alma başarılı
        await _processSuccessfulPurchase(purchaseDetails);
        
        // Satın alma işlemini tamamla
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        
        _purchasePending = false;
        if (kDebugMode) print('✅ Satın alma başarılı: ${purchaseDetails.productID}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Satın alma işleme hatası: $e');
      _purchasePending = false;
    }
  }

  /// Başarılı satın almayı işle
  Future<void> _processSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    
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
    
    if (kDebugMode) print('🎉 Premium aktifleştirildi: $productId');
  }

  /// Premium durumunu kaydet
  Future<void> _savePremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium_active', _isPremiumActive);
    await prefs.setString('active_subscription_id', _activeSubscriptionId ?? '');
    
    if (_premiumExpiryDate != null) {
      await prefs.setString('premium_expiry_date', _premiumExpiryDate!.toIso8601String());
    }
  }

  /// Premium durumunu yükle
  Future<void> loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremiumActive = prefs.getBool('is_premium_active') ?? false;
      _activeSubscriptionId = prefs.getString('active_subscription_id');
      
      final expiryString = prefs.getString('premium_expiry_date');
      if (expiryString != null) {
        _premiumExpiryDate = DateTime.parse(expiryString);
        
        // Süre dolmuş mu kontrol et
        if (_premiumExpiryDate!.isBefore(DateTime.now())) {
          _isPremiumActive = false;
          _activeSubscriptionId = null;
          _premiumExpiryDate = null;
          await _savePremiumStatus();
        }
      }
      
      if (kDebugMode) print('📱 Premium durumu yüklendi: $_isPremiumActive');
    } catch (e) {
      if (kDebugMode) print('❌ Premium durumu yükleme hatası: $e');
    }
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

    // Ürünü bul
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => _products.first, // Fallback
    );

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

  /// Premium durumunu temizle (test için)
  Future<void> clearPremiumStatus() async {
    _isPremiumActive = false;
    _activeSubscriptionId = null;
    _premiumExpiryDate = null;
    await _savePremiumStatus();
    if (kDebugMode) print('🧹 Premium durumu temizlendi');
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
