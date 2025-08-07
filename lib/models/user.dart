import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  
  // Meditation özellikleri
  final int totalMeditationMinutes;
  final int streakDays;
  final DateTime? lastMeditationDate;
  final List<String> completedJourneys;
  final List<String> favoriteBreathingExercises;
  final List<String> favoriteSounds;
  
  // Ayarlar
  final Map<String, dynamic> preferences;
  final bool notificationsEnabled;
  final String? preferredTheme; // 'light', 'dark', 'system'

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.totalMeditationMinutes = 0,
    this.streakDays = 0,
    this.lastMeditationDate,
    this.completedJourneys = const [],
    this.favoriteBreathingExercises = const [],
    this.favoriteSounds = const [],
    this.preferences = const {},
    this.notificationsEnabled = true,
    this.preferredTheme = 'system',
  });

  // Firestore'dan AppUser oluştur
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppUser(
      uid: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      isPremium: data['isPremium'] ?? false,
      premiumExpiryDate: data['premiumExpiryDate'] != null 
          ? (data['premiumExpiryDate'] as Timestamp).toDate() 
          : null,
      totalMeditationMinutes: data['totalMeditationMinutes'] ?? 0,
      streakDays: data['streakDays'] ?? 0,
      lastMeditationDate: data['lastMeditationDate'] != null 
          ? (data['lastMeditationDate'] as Timestamp).toDate() 
          : null,
      completedJourneys: List<String>.from(data['completedJourneys'] ?? []),
      favoriteBreathingExercises: List<String>.from(data['favoriteBreathingExercises'] ?? []),
      favoriteSounds: List<String>.from(data['favoriteSounds'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      preferredTheme: data['preferredTheme'] ?? 'system',
    );
  }

  // Firestore'a göndermek için Map'e çevir
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate != null 
          ? Timestamp.fromDate(premiumExpiryDate!) 
          : null,
      'totalMeditationMinutes': totalMeditationMinutes,
      'streakDays': streakDays,
      'lastMeditationDate': lastMeditationDate != null 
          ? Timestamp.fromDate(lastMeditationDate!) 
          : null,
      'completedJourneys': completedJourneys,
      'favoriteBreathingExercises': favoriteBreathingExercises,
      'favoriteSounds': favoriteSounds,
      'preferences': preferences,
      'notificationsEnabled': notificationsEnabled,
      'preferredTheme': preferredTheme,
    };
  }

  // Premium durumunu kontrol et
  bool get isActivePremium {
    if (!isPremium) return false;
    if (premiumExpiryDate == null) return true; // Lifetime premium
    return premiumExpiryDate!.isAfter(DateTime.now());
  }

  // Kullanıcıyı güncellemek için copyWith metodu
  AppUser copyWith({
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? lastLoginAt,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    int? totalMeditationMinutes,
    int? streakDays,
    DateTime? lastMeditationDate,
    List<String>? completedJourneys,
    List<String>? favoriteBreathingExercises,
    List<String>? favoriteSounds,
    Map<String, dynamic>? preferences,
    bool? notificationsEnabled,
    String? preferredTheme,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      totalMeditationMinutes: totalMeditationMinutes ?? this.totalMeditationMinutes,
      streakDays: streakDays ?? this.streakDays,
      lastMeditationDate: lastMeditationDate ?? this.lastMeditationDate,
      completedJourneys: completedJourneys ?? this.completedJourneys,
      favoriteBreathingExercises: favoriteBreathingExercises ?? this.favoriteBreathingExercises,
      favoriteSounds: favoriteSounds ?? this.favoriteSounds,
      preferences: preferences ?? this.preferences,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredTheme: preferredTheme ?? this.preferredTheme,
    );
  }
} 