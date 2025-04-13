# WinPoi - Ürün Gereksinim Dokümanı (PRD)

## 1. Giriş

### 1.1 Amaç
Bu doküman, WinPoi mobil uygulamasının gereksinimlerini ve özelliklerini detaylı bir şekilde tanımlamaktadır. Doküman, uygulama geliştirme sürecine yön vermek ve tüm paydaşlar arasında ortak bir anlayış sağlamak amacıyla hazırlanmıştır.

### 1.2 Kapsam
WinPoi, kullanıcıların sanal bir harita üzerinde ödülleri bulmaya çalıştıkları, konum-tabanlı bir mobil oyun uygulamasıdır. Bu PRD, uygulamanın Flutter ile geliştirilecek mobil uygulama bileşenlerini ve özellikle backend entegrasyonunu kapsamaktadır.

### 1.3 Hedef Kitle
- Mobil oyun severleri
- Ödüllü yarışmalara katılmak isteyen kullanıcılar
- Konum tabanlı oyunlara ilgi duyan kullanıcılar

## 2. Ürün Vizyonu

WinPoi, kullanıcılara eğlenceli ve rekabetçi bir oyun deneyimi sunarak gerçek ödüller kazanma imkanı veren yenilikçi bir mobil platformdur. Kullanıcılar, gerçek dünya haritalarında ödülleri arayarak zaman bazlı yarışmalara katılır ve çeşitli yetenekler kazanarak oyun içinde ilerlerler.

## 3. Ürün Özellikleri

### 3.1 Temel Özellikler

- **Konum-Tabanlı Ödül Arama**: Kullanıcılar gerçek dünya haritalarında sanal ödülleri ararlar
- **Zaman Bazlı Yarışmalar**: 10-24 saat süren yarışmalar düzenlenir
- **Sıralama Sistemi**: Kullanıcılar ödülleri bulma sürelerine göre sıralanır
- **Çoklu Oyun Hakkı**: Her kullanıcının bir yarışmada 3 deneme hakkı bulunur
- **Oyun İçi Yetenekler**: XP kazanarak açılan yeteneklerle oyun kolaylaştırılabilir
- **Ödül Kazanma**: Süre sonunda en iyi skora sahip oyuncu ödülü kazanır

### 3.2 Kullanıcı Yolculuğu

1. Uygulama indirme ve onboarding ekranı
2. Demo oyun ile tanışma
3. Kayıt olma
4. Ana sayfa ve yarışma seçimi
5. Ödeme ve yarışmaya katılma
6. Oyun oynama ve ödül arama
7. Sıralama takibi
8. Kalan hakları kullanarak iyileştirme yapma
9. Sonuç ve ödül kazanma/kaybetme

## 4. Teknik Gereksinimler

### 4.1 Teknoloji Seçimleri

- **Mobil Uygulama**: Flutter
- **Oyun Motoru**: Unity (Entegre edilecek)
- **Backend Hizmetleri**: Firebase
- **Mimari**: Clean Architecture

### 4.2 Firebase Servisleri

- **Firebase Authentication**: Kullanıcı kayıt, giriş ve kimlik doğrulama işlemleri
- **Firestore Database**: Kullanıcı profilleri, yarışma bilgileri ve sıralama verilerinin saklanması
- **Realtime Database**: Anlık sıralama güncellemeleri ve aktif oyun verileri

### 4.3 Veri Modelleri

#### 4.3.1 Kullanıcı
```
User {
  id: String
  email: String
  username: String
  password: String (hashed)
  phoneNumber: String
  address: String
  joinedDate: Timestamp
  joinedGames: String
  gamesWon: String
  gamesPlayed: String
}
```

#### 4.3.2 Yarışma
```
Contest {
  id: String
  title: String
  prizeImage: String (URL)
  prizeDescription: String
  entryFee: Number
  startTime: Timestamp
  endTime: Timestamp
  isActive: Boolean
  totalParticipants: Number
}
```

#### 4.3.3 Katılım
```
Participation {
  id: String
  userId: String
  contestId: String
  bestTime: Number (seconds)
  attemptsLeft: Number (0-3)
  currentRank: Number
  lastPlayedAt: Timestamp
  xpEarned: Number
  unlockedAbilities: Array<String>
}
```

#### 4.3.4 Sıralama
```
Ranking {
  contestId: String
  rankings: Array<{
    userId: String
    username: String
    time: Number (seconds)
    rank: Number
  }>
  lastUpdated: Timestamp
}
```

## 5. Ekran Tasarımları ve Kullanıcı Arayüzü

### 5.1 Onboarding Ekranı
- Uygulama tanıtımı
- Demo oyun deneyimi
- Kayıt olma/giriş yapma yönlendirmesi

### 5.2 Kayıt Olma/Giriş Ekranı
- E-posta ve şifre ile kayıt
- Google ile hızlı kayıt
- Giriş yapma formu
- Şifremi unuttum seçeneği

### 5.3 Ana Sayfa
- Aktif yarışmaların listesi
- Her yarışma için kart görünümü:
  - Oyun başlığı
  - Ödül resmi
  - Geri sayım süresi
  - Detay butonu
  - Katıl butonu

### 5.4 Yarışma Detay Ekranı
- Büyütülmüş yarışma kartı
- Ödül ayrıntıları
- Katılım ücreti
- Yarışmaya katıl butonu

### 5.5 Aktif Oyunlar Sayfası
- Kullanıcının katıldığı oyunların listesi
- Her oyun için:
  - Başlık
  - Geri sayım
  - Kalan hak sayısı
  - Anlık sıralama bilgisi
  - Tekrar oyna butonu

### 5.6 Oyun Arayüzü(Burası bizimle alakalı değil)
- Unity entegrasyonu ile oyun ekranı
- Labirent şeklinde harita görünümü
- XP göstergesi
- Yetenekler menüsü
- Süre göstergesi

### 5.7 Sıralama Ekranı
- Yarışmaya katılan tüm kullanıcıların sıralaması
- Her kullanıcı için:
  - Kullanıcı adı
  - Tamamlama süresi
  - Mevcut sıralama

### 5.8 Genel Liderlik Tablosu
- Ayın en iyi oyuncuları
- Toplam kazanılan ödül sayısı
- Kullanıcı puanları
- Kişisel sıralama bilgisi

### 5.9 Ayarlar Sayfası
- Profil bilgileri düzenleme
- Şifre değiştirme
- Bildirim tercihleri
- Uygulama hakkında bilgiler
- Kullanıcı sözleşmeleri

## 6. Backend Mimarisi

### 6.1 Clean Architecture Yaklaşımı

#### 6.1.1 Katmanlar
- **Sunum Katmanı**: UI bileşenleri ve sayfa yönetimi
- **Domain Katmanı**: İş mantığı ve use case'ler
- **Veri Katmanı**: Repository implementasyonları ve harici veri kaynaklarına erişim

#### 6.1.2 Bağımlılık Yönetimi
- Dependency Injection kullanılarak bağımlılıkların yönetilmesi
- get_it veya provider paketleri ile servis lokasyonu

### 6.2 Firebase Entegrasyonu

#### 6.2.1 Authentication
- E-posta/şifre tabanlı kimlik doğrulama
- Google ile giriş entegrasyonu
- Oturum durumu yönetimi
- Güvenli erişim kontrolü

#### 6.2.2 Veritabanı Yönetimi
- Cloud Firestore için repository pattern kullanımı
- Realtime Database için anlık dinleyiciler
- Çevrimdışı destek ve veri senkronizasyonu
- Veri tutarlılığı ve güvenliği

#### 6.2.3 Firebase Functions
- Oyun süresi kontrolü için zamanlayıcılar
- Yarışma sonuçlarının otomatik hesaplanması
- Ödül dağıtım sürecinin yönetimi

## 7. Entegrasyon Gereksinimleri

### 7.1 Unity Oyun Motoru Entegrasyonu
- Flutter projesine Unity modülünün entegrasyonu
- Flutter ve Unity arasında veri alışverişi
- Oyun durumunun Flutter uygulamasına aktarılması

### 7.2 Google Maps API Entegrasyonu(Oyun kısmına dahil bizle ilgili değil)
- Gerçek dünya haritalarının oyun içinde kullanılması
- Konum tabanlı özelliklerin implementasyonu

### 7.3 Ödeme Sistemi Entegrasyonu
- Yarışmalara katılım için ödeme sistemi
- Güvenli ödeme işlemleri
- Ödeme geçmişi takibi

## 8. Performans Gereksinimleri

- Uygulama başlatma süresi < 3 saniye
- Ekranlar arası geçiş süresi < 300 ms
- Veritabanı sorgularında cevap süresi < 1 saniye
- Anlık sıralama güncellemeleri < 2 saniye
- Düşük internet bağlantısında çalışabilme

## 9. Güvenlik Gereksinimleri

- Kullanıcı kimlik bilgilerinin güvenli saklanması
- Ödeme bilgilerinin şifrelenmesi
- Firebase güvenlik kurallarının doğru yapılandırılması
- Hile önleme mekanizmaları
- Kullanıcı verilerinin KVKK uyumlu işlenmesi

## 10. Test Stratejisi

### 10.1 Birim Testleri
- Domain katmanı iş mantığı testleri
- Repository ve servis sınıfları testleri

### 10.2 Entegrasyon Testleri
- Firebase servisleri entegrasyon testleri
- Unity entegrasyonu testleri

### 10.3 UI Testleri
- Ekran geçişleri testleri
- Kullanıcı etkileşimi testleri

### 10.4 Yük ve Performans Testleri
- Çok sayıda kullanıcı senaryosu
- Düşük bağlantı koşullarında performans testi

## 11. Geliştirme Zaman Çizelgesi

1. **Temel Yapı ve Mimari (2 hafta)**
   - Proje yapısı kurulumu
   - Firebase entegrasyonu
   - Clean architecture yapılandırması

2. **Kimlik Doğrulama ve Kullanıcı Yönetimi (1 hafta)**
   - Kayıt ve giriş ekranları
   - Firebase Authentication entegrasyonu
   - Kullanıcı profili yönetimi

3. **Ana Ekranlar ve UI (2 hafta)**
   - Ana sayfa
   - Yarışma detay ekranı
   - Aktif oyunlar sayfası
   - Liderlik tablosu

4. **Unity Entegrasyonu (2 hafta)**
   - Unity modülünün Flutter'a entegrasyonu
   - Veri alışverişi mekanizmaları
   - Oyun durumu yönetimi

5. **Yarışma ve Sıralama Sistemi (2 hafta)**
   - Yarışma oluşturma ve yönetme
   - Süre takibi ve sıralama algoritması
   - Realtime Database entegrasyonu

6. **Ödeme Sistemi (1 hafta)**
   - Ödeme akışı tasarımı
   - Ödeme API entegrasyonu
   - Güvenlik önlemleri

7. **Test ve Hata Ayıklama (2 hafta)**
   - Birim testleri
   - Entegrasyon testleri
   - Kullanıcı kabul testleri

8. **Optimizasyon ve İyileştirmeler (1 hafta)**
   - Performans iyileştirmeleri
   - Veritabanı optimizasyonu
   - UI/UX ince ayarları

## 12. Başarı Metrikleri

- Aylık aktif kullanıcı sayısı
- Oturum başına ortalama süre
- Tamamlanan yarışma sayısı
- Kullanıcı başına oyun hakkı kullanım oranı
- Kullanıcı elde tutma oranı
- Ödeme dönüşüm oranı
- Çökme ve hata oranları

## 13. Sonuç

WinPoi, kullanıcılara eğlenceli ve ödüllü bir oyun deneyimi sunmayı hedefleyen yenilikçi bir mobil uygulamadır. Bu PRD, uygulamanın başarılı bir şekilde geliştirilmesi ve sürdürülmesi için gerekli teknik ve işlevsel gereksinimleri detaylandırmaktadır. Flutter ve Firebase teknolojileri kullanılarak, Clean Architecture prensipleriyle geliştirilecek bu uygulama, kullanıcılara hızlı, güvenilir ve keyifli bir deneyim sunmayı amaçlamaktadır. Dediğim gibi biz sadece mmobil uygulama kısmı ile ilgileniyoruz. Oyun kısmını başka bir takımda.
