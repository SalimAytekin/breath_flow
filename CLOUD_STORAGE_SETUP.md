# 🔥 Firebase Cloud Storage Kurulum Rehberi

Bu rehber BreathFlow uygulaması için Firebase Cloud Storage kurulumunu adım adım açıklar.

## 📋 ADIM 1: Firebase Console'da Storage Aktivasyonu

### 1.1 Firebase Console'a Giriş
1. [Firebase Console](https://console.firebase.google.com) adresine gidin
2. BreathFlow projenizi seçin

### 1.2 Storage Servisini Aktifleştir
1. Sol menüden **"Build"** → **"Storage"** seçin
2. **"Get started"** butonuna tıklayın
3. Security rules için **"Start in test mode"** seçin (geçici)
4. **"Next"** butonuna tıklayın
5. Cloud Storage location seçin:
   - Avrupa: `europe-west1` (Amsterdam)
   - ABD: `us-central1` (Iowa)
   - Asya: `asia-northeast1` (Tokyo)
6. **"Done"** butonuna tıklayın

### 1.3 Bucket Oluşturulmasını Bekleyin
- Firebase otomatik olarak default bucket oluşturacak
- Bucket adı: `your-project-id.appspot.com` formatında olacak

## 📋 ADIM 2: Security Rules Güncelleme

### 2.1 Rules Sekmesine Geç
1. Storage sayfasında **"Rules"** sekmesine tıklayın
2. Mevcut rule'ları silin

### 2.2 Yeni Security Rules Uygula
`storage.rules` dosyasındaki kuralları Firebase Console'a kopyalayın:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Kullanıcı profil fotoğrafları
    match /profile_photos/{userId}/{filename} {
      allow read, write, delete: if request.auth != null 
        && request.auth.uid == userId;
      allow write: if request.auth != null 
        && request.auth.uid == userId
        && request.resource.size <= 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
    
    // Uygulama içeriği - sadece okuma
    match /content/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    
    // Premium içerik
    match /content/premium/{allPaths=**} {
      allow read: if request.auth != null && isPremiumUser(request.auth.uid);
      allow write: if false;
    }
    
    // Diğer dosyalar
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
  
  function isPremiumUser(userId) {
    return exists(/databases/(default)/documents/users/$(userId)) &&
           get(/databases/(default)/documents/users/$(userId)).data.isPremium == true;
  }
}
```

### 2.3 Rules'ı Publish Et
1. **"Publish"** butonuna tıklayın
2. Onay mesajını bekleyin

## 📋 ADIM 3: Klasör Yapısı Oluşturma

### 3.1 İlk Dosya Upload'u
Storage bucket'ına ilk klasör yapısını oluşturmak için:

1. **"Upload file"** butonuna tıklayın
2. Herhangi bir test dosyası seçin
3. Dosya yolunu şu şekilde belirtin:
   ```
   content/sounds/meditation/test.mp3
   content/images/backgrounds/test.jpg
   content/stories/test_series/test.mp3
   content/breathing_exercises/test.mp3
   profile_photos/test_user_id/profile.jpg
   ```

### 3.2 Test Dosyalarını Sil
- Upload işleminden sonra test dosyalarını silebilirsiniz
- Klasör yapısı korunur

## 📋 ADIM 4: CORS Ayarları (Web için)

### 4.1 Google Cloud Console'a Giriş
1. [Google Cloud Console](https://console.cloud.google.com) adresine gidin
2. Firebase projenizi seçin

### 4.2 Cloud Shell Açın
1. Sağ üst köşedeki Cloud Shell ikonuna tıklayın
2. Terminal açılmasını bekleyin

### 4.3 CORS Dosyası Oluştur
```bash
cat > cors.json << EOF
[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Authorization"]
  }
]
EOF
```

### 4.4 CORS Ayarlarını Uygula
```bash
gsutil cors set cors.json gs://your-project-id.appspot.com
```

**Not:** `your-project-id` yerine gerçek proje ID'nizi yazın.

## 📋 ADIM 5: Storage Monitoring

### 5.1 Usage Monitoring
1. Storage ana sayfasında **"Usage"** sekmesine tıklayın
2. Günlük/aylık kullanım istatistiklerini görüntüleyin

### 5.2 Quotas & Limits
- Ücretsiz plan: 5 GB storage, 1 GB/gün transfer
- Upload limit: 32 MB/dosya
- Download limit: Sınırsız

## 📋 ADIM 6: Test ve Doğrulama

### 6.1 Flutter Uygulamasında Test
1. `flutter pub get` komutunu çalıştırın
2. Uygulamayı başlatın
3. Profil fotoğrafı upload işlemini test edin

### 6.2 Console'da Doğrulama
1. Firebase Console → Storage
2. **"Files"** sekmesinde yüklenen dosyaları görün
3. Metadata bilgilerini kontrol edin

## 🔧 Sorun Giderme

### Authentication Hatası
```
User does not have permission to access this object
```
**Çözüm:**
- Security rules'ı kontrol edin
- Kullanıcının giriş yapmış olduğundan emin olun

### CORS Hatası (Web)
```
Cross-Origin Request Blocked
```
**Çözüm:**
- CORS ayarlarını tekrar uygulayın
- Bucket adını doğrulayın

### Upload Hatası
```
File size limit exceeded
```
**Çözüm:**
- Security rules'da dosya boyutu limitini kontrol edin
- Maksimum 5MB profil fotoğrafı izni var

### Storage Rules Hatası
```
Permission denied
```
**Çözüm:**
- Rules'da syntax hatası kontrol edin
- Firestore ile Storage rules entegrasyonu doğrulayın

## 📊 Best Practices

### 6.1 Dosya Organizasyonu
```
bucket-name/
├── profile_photos/
│   └── {userId}/
│       └── profile.jpg
├── content/
│   ├── sounds/
│   │   ├── meditation/
│   │   ├── nature/
│   │   └── sleep_stories/
│   ├── images/
│   │   ├── backgrounds/
│   │   └── story_covers/
│   ├── stories/
│   │   └── {series_id}/
│   └── breathing_exercises/
└── premium/
    └── {content_type}/
```

### 6.2 Güvenlik
- Profil fotoğrafları sadece sahibi tarafından erişilebilir
- İçerik sadece authenticated kullanıcılar tarafından okunabilir
- Premium içerik sadece premium kullanıcılar tarafından erişilebilir
- Admin paneli için ayrı rules gerekebilir

### 6.3 Performance
- Resim boyutlarını optimize edin (512x512 profil fotoğrafı)
- CDN otomatik olarak aktif
- Caching headers ayarlayın

## ✅ Kurulum Tamamlandı!

Bu adımları tamamladıktan sonra:
- ✅ Firebase Storage aktif
- ✅ Security rules uygulandı
- ✅ Klasör yapısı oluşturuldu
- ✅ CORS ayarları yapıldı
- ✅ Test edildi

**Sonraki Adım:** Analytics ve Cloud Functions kurulumu 