# 🔥 Firestore Kurulum Rehberi

## ✅ Tamamlananlar
- [x] cloud_firestore paketi eklendi (v5.6.0)
- [x] AppUser modeli Firestore serialization ile genişletildi
- [x] UserService (CRUD operasyonları) oluşturuldu
- [x] AuthService Firestore ile entegre edildi
- [x] AuthProvider güncellenip gerçek zamanlı veri dinleme eklendi
- [x] Firestore güvenlik kuralları hazırlandı
- [x] Composite indexes tanımlandı

## 🎯 Firebase Console'da Yapılması Gerekenler

### 1. Firestore Database Oluşturma
1. [Firebase Console](https://console.firebase.google.com) → `breathe-flow-app` projesine git
2. **Firestore Database** → **Create database**
3. **Test mode** ile başlat (güvenlik kurallarını sonra uygulayacağız)
4. Location: **eur3 (europe-west)** (Türkiye'ye en yakın)

### 2. Güvenlik Kurallarını Uygulama
1. **Firestore Database** → **Rules** sekmesi
2. Proje kök dizinindeki `firestore.rules` dosyasının içeriğini kopyala
3. Firebase Console'daki rules editörüne yapıştır
4. **Publish** butonuna tıkla

### 3. Composite Indexes Oluşturma
```bash
# Firebase CLI ile otomatik yükleme
firebase deploy --only firestore:indexes

# Veya manuel olarak Firebase Console'dan:
# Firestore Database → Indexes → Composite → Create Index
```

## 📊 Koleksiyon Yapısı

### 👤 users
```
users/{userId}
├── uid: string
├── email: string
├── displayName: string?
├── photoURL: string?
├── createdAt: timestamp
├── lastLoginAt: timestamp
├── isPremium: boolean
├── premiumExpiryDate: timestamp?
├── totalMeditationMinutes: number
├── streakDays: number
├── lastMeditationDate: timestamp?
├── completedJourneys: array<string>
├── favoriteBreathingExercises: array<string>
├── favoriteSounds: array<string>
├── preferences: map
├── notificationsEnabled: boolean
└── preferredTheme: string
```

### 📝 Kullanıcı Alt-Koleksiyonları
```
users/{userId}/journal_entries/{entryId}
users/{userId}/sleep_entries/{entryId}
users/{userId}/hrv_measurements/{measurementId}
```

### 🌟 Public İçerik Koleksiyonları
```
breathing_exercises/{exerciseId}
meditation_journeys/{journeyId}
sounds/{soundId}
stories/{storyId}
premium_content/{contentId}
```

## 🔒 Güvenlik Özellikleri
- ✅ Kullanıcılar sadece kendi verilerine erişebilir
- ✅ Public içerik sadece okunabilir
- ✅ Premium içerik sadece active premium kullanıcılar
- ✅ Critical alanlar (uid, createdAt) değiştirilemez
- ✅ Veri doğrulama fonksiyonları aktif

## 🚀 Kullanım Örnekleri

### Yeni Kullanıcı Kaydı
```dart
// AuthProvider üzerinden otomatik
final success = await authProvider.signUpWithEmail(email, password);
```

### Kullanıcı Verilerini Dinleme
```dart
// AuthProvider'da otomatik real-time listening
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    final user = authProvider.user;
    return Text('Toplam ${user?.totalMeditationMinutes} dakika');
  },
)
```

### Meditasyon İstatistiklerini Güncelleme
```dart
// Meditasyon sonrası
await authProvider.addMeditationMinutes(10);
```

### Favori İşlemleri
```dart
// Favori ses ekle/çıkar
await authProvider.toggleFavoriteSound('ocean_waves');

// Favori nefes egzersizi ekle/çıkar
await authProvider.toggleFavoriteBreathingExercise('4_7_8_breathing');
```

### Kullanıcı Tercihlerini Güncelleme
```dart
await authProvider.updateUserPreferences({
  'breathingReminderTime': '08:00',
  'weeklyGoalMinutes': 105,
});
```

## 🔧 Maintenance Commands

### Firestore Kurallarını Deploy Etme
```bash
firebase deploy --only firestore:rules
```

### Indexes Deploy Etme
```bash
firebase deploy --only firestore:indexes
```

### Firestore Emulator (Development)
```bash
firebase emulators:start --only firestore
```

## 📈 Monitoring
- Firebase Console → Firestore → Usage tab
- Real-time database activity monitoring
- Query performance insights

## 🆘 Troubleshooting

### "Missing or insufficient permissions"
→ Güvenlik kuralları düzgün deploy edilmemiş

### "Index not found" hatası  
→ Composite indexes deploy edilmemiş

### Yavaş query performance
→ Firestore Console'dan query insights kontrol et

## ✨ Özet
Firestore kurulumu tamamlandı! Artık uygulama:
- ✅ Kullanıcı verilerini güvenli şekilde saklayabilir
- ✅ Real-time data synchronization yapabilir  
- ✅ Premium özellikleri kontrol edebilir
- ✅ Meditasyon istatistiklerini takip edebilir
- ✅ Kullanıcı tercihlerini yönetebilir

**Sonraki Adım**: İçerik (ses, resim, hikaye) yönetimi için Cloud Storage kurulumu! 