import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:breathe_flow/models/user.dart';

class UserService {
  static const String _usersCollection = 'users';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı koleksiyonuna referans
  CollectionReference get _usersRef => _firestore.collection(_usersCollection);

  // Yeni kullanıcı oluştur
  Future<void> createUser(AppUser user) async {
    try {
      await _usersRef.doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw Exception('Kullanıcı oluşturulurken hata: $e');
    }
  }

  // Kullanıcı verilerini getir
  Future<AppUser?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _usersRef.doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Kullanıcı verisi alınırken hata: $e');
    }
  }

  // Kullanıcı verilerini gerçek zamanlı dinle
  Stream<AppUser?> getUserStream(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    });
  }

  // Kullanıcı verilerini güncelle
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      await _usersRef.doc(uid).update(updates);
    } catch (e) {
      throw Exception('Kullanıcı verisi güncellenirken hata: $e');
    }
  }

  // Son giriş zamanını güncelle
  Future<void> updateLastLogin(String uid) async {
    try {
      await updateUser(uid, {
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Son giriş zamanı güncellenirken hata: $e');
    }
  }

  // Premium durumunu güncelle
  Future<void> updatePremiumStatus(String uid, bool isPremium, [DateTime? expiryDate]) async {
    try {
      Map<String, dynamic> updates = {
        'isPremium': isPremium,
        'premiumExpiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
      };
      await updateUser(uid, updates);
    } catch (e) {
      throw Exception('Premium durumu güncellenirken hata: $e');
    }
  }

  // Meditasyon dakikalarını artır
  Future<void> addMeditationMinutes(String uid, int minutes) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _usersRef.doc(uid);
        DocumentSnapshot snapshot = await transaction.get(userRef);
        
        if (snapshot.exists) {
          int currentMinutes = snapshot.get('totalMeditationMinutes') ?? 0;
          int newTotal = currentMinutes + minutes;
          
          transaction.update(userRef, {
            'totalMeditationMinutes': newTotal,
            'lastMeditationDate': Timestamp.fromDate(DateTime.now()),
          });
        }
      });
    } catch (e) {
      throw Exception('Meditasyon dakikaları eklenirken hata: $e');
    }
  }

  // Streak günlerini güncelle
  Future<void> updateStreakDays(String uid) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _usersRef.doc(uid);
        DocumentSnapshot snapshot = await transaction.get(userRef);
        
        if (snapshot.exists) {
          DateTime? lastMeditationDate;
          final lastMedData = snapshot.get('lastMeditationDate');
          if (lastMedData != null) {
            lastMeditationDate = (lastMedData as Timestamp).toDate();
          }
          
          int currentStreak = snapshot.get('streakDays') ?? 0;
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);
          
          if (lastMeditationDate != null) {
            DateTime lastMedDay = DateTime(
              lastMeditationDate.year, 
              lastMeditationDate.month, 
              lastMeditationDate.day
            );
            
            // Bugün ilk kez meditasyon yapıyorsa
            if (today.difference(lastMedDay).inDays == 1) {
              // Dün yapmış, streak devam ediyor
              currentStreak++;
            } else if (today.difference(lastMedDay).inDays > 1) {
              // Streak kırılmış, yeniden başla
              currentStreak = 1;
            }
            // Aynı gün ise streak değişmez
          } else {
            // İlk meditasyon
            currentStreak = 1;
          }
          
          transaction.update(userRef, {
            'streakDays': currentStreak,
            'lastMeditationDate': Timestamp.fromDate(now),
          });
        }
      });
    } catch (e) {
      throw Exception('Streak günleri güncellenirken hata: $e');
    }
  }

  // Favori nefes egzersizi ekle
  Future<void> addFavoriteBreathingExercise(String uid, String exerciseId) async {
    try {
      await _usersRef.doc(uid).update({
        'favoriteBreathingExercises': FieldValue.arrayUnion([exerciseId])
      });
    } catch (e) {
      throw Exception('Favori nefes egzersizi eklenirken hata: $e');
    }
  }

  // Favori nefes egzersizi çıkar
  Future<void> removeFavoriteBreathingExercise(String uid, String exerciseId) async {
    try {
      await _usersRef.doc(uid).update({
        'favoriteBreathingExercises': FieldValue.arrayRemove([exerciseId])
      });
    } catch (e) {
      throw Exception('Favori nefes egzersizi çıkarılırken hata: $e');
    }
  }

  // Favori ses ekle
  Future<void> addFavoriteSound(String uid, String soundId) async {
    try {
      await _usersRef.doc(uid).update({
        'favoriteSounds': FieldValue.arrayUnion([soundId])
      });
    } catch (e) {
      throw Exception('Favori ses eklenirken hata: $e');
    }
  }

  // Favori ses çıkar
  Future<void> removeFavoriteSound(String uid, String soundId) async {
    try {
      await _usersRef.doc(uid).update({
        'favoriteSounds': FieldValue.arrayRemove([soundId])
      });
    } catch (e) {
      throw Exception('Favori ses çıkarılırken hata: $e');
    }
  }

  // Tamamlanan journey ekle
  Future<void> addCompletedJourney(String uid, String journeyId) async {
    try {
      await _usersRef.doc(uid).update({
        'completedJourneys': FieldValue.arrayUnion([journeyId])
      });
    } catch (e) {
      throw Exception('Tamamlanan journey eklenirken hata: $e');
    }
  }

  // Kullanıcı tercihlerini güncelle
  Future<void> updateUserPreferences(String uid, Map<String, dynamic> preferences) async {
    try {
      await _usersRef.doc(uid).update({
        'preferences': preferences,
      });
    } catch (e) {
      throw Exception('Kullanıcı tercihleri güncellenirken hata: $e');
    }
  }

  // Bildirim ayarını güncelle
  Future<void> updateNotificationSettings(String uid, bool enabled) async {
    try {
      await updateUser(uid, {'notificationsEnabled': enabled});
    } catch (e) {
      throw Exception('Bildirim ayarları güncellenirken hata: $e');
    }
  }

  // Tema ayarını güncelle
  Future<void> updateThemePreference(String uid, String theme) async {
    try {
      await updateUser(uid, {'preferredTheme': theme});
    } catch (e) {
      throw Exception('Tema ayarı güncellenirken hata: $e');
    }
  }

  // Kullanıcı verilerini sil
  Future<void> deleteUser(String uid) async {
    try {
      await _usersRef.doc(uid).delete();
    } catch (e) {
      throw Exception('Kullanıcı verisi silinirken hata: $e');
    }
  }

  // Tüm kullanıcıları getir (Admin işlevi)
  Future<List<AppUser>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _usersRef.get();
      return querySnapshot.docs
          .map((doc) => AppUser.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Tüm kullanıcılar alınırken hata: $e');
    }
  }

  // Premium kullanıcıları getir (Admin işlevi)
  Future<List<AppUser>> getPremiumUsers() async {
    try {
      QuerySnapshot querySnapshot = await _usersRef
          .where('isPremium', isEqualTo: true)
          .get();
      return querySnapshot.docs
          .map((doc) => AppUser.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Premium kullanıcılar alınırken hata: $e');
    }
  }
} 