import 'package:breathe_flow/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:breathe_flow/services/auth_service.dart';
import 'package:breathe_flow/services/user_service.dart';
import 'dart:async';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  AppUser? _currentUser;
  StreamSubscription<AppUser?>? _userSubscription;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _initializeAuthState();
  }

  // Getters
  AppUser? get user => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPremium => _currentUser?.isActivePremium ?? false;

  // Sync callback'leri
  Function(String userId)? _onUserLoggedIn;
  Function()? _onUserLoggedOut;
  
  /// Kullanıcı giriş yaptığında çağrılacak callback'i ayarla
  /// Callback'e userId parametresi geçilir
  void setOnUserLoggedIn(Function(String userId) callback) {
    _onUserLoggedIn = callback;
  }
  
  /// Kullanıcı çıkış yaptığında çağrılacak callback'i ayarla
  void setOnUserLoggedOut(Function() callback) {
    _onUserLoggedOut = callback;
  }

  // Auth durumunu dinle
  void _initializeAuthState() {
    _authService.user.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        // Kullanıcı çıkış yaptı
        _currentUser = null;
        _userSubscription?.cancel();
        _userSubscription = null;
        
        // Çıkış callback'ini çağır
        _onUserLoggedOut?.call();
      } else {
        // Kullanıcı giriş yaptı, Firestore'dan dinle
        await _listenToUserData(firebaseUser.uid);
        
        // Giriş callback'ini çağır - userId'yi parametre olarak geç
        _onUserLoggedIn?.call(firebaseUser.uid);
      }
      notifyListeners();
    });
  }

  // Firestore'dan kullanıcı verilerini gerçek zamanlı dinle
  Future<void> _listenToUserData(String uid) async {
    try {
      // Önceki subscription'ı iptal et
      _userSubscription?.cancel();
      
      // Firestore'da kullanıcı var mı kontrol et
      bool userExists = await _authService.userExistsInFirestore(uid);
      if (!userExists) {
        // Eksik kullanıcı kaydı oluştur
        await _authService.createMissingUserRecord();
      }
      
      // Gerçek zamanlı dinlemeyi başlat
      _userSubscription = _userService.getUserStream(uid).listen(
        (AppUser? user) {
          _currentUser = user;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Kullanıcı verisi alınırken hata: $error';
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Kullanıcı verisi dinlenirken hata: $e';
      notifyListeners();
    }
  }

  // E-posta ve şifre ile kayıt ol
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      UserCredential? result = await _authService.signUpWithEmail(email, password);
      return result != null;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } on FirebaseException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
      return false;
    } catch (e) {
      // Firebase bazen farklı exception türleri fırlatıyor
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('email-already-in-use') || errorString.contains('already in use')) {
        _setError('Bu e-posta adresi zaten kullanılıyor.');
      } else if (errorString.contains('weak-password') || errorString.contains('weak password')) {
        _setError('Şifre çok zayıf. En az 6 karakter olmalıdır.');
      } else if (errorString.contains('invalid-email') || errorString.contains('invalid email')) {
        _setError('Geçersiz e-posta adresi.');
      } else if (errorString.contains('network')) {
        _setError('İnternet bağlantınızı kontrol edin.');
      } else {
        _setError('Kayıt oluşturulamadı. Lütfen bilgilerinizi kontrol edin.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // E-posta ve şifre ile giriş yap
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      UserCredential? result = await _authService.signInWithEmail(email, password);
      return result != null;
    } catch (e) {
      // Tüm hataları yakala ve uygun mesajı göster
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('invalid') || 
          errorString.contains('credential') || 
          errorString.contains('incorrect') ||
          errorString.contains('wrong-password') ||
          errorString.contains('malformed')) {
        _setError('E-posta veya şifre hatalı.');
      } else if (errorString.contains('user-not-found') || errorString.contains('no user')) {
        _setError('Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.');
      } else if (errorString.contains('too-many-requests')) {
        _setError('Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin.');
      } else if (errorString.contains('network')) {
        _setError('İnternet bağlantınızı kontrol edin.');
      } else if (errorString.contains('user-disabled')) {
        _setError('Bu hesap devre dışı bırakılmış.');
      } else {
        _setError('Giriş yapılamadı. Lütfen bilgilerinizi kontrol edin.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
    } catch (e) {
      _setError('Çıkış yapılırken hata: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Şifre sıfırlama e-postası gönder
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Beklenmeyen bir hata oluştu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // E-posta doğrulama gönder
  Future<bool> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      _setError('E-posta doğrulama gönderilirken hata: $e');
      return false;
    }
  }

  // Profil güncelle
  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    try {
      _setLoading(true);
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      return true;
    } catch (e) {
      _setError('Profil güncellenirken hata: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Şifre değiştir
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _setLoading(true);
      await _authService.changePassword(currentPassword, newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Şifre değiştirilirken hata: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Hesabı sil
  Future<bool> deleteAccount(String password) async {
    try {
      _setLoading(true);
      await _authService.deleteAccount(password);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e));
      return false;
    } catch (e) {
      _setError('Hesap silinirken hata: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı tercihlerini güncelle
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences) async {
    if (_currentUser == null) return false;
    
    try {
      await _userService.updateUserPreferences(_currentUser!.uid, preferences);
      return true;
    } catch (e) {
      _setError('Kullanıcı tercihleri güncellenirken hata: $e');
      return false;
    }
  }

  // Bildirim ayarını güncelle
  Future<bool> updateNotificationSettings(bool enabled) async {
    if (_currentUser == null) return false;
    
    try {
      await _userService.updateNotificationSettings(_currentUser!.uid, enabled);
      return true;
    } catch (e) {
      _setError('Bildirim ayarları güncellenirken hata: $e');
      return false;
    }
  }

  // Tema ayarını güncelle
  Future<bool> updateThemePreference(String theme) async {
    if (_currentUser == null) return false;
    
    try {
      await _userService.updateThemePreference(_currentUser!.uid, theme);
      return true;
    } catch (e) {
      _setError('Tema ayarı güncellenirken hata: $e');
      return false;
    }
  }

  // Meditasyon dakikalarını ekle
  Future<bool> addMeditationMinutes(int minutes) async {
    if (_currentUser == null) return false;
    
    try {
      await _userService.addMeditationMinutes(_currentUser!.uid, minutes);
      await _userService.updateStreakDays(_currentUser!.uid);
      return true;
    } catch (e) {
      _setError('Meditasyon istatistikleri güncellenirken hata: $e');
      return false;
    }
  }

  // Favori nefes egzersizi ekle/çıkar
  Future<bool> toggleFavoriteBreathingExercise(String exerciseId) async {
    if (_currentUser == null) return false;
    
    try {
      bool isFavorite = _currentUser!.favoriteBreathingExercises.contains(exerciseId);
      
      if (isFavorite) {
        await _userService.removeFavoriteBreathingExercise(_currentUser!.uid, exerciseId);
      } else {
        await _userService.addFavoriteBreathingExercise(_currentUser!.uid, exerciseId);
      }
      return true;
    } catch (e) {
      _setError('Favori nefes egzersizi güncellenirken hata: $e');
      return false;
    }
  }

  // Favori ses ekle/çıkar
  Future<bool> toggleFavoriteSound(String soundId) async {
    if (_currentUser == null) return false;
    
    try {
      bool isFavorite = _currentUser!.favoriteSounds.contains(soundId);
      
      if (isFavorite) {
        await _userService.removeFavoriteSound(_currentUser!.uid, soundId);
      } else {
        await _userService.addFavoriteSound(_currentUser!.uid, soundId);
      }
      return true;
    } catch (e) {
      _setError('Favori ses güncellenirken hata: $e');
      return false;
    }
  }

  // Tamamlanan journey ekle
  Future<bool> addCompletedJourney(String journeyId) async {
    if (_currentUser == null) return false;
    
    try {
      await _userService.addCompletedJourney(_currentUser!.uid, journeyId);
      return true;
    } catch (e) {
      _setError('Tamamlanan journey eklenirken hata: $e');
      return false;
    }
  }

  // Premium durumunu güncelle
  Future<bool> updatePremiumStatus(bool isPremium, [DateTime? expiryDate]) async {
    if (_currentUser == null) return false;
    
    try {
      await _userService.updatePremiumStatus(_currentUser!.uid, isPremium, expiryDate);
      return true;
    } catch (e) {
      _setError('Premium durumu güncellenirken hata: $e');
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Firebase Auth hata mesajlarını Türkçe'ye çevir
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalıdır.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda kullanılamıyor.';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'E-posta veya şifre hatalı.';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }

  // Firebase genel hata mesajlarını Türkçe'ye çevir
  String _getFirebaseErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'E-posta veya şifre hatalı.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 6 karakter olmalıdır.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin.';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
} 