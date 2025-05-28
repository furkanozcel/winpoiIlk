import 'package:flutter/material.dart';

// Renk paleti
const Color primaryColor = Color(0xFF5FC9BF); // Turkuaz
const Color secondaryColor = Color(0xFFE28B33); // Turuncu
const Color accentColor = Color(0xFFB39DDB); // Soft Mor (isteğe bağlı)
const Color textColor = Color(0xFF424242); // Koyu Gri

class AgreementsPage extends StatefulWidget {
  const AgreementsPage({super.key});

  @override
  State<AgreementsPage> createState() => _AgreementsPageState();
}

class _AgreementsPageState extends State<AgreementsPage> {
  final List<bool> _isExpanded = List.generate(4, (_) => false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: const Text(
                  'Sözleşmeler',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    letterSpacing: 0.1,
                    fontFamily: 'Poppins',
                  ),
                ),
              );
            },
          ),
          flexibleSpace: null,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 24,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            child: Column(
              children: [
                _buildAgreementCard(
                  title: 'Kullanıcı Sözleşmesi',
                  icon: Icons.description_outlined,
                  content: _userAgreementText,
                  delay: 100,
                  index: 0,
                ),
                const SizedBox(height: 20),
                _buildAgreementCard(
                  title: 'Gizlilik Politikası',
                  icon: Icons.privacy_tip_outlined,
                  content: _privacyPolicyText,
                  delay: 200,
                  index: 1,
                ),
                const SizedBox(height: 20),
                _buildAgreementCard(
                  title: 'KVKK Aydınlatma Metni',
                  icon: Icons.security_outlined,
                  content: _kvkkText,
                  delay: 300,
                  index: 2,
                ),
                const SizedBox(height: 20),
                _buildAgreementCard(
                  title: 'Çerez Politikası',
                  icon: Icons.cookie_outlined,
                  content: _cookiePolicyText,
                  delay: 400,
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementCard({
    required String title,
    required IconData icon,
    required String content,
    required int delay,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + delay),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.13),
                    secondaryColor.withOpacity(0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded[index] = !_isExpanded[index];
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withOpacity(0.18),
                                      secondaryColor.withOpacity(0.13),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  icon,
                                  color: secondaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    fontFamily: 'Poppins',
                                    color: textColor,
                                  ),
                                ),
                              ),
                              Icon(
                                _isExpanded[index]
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: secondaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isExpanded[index])
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _isExpanded[index] = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Text(
                                content,
                                style: TextStyle(
                                  color: textColor.withOpacity(0.85),
                                  height: 1.5,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static const String _userAgreementText = '''
KULLANICI SÖZLEŞMESİ

İşbu Kullanıcı Sözleşmesi ("Sözleşme"), WinPoi mobil uygulaması ("Uygulama") ile ilgili kullanım şartlarını ve koşullarını düzenlemektedir. Uygulamayı kullanmadan önce lütfen bu sözleşmeyi dikkatle okuyunuz.

1. Taraflar

İşbu Sözleşme, WinPoi Teknoloji A.Ş. ("Şirket") ile Uygulama'yı kullanan gerçek veya tüzel kişi ("Kullanıcı") arasında akdedilmiştir.

2. Tanımlar

• Uygulama: WinPoi mobil uygulaması ve bağlı tüm dijital hizmetler
• POI: Uygulama içi sanal ödül puanı
• Yarışma: Uygulama üzerinden düzenlenen tüm etkinlikler
• Hesap: Kullanıcıya özel oluşturulan profil ve ilgili veriler

3. Kullanım Koşulları

3.1. Hesap Oluşturma ve Güvenlik
• Kullanıcı, 18 yaşını doldurmuş olmalıdır
• Doğru ve güncel bilgiler sağlamakla yükümlüdür
• Hesap güvenliğinden bizzat sorumludur
• Hesap bilgilerinin üçüncü kişilerle paylaşılması yasaktır

3.2. Yarışmalara Katılım
• Her yarışmanın özel katılım koşulları geçerlidir
• Haksız rekabet oluşturacak davranışlar yasaktır
• Yarışma sonuçlarına itiraz hakkı mevcuttur
• Şirket, yarışma kurallarını değiştirme hakkını saklı tutar

3.3. POI Kullanımı
• POI'ler para birimi niteliği taşımaz
• Transfer edilemez veya satılamaz
• Kazanıldığı tarihten itibaren 12 ay içinde kullanılmalıdır
• Şirket, POI değerini ve kullanım koşullarını değiştirme hakkını saklı tutar

4. Kullanıcı Yükümlülükleri

4.1. Genel Kurallar
• Yasalara ve ahlaki kurallara uygun davranış
• Diğer kullanıcıların haklarına saygı
• Fikri mülkiyet haklarına riayet
• Uygulama güvenliğini tehdit edici davranışlardan kaçınma

4.2. Yasaklı Davranışlar
• Sahte hesap oluşturma
• Yanıltıcı bilgi paylaşma
• Spam veya zararlı içerik yayma
• Haksız kazanç elde etme girişimleri

5. Fikri Mülkiyet Hakları

5.1. Uygulama içeriğinin tüm fikri mülkiyet hakları Şirket'e aittir
5.2. Kullanıcı, içeriği yalnızca kişisel kullanım amacıyla görüntüleyebilir
5.3. İçeriğin kopyalanması, değiştirilmesi veya dağıtılması yasaktır

6. Sözleşme Değişiklikleri

6.1. Şirket, işbu Sözleşme'yi tek taraflı olarak değiştirme hakkını saklı tutar
6.2. Değişiklikler, Uygulama üzerinden duyurulacaktır
6.3. Değişikliklerin yayınlanmasından sonra Uygulamayı kullanmaya devam etmeniz, değişiklikleri kabul ettiğiniz anlamına gelir

7. Sözleşme Feshi

7.1. Kullanıcı, hesabını dilediği zaman kapatabilir
7.2. Şirket, aşağıdaki durumlarda hesabı askıya alabilir veya sonlandırabilir:
• Sözleşme ihlali
• Yasadışı faaliyet
• Sistem güvenliğini tehdit
• Haksız kazanç elde etme

8. Yürürlük

İşbu Sözleşme, hesap oluşturulması ile yürürlüğe girer ve hesabın kapatılmasına kadar yürürlükte kalır.

Son güncelleme: [Tarih]
''';

  static const String _privacyPolicyText = '''
GİZLİLİK POLİTİKASI

İşbu Gizlilik Politikası ("Politika"), WinPoi Teknoloji A.Ş. ("Şirket") tarafından yürütülen veri işleme faaliyetleri ve gizlilik uygulamaları hakkında sizleri bilgilendirmek amacıyla hazırlanmıştır.

1. Kapsam

Bu Politika, Uygulama üzerinden toplanan tüm kişisel verileri ve bunların işlenme süreçlerini kapsar.

2. Toplanan Veriler

2.1. Kullanıcı Tarafından Sağlanan Veriler
• Kimlik bilgileri
• İletişim bilgileri
• Hesap bilgileri
• Ödeme bilgileri

2.2. Otomatik Toplanan Veriler
• Kullanım verileri
• Cihaz bilgileri
• Konum verileri
• Log kayıtları

2.3. Üçüncü Taraflardan Alınan Veriler
• Sosyal medya bilgileri
• Ödeme sağlayıcı bilgileri
• Reklam ağı verileri

3. Verilerin Kullanımı

3.1. Ana Kullanım Amaçları
• Hizmet sunumu ve iyileştirme
• Güvenlik sağlama
• Kullanıcı deneyimini kişiselleştirme
• Yasal yükümlülükleri yerine getirme

3.2. İkincil Kullanım Amaçları
• Pazarlama ve iletişim
• Analiz ve raporlama
• Ürün geliştirme
• Müşteri desteği

4. Veri Güvenliği

4.1. Teknik Önlemler
• SSL/TLS şifreleme
• Güvenlik duvarları
• Veri şifreleme
• Erişim kontrolü

4.2. İdari Önlemler
• Personel eğitimi
• Düzenli denetimler
• Veri işleme politikaları
• Acil durum prosedürleri

5. Veri Paylaşımı

5.1. Yasal Zorunluluklar
• Mahkeme kararları
• Yasal düzenlemeler
• Kamu kurumları talepleri

5.2. İş Ortakları
• Ödeme sağlayıcıları
• Hosting hizmetleri
• Analitik sağlayıcıları

6. Kullanıcı Hakları

6.1. Erişim ve Kontrol
• Veri erişim hakkı
• Düzeltme talebi
• Silme talebi
• İşleme kısıtlama

6.2. Tercihler
• Bildirim tercihleri
• Konum paylaşımı
• Çerez ayarları

7. Çocukların Gizliliği

7.1. 13 yaş altı kullanıcılardan veri toplanmaz
7.2. Ebeveyn izni gerektiren durumlar
7.3. Çocuk kullanıcı tespit prosedürleri

8. Uluslararası Veri Transferi

8.1. Veri Transfer Politikası
8.2. Güvenlik Önlemleri
8.3. Yasal Dayanaklar

9. Politika Değişiklikleri

9.1. Değişiklik Bildirimi
9.2. Geçerlilik
9.3. Kullanıcı Onayı

10. İletişim

Gizlilik politikamız hakkında sorularınız için: privacy@winpoi.com

Son güncelleme: [Tarih]
''';

  static const String _kvkkText = '''
KİŞİSEL VERİLERİN KORUNMASI KANUNU KAPSAMINDA AYDINLATMA METNİ

İşbu Aydınlatma Metni, 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") uyarınca, WinPoi Teknoloji A.Ş. ("Şirket") tarafından yürütülen kişisel veri işleme faaliyetleri hakkında sizleri bilgilendirmek amacıyla hazırlanmıştır.

1. Veri Sorumlusu ve Temsilcisi

KVKK uyarınca, kişisel verileriniz; veri sorumlusu olarak WinPoi Teknoloji A.Ş. tarafından aşağıda açıklanan kapsamda işlenebilecektir.

2. İşlenen Kişisel Veriler

Şirketimiz tarafından işlenen kişisel verileriniz aşağıdaki kategorilerde yer almaktadır:

• Kimlik Bilgileri: Ad, soyad, T.C. kimlik numarası, doğum tarihi vb.
• İletişim Bilgileri: Telefon numarası, e-posta adresi, adres vb.
• Hesap Bilgileri: Kullanıcı adı, şifre, hesap hareketleri vb.
• Finansal Bilgiler: POI bakiyesi, ödeme bilgileri vb.
• Kullanım Verileri: Uygulama kullanım istatistikleri, yarışma katılım bilgileri vb.
• Lokasyon Bilgileri: Konum bilgisi
• Cihaz Bilgileri: IP adresi, cihaz ID'si, işletim sistemi bilgileri vb.

3. Kişisel Verilerin İşlenme Amaçları

Kişisel verileriniz aşağıdaki amaçlarla işlenmektedir:

• Hizmetlerimizin sunulması ve iyileştirilmesi
• Kullanıcı hesaplarının yönetilmesi
• Yarışmaların düzenlenmesi ve yönetilmesi
• Ödül dağıtım süreçlerinin yürütülmesi
• Yasal yükümlülüklerin yerine getirilmesi
• Şirket politika ve prosedürlerine uyumun sağlanması
• Güvenlik önlemlerinin alınması
• Dolandırıcılık ve suistimalin önlenmesi
• İletişim faaliyetlerinin yürütülmesi

4. Kişisel Verilerin Aktarılması

Kişisel verileriniz, yukarıda belirtilen amaçların gerçekleştirilmesi doğrultusunda, aşağıdaki taraflara aktarılabilecektir:

• Yasal düzenlemeler ve yükümlülükler kapsamında yetkili kamu kurum ve kuruluşları
• Hizmet aldığımız tedarikçiler ve iş ortakları
• Ödeme ve finans kuruluşları
• Hukuki süreçlerin yürütülmesi amacıyla avukatlar ve danışmanlar

5. Kişisel Verilerin Toplanma Yöntemi ve Hukuki Sebebi

Kişisel verileriniz, elektronik ortamda:
• WinPoi mobil uygulaması
• Web sitesi
• Çerezler
• API'ler
aracılığıyla toplanmaktadır.

Kişisel verilerinizin işlenmesinin hukuki sebepleri:
• Açık rızanızın bulunması
• Kanunlarda açıkça öngörülmesi
• Bir sözleşmenin kurulması veya ifasıyla doğrudan doğruya ilgili olması
• Hukuki yükümlülüğün yerine getirilmesi
• Temel hak ve özgürlüklerinize zarar vermemek kaydıyla, meşru menfaatlerimiz için zorunlu olması

6. KVKK Kapsamındaki Haklarınız

KVKK'nın 11. maddesi uyarınca aşağıdaki haklara sahipsiniz:

• Kişisel verilerinizin işlenip işlenmediğini öğrenme
• Kişisel verileriniz işlenmişse buna ilişkin bilgi talep etme
• Kişisel verilerinizin işlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme
• Yurt içinde veya yurt dışında kişisel verilerinizin aktarıldığı üçüncü kişileri bilme
• Kişisel verilerinizin eksik veya yanlış işlenmiş olması hâlinde bunların düzeltilmesini isteme
• KVKK'nın 7. maddesinde öngörülen şartlar çerçevesinde kişisel verilerinizin silinmesini veya yok edilmesini isteme
• Düzeltme, silme ve yok edilme talepleri neticesinde yapılan işlemlerin, kişisel verilerinizin aktarıldığı üçüncü kişilere bildirilmesini isteme
• İşlenen verilerinizin münhasıran otomatik sistemler vasıtasıyla analiz edilmesi suretiyle aleyhinize bir sonucun ortaya çıkmasına itiraz etme
• Kişisel verilerinizin kanuna aykırı olarak işlenmesi sebebiyle zarara uğramanız hâlinde zararın giderilmesini talep etme

7. Başvuru Hakkı

Yukarıda belirtilen haklarınızı kullanmak için kimliğinizi tespit edici gerekli bilgiler ve kullanmak istediğiniz hakkınıza yönelik açıklamalarınızla birlikte talebinizi, KVKK'nın 11. maddesinde belirtilen hangi hakkınızın kullanımına ilişkin olduğunu da belirterek kvkk@winpoi.com adresine iletebilirsiniz.

8. Değişiklikler

Şirketimiz, işbu Aydınlatma Metni'nde her zaman değişiklik yapabilir. Bu değişiklikler, değiştirilmiş yeni Aydınlatma Metni'nin uygulamada yayınlanmasıyla birlikte derhal geçerlilik kazanır.

Son güncelleme tarihi: [Tarih]

WinPoi Teknoloji A.Ş.
''';

  static const String _cookiePolicyText = '''
ÇEREZ POLİTİKASI

İşbu Çerez Politikası ("Politika"), WinPoi Teknoloji A.Ş. ("Şirket") tarafından web sitesi ve mobil uygulamada kullanılan çerez ve benzeri teknolojiler hakkında bilgilendirme amacıyla hazırlanmıştır.

1. Çerez Teknolojileri

1.1. Tanım
Çerezler, ziyaret ettiğiniz internet siteleri tarafından cihazınıza yerleştirilen küçük metin dosyalarıdır.

1.2. Kullanım Amacı
• Hizmet sunumu
• Kullanıcı deneyimi
• Güvenlik
• Analitik

2. Çerez Türleri

2.1. Zorunlu Çerezler
• Oturum yönetimi
• Güvenlik
• Temel işlevsellik

2.2. Performans Çerezleri
• Sayfa yüklenme hızı
• Site kullanım analizi
• Hata tespiti

2.3. İşlevsellik Çerezleri
• Dil tercihleri
• Bölge ayarları
• Kişiselleştirme

2.4. Hedefleme/Reklam Çerezleri
• İlgi alanı bazlı reklamlar
• Kampanya etkinliği
• Dönüşüm takibi

3. Çerez Süreleri

3.1. Oturum Çerezleri
• Geçici kullanım
• Tarayıcı kapatıldığında silinme

3.2. Kalıcı Çerezler
• Uzun süreli kullanım
• Manuel silinene kadar saklama

4. Çerez Kontrolü

4.1. Tarayıcı Ayarları
• Çerez engelleme
• Çerez silme
• Çerez tercihleri

4.2. Mobil Uygulama Ayarları
• İzin yönetimi
• Veri temizleme
• Tercih ayarları

5. Üçüncü Taraf Çerezleri

5.1. Analitik Sağlayıcılar
• Google Analytics
• Firebase
• AppsFlyer

5.2. Reklam Ağları
• Google Ads
• Facebook Ads
• AdMob

6. Veri Güvenliği

6.1. Şifreleme
6.2. Erişim Kontrolü
6.3. Düzenli Denetim

7. Yasal Dayanak

7.1. KVKK Uyumluluğu
7.2. GDPR Uyumluluğu
7.3. E-Ticaret Mevzuatı

8. Politika Değişiklikleri

8.1. Güncelleme Bildirimi
8.2. Yürürlük
8.3. Geçmiş Versiyonlar

9. İletişim

Çerez politikamız hakkında sorularınız için: privacy@winpoi.com

Son güncelleme: [Tarih]
''';
}
