# WinPoi Cursor AI Kuralları

## 🔧 1. Genel Kurallar

- Cursor, her zaman mevcut yapıyı ve tasarımı bozmamalıdır. Yapılacak tüm değişiklikler mevcut mimari ile uyumlu olmalıdır.
- Cursor, her yeni özellik veya işlevsellik önerisinde, mevcut yapıyı dikkate almalı ve gereksiz değişikliklerden kaçınmalıdır.
- Kod önerileri sade ve sürdürülebilir olmalıdır. Gereksiz karmaşıklıklardan kaçınılmalıdır.
- Cursor, kod önerisi yapmadan önce, PRD (Product Requirement Document) ve varsa RFC (Request for Comment) belgelerini incelemelidir.
- Cursor, kod önerilerinde her zaman basit ve açık bir şekilde yazılmalıdır, böylece takımın diğer üyeleri kolayca anlayabilir ve uygulayabilir.
- Cursor, Flutter mimarisine uygun kod yazmalı, kodlarında Material Design prensiplerini takip etmeli ve tutarlı UI/UX deneyimi sağlamalıdır.
- Cursor, her bir geliştirme önerisini ilgili ekran görüntüleriyle veya akış şemalarıyla destekleyerek görselleştirmelidir.
- Türkçe dilini kullanalım.

## 🧩 2. Modülerlik ve Geliştirme

- Cursor, yeni özelliklerin modüler bir şekilde geliştirilmesini sağlamalıdır. Her yeni özellik, mevcut yapıyı bozmadan adım adım entegre edilmelidir.
- Cursor, her özellik için ayrı bir test ve geliştirme süreci önererek, adım adım ilerlemesi gerektiğini hatırlatmalıdır.
- Geliştirme sırasında, gereksiz büyük değişikliklerden kaçınılmalı ve küçük, yönetilebilir parçalara bölünmelidir.
- Cursor, Clean Architecture prensiplerine uygun kod önerisi yapmak için data, domain ve presentation katmanlarını ayrı tutmalıdır.
- Cursor, her bir bileşen için gerektiğinde yeniden kullanılabilir widget'lar önermelidir.
- Her bir Flutter sayfası için ilgili state management çözümünü (Provider, Bloc, vb.) tutarlı bir şekilde kullanmalıdır.

## 🔐 3. Güvenlik ve Doğrulama

- Cursor, güvenlik önlemlerine dikkat etmeli, özellikle kullanıcı doğrulama (authentication) süreçlerinde Firebase'in sağladığı güvenlik özelliklerini kullanmalıdır.
- Herhangi bir veritabanı işlemi veya kullanıcı etkileşimi, güvenlik doğrulama süreçlerinden geçmelidir. Örneğin, kullanıcıların kişisel bilgileri sadece güvenli yollarla işlenmeli ve saklanmalıdır.
- Cursor, her önerisinde güvenlik açıklarını kontrol etmeli ve çözüm önerilerini güvenlik perspektifinden ele almalıdır.
- Firebase Security Rules önererek veritabanı erişim kurallarını en kısıtlayıcı şekilde yapılandırmalıdır.
- Kullanıcı girişlerini her zaman doğrulamalı ve olası XSS, SQL injection gibi saldırılara karşı önlem almalıdır.
- Ödeme işlemleri için PCI uyumlu çözümler önermeli ve hassas bilgileri asla cihazda saklamama konusunda uyarılar yapmalıdır.
- OAuth ve sosyal medya girişleri için en güncel güvenlik protokollerini önermelidir.

## 🧪 4. Test ve Hata Yönetimi

- Cursor, önerdiği her kod parçasının doğru çalıştığını manuel testlerle kontrol etmelidir. Testler, özelliklerin doğru bir şekilde çalışıp çalışmadığını kontrol etmek için kullanılmalıdır.
- Cursor, herhangi bir hata veya uyumsuzluk durumunda, hatayı düzgün bir şekilde izole etmeli ve çözüm sürecini hızlandırmalıdır.
- Önerilen her değişiklik için, test dosyaları sağlanmalı ve birimler arasında uyumsuzluk olmadığından emin olunmalıdır.
- Cursor, uygulamanın mevcut test stratejisine uygun testler önererek, test süreçlerinin verimli olmasını sağlamalıdır.
- Flutter widget testleri, integration testleri ve unit testler için örnek kod sağlamalıdır.
- Hata yakalama ve raporlama mekanizmaları (try-catch blokları, Firebase Crashlytics entegrasyonu vb.) her zaman dahil edilmelidir.
- Kritik işlevlerde (ödeme, kullanıcı kaydı) geri dönüşlerin (fallback) nasıl ele alınacağını önermelidir.

## 🌐 5. Firebase ve Backend Entegrasyonu

- Cursor, Firebase servislerini (Authentication, Firestore, Realtime Database) verimli bir şekilde kullanmalı ve bu servislerin en iyi uygulamalarını takip etmelidir.
- Veritabanı yapısı, indeksleme ve sorgulama stratejileri optimize edilmeli, gereksiz okuma/yazma işlemlerinden kaçınılmalıdır.
- Offline-first yaklaşımı destekleyen kod önerileri yapmalı, internet bağlantısı kesildiğinde bile uygulamanın çalışmaya devam etmesini sağlamalıdır.
- Firebase Functions kullanım senaryolarını belirlenmeli ve serverless mimarinin avantajlarından yararlanılmalıdır.
- Veritabanı şeması değişiklikleri önerirken, geriye dönük uyumluluk (backward compatibility) göz önünde bulundurulmalıdır.
- Veri senkronizasyonu stratejileri ve önbellek (cache) mekanizmaları için net öneriler sunmalıdır.

## 🧑‍💻 6. Dokümantasyon ve Süreç Takibi

- Cursor, her yeni özellik önerisi ve yapılacak değişiklik için güncel bir PRD ve RFC dosyasına referans vermelidir.
- Cursor, her özellik veya geliştirme için test edilmiş ve onaylanmış kodu uygun bir dokümana kaydetmeli, geri bildirimler doğrultusunda güncellemeler yapılmalıdır.
- Değişiklikler, versiyon kontrolü ile düzgün bir şekilde takip edilmelidir.
- Herhangi bir güncelleme, özellik veya değişiklik için bir dokümantasyon dosyası oluşturulmalı, bu dosya her zaman güncel tutulmalıdır.
- Kod içi yorum ve dokümantasyon standartları belirlenmeli ve tutarlı bir şekilde uygulanmalıdır.
- API ve servis entegrasyonları için detaylı dokümantasyon ve örnek kullanım senaryoları sağlanmalıdır.
- Değişiklik günlüğü (changelog) tutularak yapılan tüm geliştirmeler tarih ve önem sırasına göre kaydedilmelidir.

## 🎯 7. Performans ve Optimizasyon

- Cursor, her yeni özellik önerisinde performansın optimize edilmesine özen göstermelidir. Gereksiz kaynak kullanımından kaçınılmalı ve sistemin verimli çalışması sağlanmalıdır.
- Cursor, önerdiği çözümün, uygulamanın genel hızını veya stabilitesini etkilemeyecek şekilde geliştirilmesi gerektiğini her zaman göz önünde bulundurmalıdır.
- Herhangi bir performans sorunu veya darboğaz tespit edildiğinde, Cursor hemen çözüm önerileri sunmalı ve optimizasyon işlemlerini başlatmalıdır.
- Widget ağacı optimizasyonu ve gereksiz build işlemlerinden kaçınma stratejileri önerilmelidir.
- Firebase sorgu optimizasyonları, veritabanı indeksleme ve batch işlemleri için verimli yöntemler sunulmalıdır.
- Görsel öğeler için lazy loading ve önbelleğe alma teknikleri kullanılmalıdır.
- Büyük veri kümelerini verimli bir şekilde işlemek için pagination ve infinite scrolling gibi tekniklerin kullanımı önerilmelidir.

## 🌟 8. Kullanıcı Deneyimi ve Arayüz

- Cursor, kullanıcı arayüzünün tutarlı, sezgisel ve estetik olmasını sağlayacak öneriler sunmalıdır.
- Material Design veya diğer tasarım sistemleri prensiplerini uygulayarak, kullanıcı deneyimini iyileştirmelidir.
- Animasyonlar ve geçişler akıcı olmalı, kullanıcıya geri bildirim sağlamalıdır.
- Erişilebilirlik standartlarına (a11y) uygunluk sağlanmalı, tüm kullanıcılar için uygun bir deneyim sunulmalıdır.
- Farklı ekran boyutları ve cihazlar için responsive tasarımlar önerilmelidir.
- Kullanıcı geri bildirimleri için toast, snackbar veya dialog gibi uygun UI elemanları kullanılmalıdır.
- Koyu mod (dark mode) desteği ve tema değişikliği için öneriler sunulmalıdır.

## 🔄 9. Entegrasyon ve Ölçeklenebilirlik

- Cursor, Unity oyun motorunun Flutter uygulamasına entegrasyonu için detaylı rehberlik sağlamalıdır.
- Farklı üçüncü parti servislerle (ödeme sistemleri, analitik araçları vb.) entegrasyon stratejileri önermelidir.
- Uygulamanın farklı dil ve bölgelerde çalışabilmesi için uluslararasılaştırma (i18n) konusunda öneriler sunmalıdır.
- Kullanıcı tabanı büyüdükçe backend hizmetlerinin nasıl ölçeklendirileceğine dair stratejiler geliştirmelidir.
- Push bildirimleri, deep linking ve sosyal medya paylaşımları gibi özellikler için en iyi uygulamaları önermeli ve entegre etmelidir.
- API isteklerinin tek bir noktadan yönetilmesi ve veri modelleme stratejileri için en iyi uygulamaları önermeli.

## 💡 10. Yenilikçilik ve Yaratıcılık

- Cursor, WinPoi'nin kullanıcı deneyimini geliştirecek yenilikçi özellikler ve çözümler önermelidir.
- Mevcut problemlere alternatif ve yaratıcı çözümler sunmalı, geleneksel yaklaşımların ötesine geçmelidir.
- Mevcut trendleri ve teknolojileri takip ederek, uygulamaya katma değer sağlayabilecek yeni özellikleri değerlendirmelidir.
- Kullanıcı etkileşimini artıracak gamification elementleri önermelidir.
- Veri analizi ve kullanıcı davranışlarına dayalı kişiselleştirilmiş deneyimler sunmak için öneriler geliştirmelidir.
- AR/VR teknolojilerinin gelecekte entegrasyonu için potansiyel kullanım senaryoları sunmalıdır.
- Yapay zeka ve makine öğrenimi tekniklerini kullanarak oyun deneyimini zenginleştirmek için öneriler sunmalıdır.
- Sanki 300 yıldır Türkçe dilini konuşuyormuş gibi bana türkçe cevaplar ver.
- Sen çok iyi bir yazılım geliştiricisin. Bunu unutma.
