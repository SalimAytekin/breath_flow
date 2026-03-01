import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:breathe_flow/models/user.dart';
import 'package:breathe_flow/services/user_service.dart';
import 'package:breathe_flow/services/storage_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  // Auth state stream
  Stream<User?> get user => _auth.authStateChanges();

  // Sign up with email & password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        await _createUserInFirestore(result.user!);
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Sign up error: ${e.message}');
      rethrow; // Hata UI'a iletilsin
    } catch (e) {
      if (kDebugMode) print('Unexpected error during sign up: $e');
      rethrow;
    }
  }

  // Sign in with email & password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        await _userService.updateLastLogin(result.user!.uid);
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Sign in error: ${e.message}');
      rethrow; // Hata UI'a iletilsin
    } catch (e) {
      if (kDebugMode) print('Unexpected error during sign in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) print('Sign out error: $e');
      rethrow;
    }
  }

  // Şifre sıfırlama e-postası gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Password reset error: ${e.message}');
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Unexpected error during password reset: $e');
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
      if (kDebugMode) print('Email verification error: $e');
      rethrow;
    }
  }

  // Profil güncelle (displayName, photoURL)
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        Map<String, dynamic> updates = {};
        if (displayName != null) updates['displayName'] = displayName;
        if (photoURL != null) updates['photoURL'] = photoURL;
        
        if (updates.isNotEmpty) {
          await _userService.updateUser(user.uid, updates);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Profile update error: $e');
      rethrow;
    }
  }
  // Profil fotoğrafı yükle (File) - StorageService üzerinden
  Future<String?> uploadProfilePhoto(File imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }
      final downloadURL = await _storageService.uploadProfilePhoto(user.uid, imageFile);
      if (downloadURL != null && downloadURL.isNotEmpty) {
        await user.updatePhotoURL(downloadURL);
        await _userService.updateUser(user.uid, {'photoURL': downloadURL});
      }
      return downloadURL;
    } catch (e) {
      if (kDebugMode) print('Profile photo upload error: $e');
      rethrow;
    }
  }

  // Profil fotoğrafı yükle (Bytes - Web için) - StorageService üzerinden
  Future<String?> uploadProfilePhotoBytes(Uint8List imageBytes) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }
      final downloadURL = await _storageService.uploadProfilePhotoBytes(user.uid, imageBytes);
      if (downloadURL != null && downloadURL.isNotEmpty) {
        await user.updatePhotoURL(downloadURL);
        await _userService.updateUser(user.uid, {'photoURL': downloadURL});
      }
      return downloadURL;
    } catch (e) {
      if (kDebugMode) print('Profile photo upload error: $e');
      rethrow;
    }
  }

  // Profil fotoğrafını sil - StorageService üzerinden
  Future<bool> deleteProfilePhoto() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }
      final deleted = await _storageService.deleteProfilePhoto(user.uid);
      if (deleted) {
        await user.updatePhotoURL(null);
        await _userService.updateUser(user.uid, {'photoURL': null});
      }
      return deleted;
    } catch (e) {
      if (kDebugMode) print('Profile photo delete error: $e');
      return false;
    }
  }


  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Önce yeniden kimlik doğrulama yap
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Şifreyi güncelle
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Change password error: ${e.message}');
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Unexpected error during password change: $e');
      rethrow;
    }
  }

  // Hesabı sil
  Future<void> deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Önce yeniden kimlik doğrulama yap
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Firestore'dan sil
        await _userService.deleteUser(user.uid);
        
        // Firebase Auth'tan sil
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Delete account error: ${e.message}');
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Unexpected error during account deletion: $e');
      rethrow;
    }
  }

  // Firestore'da yeni kullanıcı oluştur
  Future<void> _createUserInFirestore(User firebaseUser) async {
    try {
      final newUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isPremium: false,
        totalMeditationMinutes: 0,
        streakDays: 0,
        favoriteBreathingExercises: [],
        favoriteSounds: [],
        completedJourneys: [],
        preferences: {
          'dailyGoal': 10,
          'reminderTime': '20:00',
        },
        notificationsEnabled: true,
        preferredTheme: 'system',
      );
      
      await _userService.createUser(newUser);
    } catch (e) {
      if (kDebugMode) print('Error creating user in Firestore: $e');
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
      if (kDebugMode) print('Error checking user existence: $e');
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
      if (kDebugMode) print('Error creating missing user record: $e');
    }
  }
}