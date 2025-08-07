# Breathe Flow: Ürün Geliştirme Yol Haritası

Bu doküman, Breathe Flow uygulamasını sıradan bir rahatlama uygulamasından, kullanıcıların silmeyi aklından bile geçirmeyeceği vazgeçilmez bir yol arkadaşına dönüştürmek için hazırlanmış detaylı bir yol haritasıdır. Her özellik, kullanıcıya nasıl değer katacağı, teknik olarak nasıl hayata geçirileceği ve neden bağımlılık yaratacağı düşünülerek planlanmıştır.

---

## FAZ 1: TEMELİ GÜÇLENDİRME VE KİŞİSELLEŞTİRME

*Amaç: Mevcut kullanıcıyı anında yakalamak ve uygulamanın "akıllı" olduğunu hissettirmek.*

#### 1. Dinamik Ana Sayfa ("Sana Özel Akış")
*   **✅ Özellik Adı:** Sana Özel Akış
*   **✅ Ne İşe Yarar:** Ana sayfayı, statik bir menü olmaktan çıkarıp, günün saatine, kullanıcının geçmiş eylemlerine ve seçtiği ruh haline göre yaşayan, nefes alan bir asistana dönüştürür. Kullanıcıyı her açılışta "Bugün sana ne lazım?" sorusunun cevabıyla karşılar.
*   **✅ Nasıl Çalışır:**
    *   **Kural Tabanlı Başlangıç:** Basit bir kural motoruyla başla. Örnek:
        *   `06:00-10:00 arası:` "Günaydın! Güne enerjik başlamak için 5 dakikalık Enerji Nefesi'ne ne dersin?" kartını en üste koy.
        *   `21:00'den sonra:` "İyi geceler. Uykuya dalmanı kolaylaştıracak 'Alplerde Tren Yolculuğu' hikayesi hazır." kartını göster.
        *   `Kullanıcı 'Odaklanma' ruh halini seçtiyse:` Ana sayfayı "Odaklanma" temalı içeriklerle (Lo-fi müzik listesi, Odak Nefesi egzersizi) doldur.
*   **✅ Neden Bağımlılık Yapar:** "Bu uygulama beni tanıyor" hissi yaratır. Her seferinde aynı sıkıcı ekran yerine, relevant ve taze önerilerle karşılaşmak, kullanıcıyı uygulamayı bir araç olarak değil, bir yol arkadaşı olarak görmeye iter.
*   **✅ Hangi Ekranda:** Ana Sayfa.
*   **✅ Zorluk:** 6/10 (Başlangıçta basit kurallarla kolay, AI ile zorlaşır.)
*   **✅ Başka Yerde Var mı:** Evet, Calm ve Headspace gibi büyükler bunu yapıyor. Spotify'ın ana sayfası mantığı. Bu artık bir lüks değil, standart.

#### 2. Akıllı Ses Karıştırıcı ("Soundscape Studio")
*   **✅ Özellik Adı:** Ses Manzarası Stüdyosu
*   **✅ Ne İşe Yarar:** Kullanıcılara sadece hazır sesleri dinletmek yerine, onlara bir "ses DJ'i" olma imkanı sunar. Yağmur, rüzgar, kamp ateşi, kafe uğultusu gibi sesleri karıştırıp, her birinin volümünü ayarlayarak kendi mükemmel rahatlama veya odaklanma ambiyanslarını yaratmalarını sağlar.
*   **✅ Nasıl Çalışır:** Flutter'daki `just_audio` gibi paketler birden fazla sesi aynı anda çalabilir. Arayüzde her ses için bir ikon ve bir volüm kaydırıcısı (`Slider`) bulunur. Kullanıcı, oluşturduğu bu mix'i "Benim Odaklanma Sesim" gibi bir isimle kaydedebilir.
*   **✅ Neden Bağımlılık Yapar:** Yaratıcılık ve sahiplenme. Kullanıcı pasif bir dinleyici olmaktan çıkıp aktif bir yaratıcıya dönüşür. Kendi yarattığı "esere" duygusal olarak bağlanır ve tekrar tekrar kullanmak ister.
*   **✅ Hangi Ekranda:** Sesler Ekranı.
*   **✅ Zorluk:** 7/10 (UI/UX tasarımı ve seslerin senkronizasyonu biraz uğraştırır.)
*   **✅ Başka Yerde Var mı:** Evet, bazı niş uygulamalarda var. Bunu iyi yapan çok az. Senin için büyük bir farklılaşma fırsatı.

#### 3. Rehberli Meditasyon "Yolculukları"
*   **✅ Özellik Adı:** 7 Günlük Stres Azaltma Yolculuğu
*   **✅ Ne İşe Yarar:** Kullanıcıya tek seferlik meditasyonlar yerine, bir başlangıcı ve sonu olan, yapılandırılmış programlar sunar. "Strese Elveda", "Meditasyona İlk Adım", "Öz Şefkat" gibi temalarda, her gün bir önceki seansın üzerine inşa edilen 7-10 günlük seriler.
*   **✅ Nasıl Çalışır:** Her yolculuk, profesyonel bir seslendirmen tarafından kaydedilmiş numaralandırılmış ses dosyalarından (Gün 1, Gün 2...) oluşur. Kullanıcı bir yolculuğa başladığında, uygulama her gün bir sonraki seansın kilidini açar. "Serideki ilerlemen: 3/7" gibi bir gösterge eklenir.
*   **✅ Neden Bağımlılık Yapar:** Netflix'in "bir sonraki bölüm" etkisi. İlerleme hissi ve seriyi tamamlama arzusu, kullanıcıyı her gün uygulamaya geri getirir. Belirsiz bir "meditasyon yap" hedefi yerine, "bugünkü 10 dakikalık seansı tamamla" gibi somut bir görev verir.
*   **✅ Hangi Ekranda:** Ayrı bir "Meditasyon" veya "Keşfet" ekranı oluşturulmalı.
*   **✅ Zorluk:** İçerik üretimi (profesyonel kayıt) 9/10, teknik implementasyon 4/10.
*   **✅ Başka Yerde Var mı:** Evet, Calm ve Headspace'in temel direğidir. Pazarda rekabet etmek için bu şart.

---

### **FAZ 2: VERİYE DAYALI DEĞER VE DERİNLEŞME**

*Amaç: Uygulamayı "güzel bir oyuncak" olmaktan çıkarıp, kullanıcının hayatına somut fayda sağlayan "vazgeçilmez bir araç" haline getirmek.*

#### 4. Uyku Borcu Hesaplayıcı & Analizi
*   **✅ Özellik Adı:** Uyku Borcu Hesaplayıcı
*   **✅ Ne İşe Yarar:** Kullanıcının haftalık uyku açığını net bir şekilde hesaplar ve "Bu hafta vücuduna 2 saat 30 dakika borçlusun" gibi somut bir veriyle yüzleştirir.
*   **✅ Nasıl Çalışır:**
    *   **Giriş:** Kullanıcı hedef uyku süresini (örn. 8 saat) ve her gece kaçta yatıp kaçta kalktığını manuel olarak girer. (İleri seviye: Google Fit/Apple Health entegrasyonu ile otomatik çekilir).
    *   **Hesaplama:** `(Hedef x 7) - (Gerçekleşen Toplam Uyku)` formülüyle haftalık borç hesaplanır.
    *   **Görselleştirme:** Basit bir bar grafiği ile haftanın her günü ne kadar uyuduğu ve hedefe ne kadar yaklaştığı gösterilir. Toplam borç büyük bir sayıyla vurgulanır.
*   **✅ Neden Bağımlılık Yapar:** Gamification (Oyunlaştırma). İnsanlar sayıları, hedefleri ve "borç kapatma" psikolojisini sever. Bu özellik, soyut olan "iyi uyu" tavsiyesini, "borcunu kapat" gibi somut, ölçülebilir bir göreve dönüştürür.
*   **✅ Hangi Ekranda:** İstatistikler ekranı ve Ana Sayfa'da bir özet widget'ı.
*   **✅ Zorluk:** Manuel giriş ile 4/10. Health entegrasyonu ile 7/10.
*   **✅ Başka Yerde Var mı:** Niş uyku takip uygulamalarında var. Relaxasyon uygulamalarında bu kadar net sunulması, senin için büyük bir avantaj olur.

#### 5. Akıllı Hatırlatıcılar ("Mindful Moments")
*   **✅ Özellik Adı:** An'da Kal Hatırlatıcıları
*   **✅ Ne İşe Yarar:** Gün içinde kullanıcıya "sadece bildirim göndermek" yerine, ona bağlamla ilgili, eyleme geçirilebilir mikro-seanslar sunar.
*   **✅ Nasıl Çalışır:** Kullanıcı ayarlardan hangi konularda hatırlatıcı istediğini seçer (Stres, Duruş, Su iç, Şükran...). Örnek bildirimler:
    *   `(Stres):` "Bir an için dur. Omuzlarını indir ve 3 derin nefes al. Başlat? [Evet] [Hayır]". "Evet"e tıklandığında, uygulama açılmadan direkt bildirim üzerinden 30 saniyelik bir nefes animasyonu oynar.
    *   `(Şükran):` "Bugün minnettar olduğun 1 şeyi düşün. Cevabını günlüğüne yazmak ister misin?"
*   **✅ Neden Bağımlılık Yapar:** Uygulamanın sadece açıldığında değil, gün boyu kullanıcıya değer kattığını gösterir. Yardımcı ve rahatsız etmeyen bir dost gibi hissettirir. Mikro-etkileşimler, büyük seanslardan daha güçlü bir alışkanlık yaratabilir.
*   **✅ Hangi Ekranda:** İşletim sisteminin bildirim merkezi. Ayarları uygulama içinde.
*   **✅ Zorluk:** 8/10 (Zengin bildirimler (rich notifications) ve arka plan servisleri gerektirir, platforma özel kodlama gerekir).
*   **✅ Başka Yerde Var mı:** Bazı uygulamalar yapıyor ama çoğu sadece "Meditasyon zamanı!" gibi sıkıcı bildirimler gönderiyor. Senin yapacağın bu interaktif versiyon çok daha güçlü.

#### **6. Kişisel Günlük & Duygu Takibi ("Reflection Journal")**
*   **✅ Özellik Adı:** Yansıma Günlüğü
*   **✅ Ne İşe Yarar:** Kullanıcının sadece ne yaptığını değil, ne hissettiğini de kaydetmesini sağlar. Meditasyon sonrası "nasıl hissettin?", gün sonu "bugünün en güzel anı neydi?" gibi yönlendirmelerle yapılandırılmış bir günlük tutma deneyimi sunar.
*   **✅ Nasıl Çalışır:**
    *   Kullanıcıya her seans sonrası "Bu seans sana nasıl hissettirdi?" diye sorulur ve birkaç duygu ikonu (mutlu, sakin, nötr, endişeli) sunulur.
    *   Profilde ayrı bir "Günlüğüm" sekmesi olur. Burada tarih bazlı olarak kullanıcının girdiği notlar, seçtiği duygular ve tamamladığı seanslar bir arada gösterilir.
    *   **Gelişmiş Fikir:** Zamanla, "Son 1 ayda en çok 'sakin' hissettiğin günler Salı günleriydi, o günler genelde 'Yağmur Sesi' dinlemişsin." gibi içgörüler sunulabilir.
*   **✅ Neden Bağımlılık Yapar:** Kendini keşfetme ve ilerlemeyi görme. Kullanıcı, uygulamanın sadece bir araç değil, aynı zamanda kendi zihinsel sağlığının bir arşivi olduğunu görür. Geriye dönüp baktığında katettiği yolu görmek güçlü bir motivasyon kaynağıdır.
*   **✅ Hangi Ekranda:** Profil Ekranı (ana bölüm) ve seans bitiş ekranları (giriş noktası).
*   **✅ Zorluk:** Temel versiyon 5/10. İçgörü sunan versiyon 8/10.
*   **✅ Başka Yerde Var mı:** Evet, ama çoğu basit bir not defterinden ibaret. Yönlendirmelerle ve veri analiziyle seninkini farklılaştırabilirsin.

#### **7. Biyometrik Veri Entegrasyonu (HRV Analizi)**
*   **✅ Özellik Adı:** Stres Seviyesi Ölçümü (HRV ile)
*   **✅ Ne İşe Yarar:** Kullanıcının stres seviyesini "nasıl hissediyorsun?" diye sorarak değil, telefonun kamerasıyla parmak ucundan Kalp Atış Hızı Değişkenliğini (HRV) ölçerek somut bir veriyle gösterir. Nefes egzersizi öncesi ve sonrası ölçüm yaparak, egzersizin fizyolojik etkisini kanıtlar.
*   **✅ Nasıl Çalışır:**
    *   Kullanıcı parmağını telefonun arka kamerasına koyar. Flash açılır, kamera parmaktaki kılcal damarlardaki renk değişiminden kalp atışlarını ve atışlar arasındaki milisaniyelik farkları (HRV) algılar. Bunun için hazır SDK'lar ve kütüphaneler mevcut.
    *   Ölçüm sonucu "Stres Seviyen: Yüksek (HRV: 25ms)" veya "Rahatlama Seviyen: İyi (HRV: 65ms)" gibi net bir skorla gösterilir.
    *   "Nefes egzersizi sonrası rahatlama seviyen %30 arttı!" gibi karşılaştırmalı sonuçlar sunulur.
*   **✅ Neden Bağımlılık Yapar:** Somut Kanıt! "İşe yarıyor galiba" hissini, "İşe yaradığını GÖRÜYORUM" kesinliğine dönüştürür. Uygulamanın değerini bilimsel ve kişisel bir kanıtla ortaya koyar. Bu özellik tek başına uygulamayı "oyuncak" kategorisinden "sağlık aracı" kategorisine taşır.
*   **✅ Hangi Ekranda:** İstatistikler Ekranı ve belki de belirli nefes egzersizlerinin başlangıç/bitiş ekranları.
*   **✅ Zorluk:** 9/10 (Harici bir SDK entegrasyonu ve kalibrasyon gerektirir. Teknik olarak zorlayıcıdır ama getirisi çok yüksek.)
*   **✅ Başka Yerde Var mı:** Welltory, EliteHRV gibi spesifik HRV uygulamalarında var. Bir rahatlama uygulamasında bu kadar basit ve etkili sunulması seni pazarda eşsiz kılar.

---

### **FAZ 3: ALIŞKANLIK YARATMA VE SÜRDÜRÜLEBİLİRLİK**

*Amaç: Uygulamayı bir "alışkanlık" haline getirmek, sürdürülebilir bir gelir modeli oluşturmak ve kullanıcıyı bir "hayran"a dönüştürmek.*

#### **8. "Uyku Hikayeleri" Evreni & Serileri**
*   **✅ Özellik Adı:** Breathe Flow Hikaye Evreni
*   **✅ Ne İşe Yarar:** Rastgele, tek seferlik uyku hikayeleri yerine, birbiriyle bağlantılı, devam eden seriler sunar. "Sherlock Holmes'un Kayıp Vakası" (her bölümü 30 dk olan 10 bölümlük bir seri) veya "Kaşif Elara'nın Amazon Günlükleri" gibi.
*   **✅ Nasıl Çalışır:** Hikayeler profesyonel yazarlar ve seslendirmenlerle üretilir. Uygulamada "Seriler" adında yeni bir bölüm açılır. Her gece serinin yeni bir bölümü dinlenir.
*   **✅ Neden Bağımlılık Yapar:** Merak ve beklenti. Tıpkı bir dizinin yeni sezonunu beklemek gibi, kullanıcılar hikayenin devamını dinlemek için ertesi gece tekrar uygulamaya dönerler. Bu, "uyumama yardım et" ihtiyacını, "eğlenceli bir aktivite" ile birleştirir.
*   **✅ Hangi Ekranda:** Uyku Ekranı.
*   **✅ Zorluk:** İçerik üretimi 10/10, teknik implementasyon 3/10.
*   **✅ Başka Yerde Var mı:** Calm bu konuda öncü, ama sen daha niş ve ilginç konularla (örneğin Türk mitolojisi, bilim-kurgu vb.) fark yaratabilirsin.

#### **9. Uzmanlarla İşbirliği & Masterclass'lar**
*   **✅ Özellik Adı:** Uzman Atölyesi (Masterclass'lar)
*   **✅ Ne İşe Yarar:** Uygulamaya güvenilirlik ve derinlik katar. Türkiye'nin tanınmış psikologları, uyku uzmanları, yoga eğitmenleri ile yapılan özel sesli veya videolu içerik serileri. Örnek: "Psikolog Dr. Ayşe Yılmaz ile Anksiyete Yönetimi - 5 Ders".
*   **✅ Nasıl Çalışır:** Uzmanlarla gelir paylaşımı veya tek seferlik ücret karşılığı anlaşılır. İçerikler (genellikle ses) profesyonel kalitede kaydedilir ve uygulama içinde özel bir "Atölye" veya "Masterclass" bölümünde sunulur. Bu içerikler genellikle premium üyelere özel olur.
*   **✅ Neden Bağımlılık Yapar:** Otorite ve Güven. Kullanıcılar, içeriğin rastgele değil, alanında yetkin bir uzman tarafından hazırlandığını bildiğinde ona daha çok değer verir. Bu, uygulamanı bilimsel temeli olan, ciddi bir platform olarak konumlandırır.
*   **✅ Hangi Ekranda:** Keşfet/Meditasyon ekranı içinde yeni bir bölüm.
*   **✅ Zorluk:** İş geliştirme ve içerik anlaşmaları 10/10, teknik implementasyon 4/10.
*   **✅ Başka Yerde Var mı:** Headspace ve Calm'ın en güçlü yanlarından biridir. Lokal pazarda bunu iyi yapan yok, bu senin en büyük kozun olabilir.

#### **10. "Akıllı" Premium Sunumu (Paywall)**
*   **✅ Özellik Adı:** Akıllı Değer Önerisi
*   **✅ Ne İşe Yarar:** Kullanıcının karşısına sürekli "Premium'a Geç" butonu çıkarmak yerine, doğru zamanda, doğru teklifle çıkar. Premium üyeliği bir engel olarak değil, yolculuğun bir sonraki doğal adımı olarak sunar.
*   **✅ Nasıl Çalışır:**
    *   Kullanıcı "7 Günlük Stres Azaltma" yolculuğunu bitirdiğinde: "Harika bir başlangıç yaptın! Şimdi 'İleri Seviye Farkındalık' yolculuğu ile devam etmek için Premium'a geç."
    *   Kullanıcı 3'ten fazla kendi ses manzarasını kaydettiğinde: "Ses tasarımcısı oldun! Sınırsız manzara kaydetmek ve yeni HD seslere erişmek için Premium'a geç."
    *   Kullanıcı ücretsiz bir uzman dersini dinlediğinde: "Dr. Ayşe Yılmaz'ın dersini beğendin mi? Serinin tamamına erişmek için Premium'a geç."
*   **✅ Neden Bağımlılık Yapar:** Bu bir bağımlılık özelliği değil, bir iş modeli özelliğidir. Ancak doğru yapıldığında, kullanıcıyı rahatsız etmeden, tam da ihtiyaç duyduğu anda bir üst seviyeye taşıyarak uygulama deneyimini kesintisiz ve değerli kılar.
*   **✅ Hangi Ekranda:** Uygulamanın çeşitli bağlamsal noktalarında (seans sonu, özellik limiti vb.).
*   **✅ Zorluk:** 7/10 (Kullanıcı davranışlarını takip edip doğru tetikleyicileri kurmak gerekir).
*   **✅ Başka Yerde Var mı:** En başarılı mobil uygulamaların (Duolingo, Strava, vb.) kullandığı en etkili para kazanma yöntemidir. 