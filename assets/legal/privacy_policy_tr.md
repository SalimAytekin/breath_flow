# BreathFlow Gizlilik Politikası

**Son güncelleme:** 17 Şubat 2026  
**İletişim:** dxdiag.app@gmail.com

## 1. Topladığımız Veriler
- Hesap bilgileri: UID, e-posta, görünen ad, profil fotoğrafı, hesap oluşturma ve son giriş tarihleri.
- Premium durumu: abonelik tipi (aylık/yıllık), `isPremium`, `premiumExpiryDate`.
- Aktivite istatistikleri: toplam meditasyon dakikası, toplam seans sayısı, streak günleri, son meditasyon tarihi, tamamlanan journey'ler.
- Favoriler ve tercihler: favori nefes egzersizleri ve sesler, günlük hedef, hatırlatma saati, tema tercihi, bildirim durumu.
- Sleep Journal verileri: tarih, yatma/uyanma saatleri, ruh hali seçimi (5 seçenek), rüya notu, uyku kalitesi yorumu.
- Alt koleksiyonlar: aktiviteler, istatistikler, premium kayıtları.
- Analitik & reklam verileri: Firebase Analytics anonim olayları, Crashlytics hata logları, AdMob reklam gösterim istatistikleri.
- Yerel veriler: oturum açmadan önce cihazda saklanan uyku kayıtları (SharedPreferences).

## 2. Verileri Nasıl Kullanıyoruz?
- Uygulamayı kişiselleştirmek (favoriler, hedefler, tema, bildirimler).
- İlerleme istatistikleri göstermek ve senkronize etmek.
- Premium erişimleri doğrulamak.
- Hata takibi, performans analizi ve ürün geliştirme yapmak.
- Google AdMob üzerinden reklam göstermek.

## 3. Verilerin Saklanması
- Bulut verileri Firebase Firestore'da saklanır; Google Cloud güvenlik standartlarına tabidir.
- Cihazda tutulan veriler uygulamayı kaldırdığınızda otomatik silinir.
- Veriler yalnızca hesabınızla ilişkilidir; senkronizasyon sadece oturum açıkken yapılır.

## 4. Üçüncü Taraf Servisler
- **Firebase:** Auth, Firestore, Analytics, Crashlytics, Remote Config.
- **Google AdMob:** Google'ın kişiselleştirilmiş reklam politikalarına tabidir; tercihler Google Ads Ayarları'ndan yönetilebilir.
- **Google Play Billing:** Aylık ve Yıllık Premium abonelikler Google Play tarafından faturalandırılır; iade/iptal süreçleri Google Play kurallarına göre yürür.

## 5. Sağlık Uyarısı
- BreathFlow tıbbi tanı veya tedavi sunmaz; içerikler wellness amaçlıdır.
- Kalp/damar rahatsızlıkları, hipertansiyon, astım/KOAH, nörolojik sorunlar, panik bozukluk, hamilelik veya başka kronik durumlarda egzersizlere başlamadan önce doktorunuza danışın.
- Nefes çalışmaları sırasında baş dönmesi, göğüs ağrısı, nefes darlığı, uyuşma gibi belirtiler yaşarsanız hemen durun ve tıbbi destek alın.
- Uygulamayı araç kullanırken veya dikkat gerektiren aktiviteler esnasında kullanmayın.

## 6. Veri Silme
- Cihazdaki yerel veriler uygulama kaldırıldığında silinir.
- Hesabınızı ve Firestore verilerinizi silmek için kayıtlı e-postanızla dxdiag.app@gmail.com adresine yazabilirsiniz. Talepler 30 gün içinde sonuçlandırılır.

## 7. Haklarınız (KVKK / GDPR)
- Verilerinize erişme, düzeltme, silme, işlemeyi kısıtlama veya itiraz etme hakkına sahipsiniz.
- Talepler için dxdiag.app@gmail.com adresinden bize ulaşabilirsiniz.

## 8. Çocukların Gizliliği
- BreathFlow 13 yaş ve üzeri kullanıcılar içindir.
- 13 yaşından küçük bir kullanıcının verilerini tespit ederseniz lütfen bize bildirin; veriler derhal silinir.

## 9. Değişiklikler
- Politikayı zaman zaman güncelleyebiliriz. "Son güncelleme" tarihini günceller ve önemli değişiklikleri uygulama içinde duyururuz.

## 10. Özet
- Verileriniz cihazınızda ve Firestore'da güvenle saklanır.
- Kişisel verileri üçüncü kişilerle paylaşmayız.
- Reklamlar Google AdMob tarafından yönetilir.
- Sorularınız için her zaman dxdiag.app@gmail.com adresinden bize ulaşabilirsiniz.
