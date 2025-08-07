import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static const String _profilePhotosPath = 'profile_photos';
  static const String _contentPath = 'content';
  static const String _soundsPath = 'sounds';
  static const String _imagesPath = 'images';
  static const String _storiesPath = 'stories';
  static const String _breathingExercisesPath = 'breathing_exercises';
  
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Storage referansları
  Reference get _profilePhotosRef => _storage.ref().child(_profilePhotosPath);
  Reference get _contentRef => _storage.ref().child(_contentPath);
  Reference get _soundsRef => _contentRef.child(_soundsPath);
  Reference get _imagesRef => _contentRef.child(_imagesPath);
  Reference get _storiesRef => _contentRef.child(_storiesPath);
  Reference get _breathingExercisesRef => _contentRef.child(_breathingExercisesPath);

  // ================================
  // KULLANICI PROFİL FOTOĞRAFI
  // ================================

  // Profil fotoğrafı yükle
  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final String fileName = 'profile.jpg';
      final Reference ref = _profilePhotosRef.child(userId).child(fileName);
      
      // Metadata ayarla
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Dosyayı yükle
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      // Download URL al
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Profil fotoğrafı yüklenirken hata: $e');
    }
  }

  // Profil fotoğrafı yükle (Web için Uint8List)
  Future<String?> uploadProfilePhotoBytes(String userId, Uint8List imageBytes) async {
    try {
      final String fileName = 'profile.jpg';
      final Reference ref = _profilePhotosRef.child(userId).child(fileName);
      
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final UploadTask uploadTask = ref.putData(imageBytes, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Profil fotoğrafı yüklenirken hata: $e');
    }
  }

  // Profil fotoğrafını sil
  Future<bool> deleteProfilePhoto(String userId) async {
    try {
      final String fileName = 'profile.jpg';
      final Reference ref = _profilePhotosRef.child(userId).child(fileName);
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Profil fotoğrafı silinirken hata: $e');
      }
      return false;
    }
  }

  // ================================
  // SES DATOları YÖNETİMİ
  // ================================

  // Ses dosyası yükle
  Future<String?> uploadSound({
    required String fileName,
    required File audioFile,
    required String category, // 'meditation', 'nature', 'sleep_stories'
    Map<String, String>? metadata,
  }) async {
    try {
      final String fullPath = '$category/$fileName';
      final Reference ref = _soundsRef.child(fullPath);
      
      final SettableMetadata uploadMetadata = SettableMetadata(
        contentType: 'audio/mpeg',
        customMetadata: {
          'category': category,
          'fileName': fileName,
          'uploadedAt': DateTime.now().toIso8601String(),
          ...?metadata,
        },
      );

      final UploadTask uploadTask = ref.putFile(audioFile, uploadMetadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Ses dosyası yüklenirken hata: $e');
    }
  }

  // Ses dosyasını sil
  Future<bool> deleteSound(String category, String fileName) async {
    try {
      final String fullPath = '$category/$fileName';
      final Reference ref = _soundsRef.child(fullPath);
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Ses dosyası silinirken hata: $e');
      }
      return false;
    }
  }

  // ================================
  // GÖRSEL YÖNETİMİ
  // ================================

  // Görsel yükle
  Future<String?> uploadImage({
    required String fileName,
    required File imageFile,
    required String category, // 'backgrounds', 'journey_covers', 'icons'
    Map<String, String>? metadata,
  }) async {
    try {
      final String fullPath = '$category/$fileName';
      final Reference ref = _imagesRef.child(fullPath);
      
      final SettableMetadata uploadMetadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'category': category,
          'fileName': fileName,
          'uploadedAt': DateTime.now().toIso8601String(),
          ...?metadata,
        },
      );

      final UploadTask uploadTask = ref.putFile(imageFile, uploadMetadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Görsel yüklenirken hata: $e');
    }
  }

  // Görsel yükle (Bytes için)
  Future<String?> uploadImageBytes({
    required String fileName,
    required Uint8List imageBytes,
    required String category,
    Map<String, String>? metadata,
  }) async {
    try {
      final String fullPath = '$category/$fileName';
      final Reference ref = _imagesRef.child(fullPath);
      
      final SettableMetadata uploadMetadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'category': category,
          'fileName': fileName,
          'uploadedAt': DateTime.now().toIso8601String(),
          ...?metadata,
        },
      );

      final UploadTask uploadTask = ref.putData(imageBytes, uploadMetadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Görsel yüklenirken hata: $e');
    }
  }

  // Görseli sil
  Future<bool> deleteImage(String category, String fileName) async {
    try {
      final String fullPath = '$category/$fileName';
      final Reference ref = _imagesRef.child(fullPath);
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Görsel silinirken hata: $e');
      }
      return false;
    }
  }

  // ================================
  // UYKU HİKAYELERİ YÖNETİMİ
  // ================================

  // Hikaye dosyası yükle
  Future<String?> uploadStory({
    required String storyId,
    required String episodeId,
    required File audioFile,
    Map<String, String>? metadata,
  }) async {
    try {
      final String fullPath = '$storyId/${episodeId}.mp3';
      final Reference ref = _storiesRef.child(fullPath);
      
      final SettableMetadata uploadMetadata = SettableMetadata(
        contentType: 'audio/mpeg',
        customMetadata: {
          'storyId': storyId,
          'episodeId': episodeId,
          'uploadedAt': DateTime.now().toIso8601String(),
          ...?metadata,
        },
      );

      final UploadTask uploadTask = ref.putFile(audioFile, uploadMetadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Hikaye dosyası yüklenirken hata: $e');
    }
  }

  // Hikaye dosyasını sil
  Future<bool> deleteStory(String storyId, String episodeId) async {
    try {
      final String fullPath = '$storyId/${episodeId}.mp3';
      final Reference ref = _storiesRef.child(fullPath);
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Hikaye dosyası silinirken hata: $e');
      }
      return false;
    }
  }

  // ================================
  // NEFES EGZERSİZİ SESLERİ
  // ================================

  // Nefes egzersizi ses dosyası yükle
  Future<String?> uploadBreathingExerciseSound({
    required String exerciseId,
    required File audioFile,
    Map<String, String>? metadata,
  }) async {
    try {
      final String fileName = '${exerciseId}_guide.mp3';
      final Reference ref = _breathingExercisesRef.child(fileName);
      
      final SettableMetadata uploadMetadata = SettableMetadata(
        contentType: 'audio/mpeg',
        customMetadata: {
          'exerciseId': exerciseId,
          'type': 'breathing_guide',
          'uploadedAt': DateTime.now().toIso8601String(),
          ...?metadata,
        },
      );

      final UploadTask uploadTask = ref.putFile(audioFile, uploadMetadata);
      final TaskSnapshot snapshot = await uploadTask;
      
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Nefes egzersizi ses dosyası yüklenirken hata: $e');
    }
  }

  // ================================
  // GENEL YÖNETİM FUNKSİYONLARI
  // ================================

  // Dosya boyutunu kontrol et
  Future<int?> getFileSize(String downloadURL) async {
    try {
      final Reference ref = _storage.refFromURL(downloadURL);
      final FullMetadata metadata = await ref.getMetadata();
      return metadata.size;
    } catch (e) {
      if (kDebugMode) {
        print('Dosya boyutu alınırken hata: $e');
      }
      return null;
    }
  }

  // Dosya metadata'sını al
  Future<FullMetadata?> getFileMetadata(String downloadURL) async {
    try {
      final Reference ref = _storage.refFromURL(downloadURL);
      return await ref.getMetadata();
    } catch (e) {
      if (kDebugMode) {
        print('Dosya metadata alınırken hata: $e');
      }
      return null;
    }
  }

  // Dosyayı URL'den sil
  Future<bool> deleteFileFromURL(String downloadURL) async {
    try {
      final Reference ref = _storage.refFromURL(downloadURL);
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Dosya silinirken hata: $e');
      }
      return false;
    }
  }

  // Kategori altındaki tüm dosyaları listele
  Future<List<Reference>> listFiles(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final ListResult result = await ref.listAll();
      return result.items;
    } catch (e) {
      if (kDebugMode) {
        print('Dosyalar listelenirken hata: $e');
      }
      return [];
    }
  }

  // Upload progress izleme
  Stream<TaskSnapshot> uploadWithProgress(Reference ref, File file) {
    final UploadTask uploadTask = ref.putFile(file);
    return uploadTask.snapshotEvents;
  }

  // Upload progress izleme (Bytes için)
  Stream<TaskSnapshot> uploadBytesWithProgress(Reference ref, Uint8List data) {
    final UploadTask uploadTask = ref.putData(data);
    return uploadTask.snapshotEvents;
  }

  // ================================
  // HELPER FUNKSİYONLARI
  // ================================

  // Upload progress yüzdesini hesapla
  double getUploadProgress(TaskSnapshot snapshot) {
    return (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
  }

  // Dosya türünü kontrol et
  bool isValidImageFile(String fileName) {
    final List<String> validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    return validExtensions.any((ext) => fileName.toLowerCase().endsWith(ext));
  }

  bool isValidAudioFile(String fileName) {
    final List<String> validExtensions = ['.mp3', '.wav', '.aac', '.m4a'];
    return validExtensions.any((ext) => fileName.toLowerCase().endsWith(ext));
  }

  // Dosya boyutu kontrolü (MB cinsinden)
  bool isFileSizeValid(File file, double maxSizeMB) {
    final double fileSizeMB = file.lengthSync() / (1024 * 1024);
    return fileSizeMB <= maxSizeMB;
  }

  // Güvenli dosya adı oluştur
  String createSafeFileName(String originalName) {
    return originalName
        .replaceAll(RegExp(r'[^\w\s\-\.]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
} 