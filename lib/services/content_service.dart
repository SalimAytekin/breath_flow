import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:breathe_flow/services/storage_service.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  // ================================
  // SES KATALOğU YÖNETİMİ
  // ================================

  // Yeni ses dosyası ekle
  Future<String> addSound({
    required String title,
    required String description,
    required String category, // 'meditation', 'nature', 'sleep_stories'
    required int durationSeconds,
    required File audioFile,
    bool isPremium = false,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Önce storage'a yükle
      String fileName = _storageService.createSafeFileName('${title}_${DateTime.now().millisecondsSinceEpoch}.mp3');
      
      String? downloadURL = await _storageService.uploadSound(
        fileName: fileName,
        audioFile: audioFile,
        category: category,
        metadata: {
          'title': title,
          'description': description,
          'durationSeconds': durationSeconds.toString(),
          'isPremium': isPremium.toString(),
          ...?metadata,
        },
      );

      if (downloadURL == null) {
        throw Exception('Ses dosyası yüklenemedi');
      }

      // Firestore'a metadata ekle
      DocumentReference docRef = await _firestore.collection('sounds').add({
        'title': title,
        'description': description,
        'category': category,
        'durationSeconds': durationSeconds,
        'downloadURL': downloadURL,
        'fileName': fileName,
        'isPremium': isPremium,
        'playCount': 0,
        'averageRating': 0.0,
        'totalRatings': 0,
        'tags': metadata?['tags'] ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Ses dosyası eklenirken hata: $e');
    }
  }

  // Ses listesini getir
  Future<List<Map<String, dynamic>>> getSounds({
    String? category,
    bool? isPremium,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore.collection('sounds')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (isPremium != null) {
        query = query.where('isPremium', isEqualTo: isPremium);
      }

      QuerySnapshot snapshot = await query.limit(limit).get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      throw Exception('Sesler getirilirken hata: $e');
    }
  }

  // Ses oynatma sayısını artır
  Future<void> incrementSoundPlayCount(String soundId) async {
    try {
      await _firestore.collection('sounds').doc(soundId).update({
        'playCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Play count güncellenirken hata: $e');
    }
  }

  // Ses derecelendirme ekle
  Future<void> rateSoundAlertDialog(String soundId, double rating, String userId) async {
    try {
      // Kullanıcının önceki dereceli var mı kontrol et
      QuerySnapshot existingRating = await _firestore
          .collection('sound_ratings')
          .where('soundId', isEqualTo: soundId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingRating.docs.isNotEmpty) {
        // Var olan derecelendirmeyi güncelle
        await _firestore
            .collection('sound_ratings')
            .doc(existingRating.docs.first.id)
            .update({
          'rating': rating,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Yeni derecelendirme ekle
        await _firestore.collection('sound_ratings').add({
          'soundId': soundId,
          'userId': userId,
          'rating': rating,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Ortalama rating'i yeniden hesapla
      await _updateSoundAverageRating(soundId);
    } catch (e) {
      throw Exception('Derecelendirme eklenirken hata: $e');
    }
  }

  // ================================
  // HİKAYE YÖNETİMİ
  // ================================

  // Yeni hikaye serisi oluştur
  Future<String> createStorySeries({
    required String title,
    required String description,
    required String author,
    required File coverImageFile,
    bool isPremium = false,
    List<String> tags = const [],
  }) async {
    try {
      // Cover image'ı yükle
      String coverFileName = _storageService.createSafeFileName('${title}_cover_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      String? coverURL = await _storageService.uploadImage(
        fileName: coverFileName,
        imageFile: coverImageFile,
        category: 'story_covers',
        metadata: {
          'title': title,
          'author': author,
        },
      );

      if (coverURL == null) {
        throw Exception('Cover görseli yüklenemedi');
      }

      // Firestore'a ekle
      DocumentReference docRef = await _firestore.collection('story_series').add({
        'title': title,
        'description': description,
        'author': author,
        'coverURL': coverURL,
        'coverFileName': coverFileName,
        'isPremium': isPremium,
        'tags': tags,
        'episodeCount': 0,
        'totalDurationMinutes': 0,
        'averageRating': 0.0,
        'totalRatings': 0,
        'playCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Hikaye serisi oluşturulurken hata: $e');
    }
  }

  // Hikaye serisine episode ekle
  Future<String> addStoryEpisode({
    required String seriesId,
    required String title,
    required String description,
    required int episodeNumber,
    required int durationMinutes,
    required File audioFile,
  }) async {
    try {
      // Audio dosyasını yükle
      String? downloadURL = await _storageService.uploadStory(
        storyId: seriesId,
        episodeId: 'episode_$episodeNumber',
        audioFile: audioFile,
        metadata: {
          'title': title,
          'episodeNumber': episodeNumber.toString(),
          'durationMinutes': durationMinutes.toString(),
        },
      );

      if (downloadURL == null) {
        throw Exception('Episode ses dosyası yüklenemedi');
      }

      // Episode'u Firestore'a ekle
      DocumentReference docRef = await _firestore
          .collection('story_series')
          .doc(seriesId)
          .collection('episodes')
          .add({
        'title': title,
        'description': description,
        'episodeNumber': episodeNumber,
        'durationMinutes': durationMinutes,
        'downloadURL': downloadURL,
        'playCount': 0,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Seri istatistiklerini güncelle
      await _updateStorySeriesStats(seriesId);

      return docRef.id;
    } catch (e) {
      throw Exception('Episode eklenirken hata: $e');
    }
  }

  // Hikaye serilerini getir
  Future<List<Map<String, dynamic>>> getStorySeries({
    bool? isPremium,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('story_series')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      if (isPremium != null) {
        query = query.where('isPremium', isEqualTo: isPremium);
      }

      QuerySnapshot snapshot = await query.limit(limit).get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      throw Exception('Hikaye serileri getirilirken hata: $e');
    }
  }

  // Episode'ları getir
  Future<List<Map<String, dynamic>>> getStoryEpisodes(String seriesId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('story_series')
          .doc(seriesId)
          .collection('episodes')
          .where('isActive', isEqualTo: true)
          .orderBy('episodeNumber')
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      throw Exception('Episodes getirilirken hata: $e');
    }
  }

  // ================================
  // NEFES EGZERSİZİ SESLERİ
  // ================================

  // Nefes egzersizi ses dosyası ekle
  Future<void> addBreathingExerciseSound({
    required String exerciseId,
    required File audioFile,
  }) async {
    try {
      String? downloadURL = await _storageService.uploadBreathingExerciseSound(
        exerciseId: exerciseId,
        audioFile: audioFile,
      );

      if (downloadURL == null) {
        throw Exception('Nefes egzersizi ses dosyası yüklenemedi');
      }

      // Exercise document'ını güncelle
      await _firestore.collection('breathing_exercises').doc(exerciseId).update({
        'audioURL': downloadURL,
        'hasAudio': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Nefes egzersizi ses dosyası eklenirken hata: $e');
    }
  }

  // ================================
  // HELPER FONKSİYONLARI
  // ================================

  // Ses ortalama rating'ini güncelle
  Future<void> _updateSoundAverageRating(String soundId) async {
    try {
      QuerySnapshot ratings = await _firestore
          .collection('sound_ratings')
          .where('soundId', isEqualTo: soundId)
          .get();

      if (ratings.docs.isNotEmpty) {
        double totalRating = 0;
        for (QueryDocumentSnapshot doc in ratings.docs) {
          totalRating += (doc.data() as Map<String, dynamic>)['rating'];
        }

        double averageRating = totalRating / ratings.docs.length;

        await _firestore.collection('sounds').doc(soundId).update({
          'averageRating': averageRating,
          'totalRatings': ratings.docs.length,
        });
      }
    } catch (e) {
      print('Average rating güncellenirken hata: $e');
    }
  }

  // Hikaye serisi istatistiklerini güncelle
  Future<void> _updateStorySeriesStats(String seriesId) async {
    try {
      QuerySnapshot episodes = await _firestore
          .collection('story_series')
          .doc(seriesId)
          .collection('episodes')
          .where('isActive', isEqualTo: true)
          .get();

      int episodeCount = episodes.docs.length;
      int totalDurationMinutes = 0;

      for (QueryDocumentSnapshot episode in episodes.docs) {
        Map<String, dynamic> data = episode.data() as Map<String, dynamic>;
        totalDurationMinutes += (data['durationMinutes'] as int?) ?? 0;
      }

      await _firestore.collection('story_series').doc(seriesId).update({
        'episodeCount': episodeCount,
        'totalDurationMinutes': totalDurationMinutes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Hikaye serisi istatistikleri güncellenirken hata: $e');
    }
  }

  // Popüler içerikleri getir
  Future<Map<String, List<Map<String, dynamic>>>> getPopularContent() async {
    try {
      // Popüler sesler
      QuerySnapshot popularSounds = await _firestore
          .collection('sounds')
          .where('isActive', isEqualTo: true)
          .orderBy('playCount', descending: true)
          .limit(10)
          .get();

      // Popüler hikayeler
      QuerySnapshot popularStories = await _firestore
          .collection('story_series')
          .where('isActive', isEqualTo: true)
          .orderBy('playCount', descending: true)
          .limit(10)
          .get();

      return {
        'sounds': popularSounds.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList(),
        'stories': popularStories.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList(),
      };
    } catch (e) {
      throw Exception('Popüler içerik getirilirken hata: $e');
    }
  }

  // Kategori bazında içerik sayıları
  Future<Map<String, int>> getContentCounts() async {
    try {
      Map<String, int> counts = {};

      // Ses kategorileri
      List<String> soundCategories = ['meditation', 'nature', 'sleep_stories'];
      for (String category in soundCategories) {
        QuerySnapshot snapshot = await _firestore
            .collection('sounds')
            .where('category', isEqualTo: category)
            .where('isActive', isEqualTo: true)
            .get();
        counts['sounds_$category'] = snapshot.docs.length;
      }

      // Toplam hikaye serisi sayısı
      QuerySnapshot storiesSnapshot = await _firestore
          .collection('story_series')
          .where('isActive', isEqualTo: true)
          .get();
      counts['story_series'] = storiesSnapshot.docs.length;

      return counts;
    } catch (e) {
      throw Exception('İçerik sayıları getirilirken hata: $e');
    }
  }
} 