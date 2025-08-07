import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:breathe_flow/models/user.dart';
import 'package:breathe_flow/services/user_service.dart';
import 'package:breathe_flow/services/storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  // Stream for auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Sign up with email & password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Firebase Auth başarılı olursa Firestore'da kullanıcı oluştur
      if (result.user != null) {
        await _createUserInFirestore(result.user!);
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      // Handle errors like 'email-already-in-use', 'weak-password' etc.
      print('Sign up error: ${e.message}');
      rethrow; // Hata UI'a iletilsin
    } catch (e) {
      print('Unexpected error during sign up: $e');
      rethrow;
    }
  }

  // Sign in with email & password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Giriş zamanını güncelle
      if (result.user != null) {
        await _userService.updateLastLogin(result.user!.uid);
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      // Handle errors like 'user-not-found', 'wrong-password' etc.
      print('Sign in error: ${e.message}');
      rethrow; // Hata UI'a iletilsin
    } catch (e) {
      print('Unexpected error during sign in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Şifre sıfırlama e-postası gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during password reset: $e');
      rethrow;
    }
  }

  // E-posta doğrulama gönder
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Email verification error: $e');
      rethrow;
    }
  }

  // Profil güncelle (displayName, photoURL)
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        
        // Firestore'da da güncelle
        Map<String, dynamic> updates = {};
        if (displayName != null) updates['displayName'] = displayName;
        if (photoURL != null) updates['photoURL'] = photoURL;
        
        if (updates.isNotEmpty) {
          await _userService.updateUser(user.uid, updates);
        }
      }
    } catch (e) {
      print('Profile update error: $e');
      rethrow;
    }
  }

  // Profil fotoğrafı yükle (File)
  Future<String?> uploadProfilePhoto(File imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // Storage'a yükle
      String? downloadURL = await _storageService.uploadProfilePhoto(user.uid, imageFile);
      
      if (downloadURL != null) {
        // Firebase Auth'ta güncelle
        await user.updatePhotoURL(downloadURL);
        
        // Firestore'da güncelle
        await _userService.updateUser(user.uid, {'photoURL': downloadURL});
      }
      
      return downloadURL;
    } catch (e) {
      print('Profile photo upload error: $e');
      rethrow;
    }
  }

  // Profil fotoğrafı yükle (Bytes - Web için)
  Future<String?> uploadProfilePhotoBytes(Uint8List imageBytes) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // Storage'a yükle
      String? downloadURL = await _storageService.uploadProfilePhotoBytes(user.uid, imageBytes);
      
      if (downloadURL != null) {
        // Firebase Auth'ta güncelle
        await user.updatePhotoURL(downloadURL);
        
        // Firestore'da güncelle
        await _userService.updateUser(user.uid, {'photoURL': downloadURL});
      }
      
      return downloadURL;
    } catch (e) {
      print('Profile photo upload error: $e');
      rethrow;
    }
  }

  // Profil fotoğrafını sil
  Future<bool> deleteProfilePhoto() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // Storage'dan sil
      bool deleted = await _storageService.deleteProfilePhoto(user.uid);
      
      if (deleted) {
        // Firebase Auth'ta güncelle
        await user.updatePhotoURL(null);
        
        // Firestore'da güncelle
        await _userService.updateUser(user.uid, {'photoURL': null});
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Profile photo delete error: $e');
      return false;
    }
  }

  // Şifre değiştir
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Önce mevcut şifre ile yeniden authenticate ol
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        
        await user.reauthenticateWithCredential(credential);
        
        // Şifreyi güncelle
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      print('Change password error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during password change: $e');
      rethrow;
    }
  }

  // Hesabı sil
  Future<void> deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Önce profil fotoğrafını sil
        await deleteProfilePhoto();
        
        // Yeniden authenticate ol
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        
        await user.reauthenticateWithCredential(credential);
        
        // Firestore'dan kullanıcı verilerini sil
        await _userService.deleteUser(user.uid);
        
        // Firebase Auth'tan sil
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      print('Delete account error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during account deletion: $e');
      rethrow;
    }
  }

  // Firestore'da yeni kullanıcı oluştur
  Future<void> _createUserInFirestore(User firebaseUser) async {
    try {
      DateTime now = DateTime.now();
      
      AppUser newUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        createdAt: now,
        lastLoginAt: now,
        isPremium: false,
        totalMeditationMinutes: 0,
        streakDays: 0,
        completedJourneys: [],
        favoriteBreathingExercises: [],
        favoriteSounds: [],
        preferences: {
          'breathingReminderTime': '09:00',
          'sleepReminderTime': '22:00',
          'weeklyGoalMinutes': 70, // Haftada 10 dakika x 7 gün
        },
        notificationsEnabled: true,
        preferredTheme: 'system',
      );
      
      await _userService.createUser(newUser);
    } catch (e) {
      print('Error creating user in Firestore: $e');
      // Firestore hatası Firebase Auth'u etkilemesin
      // Kullanıcı daha sonra profil tamamlayabilir
    }
  }

  // Kullanıcı Firestore'da var mı kontrol et
  Future<bool> userExistsInFirestore(String uid) async {
    try {
      AppUser? user = await _userService.getUser(uid);
      return user != null;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // Firestore'da eksik kullanıcı kaydı oluştur
  Future<void> createMissingUserRecord() async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        bool exists = await userExistsInFirestore(firebaseUser.uid);
        if (!exists) {
          await _createUserInFirestore(firebaseUser);
        }
      }
    } catch (e) {
      print('Error creating missing user record: $e');
    }
  }
} 