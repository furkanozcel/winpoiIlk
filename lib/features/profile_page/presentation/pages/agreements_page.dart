import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF5FC9BF); // Turkuaz
const Color secondaryColor = Color(0xFFE28B33); // Turuncu
const Color accentColor = Color(0xFFB39DDB); // Soft Mor (isteğe bağlı)
const Color textColor = Color(0xFF424242); // Koyu Gri

class AgreementsPage extends StatefulWidget {
  const AgreementsPage({super.key});

  @override
  State<AgreementsPage> createState() => _AgreementsPageState();
}

class _AgreementsPageState extends State<AgreementsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _contentAnimation;
  int? _expandedIndex;

  final List<Map<String, dynamic>> _agreements = [
    {
      'title': 'Kullanıcı Sözleşmesi',
      'icon': Icons.description_outlined,
      'content': '''
1. Genel Hükümler
   • WinPoi uygulamasını kullanarak bu sözleşmeyi kabul etmiş sayılırsınız.
   • Uygulama içeriğindeki tüm materyaller WinPoi'ye aittir.
   • Kullanıcılar uygulama içeriğini kopyalayamaz, dağıtamaz veya ticari amaçla kullanamaz.
   • WinPoi, uygulama içeriğinde değişiklik yapma hakkını saklı tutar.

2. Kullanıcı Sorumlulukları
   • Kullanıcılar doğru ve güncel bilgilerini sağlamakla yükümlüdür.
   • Hesap güvenliğinden kullanıcı sorumludur.
   • Uygulama içinde yasadışı veya uygunsuz içerik paylaşımı yasaktır.
   • Kullanıcılar diğer kullanıcılara saygılı davranmakla yükümlüdür.
   • Spam, zararlı içerik veya yanıltıcı bilgi paylaşımı yasaktır.

3. Ödül ve Puan Sistemi
   • Kazanılan puanlar ve ödüller WinPoi tarafından belirlenen kurallara tabidir.
   • Puanlar ve ödüller başkalarına devredilemez.
   • WinPoi, puan ve ödül sisteminde değişiklik yapma hakkını saklı tutar.
   • Ödüller belirtilen süre içinde kullanılmalıdır.
   • Hileli yollarla puan kazanımı tespit edilirse hesap kapatılabilir.

4. Hesap Yönetimi
   • Kullanıcılar tek bir hesap açabilir.
   • Hesap bilgilerinin güncel tutulması kullanıcının sorumluluğundadır.
   • Uzun süre kullanılmayan hesaplar pasif duruma alınabilir.
   • Hesap kapatma talepleri 30 gün içinde işleme alınır.

5. Hizmet Kullanımı
   • Uygulama hizmetleri kesintisiz sunulmaya çalışılır.
   • Bakım ve güncelleme durumlarında hizmet kesintisi olabilir.
   • Kullanıcılar hizmet kalitesini etkileyecek işlemlerden kaçınmalıdır.
   • Teknik sorunlar için destek ekibiyle iletişime geçilmelidir.
''',
    },
    {
      'title': 'Gizlilik Politikası',
      'icon': Icons.privacy_tip_outlined,
      'content': '''
1. Veri Toplama
   • Kişisel bilgileriniz (ad, e-posta, telefon) güvenli şekilde saklanır.
   • Oyun istatistikleri ve puanlarınız kaydedilir.
   • Konum bilgisi sadece gerekli hizmetler için kullanılır.
   • Cihaz bilgileri (model, işletim sistemi) teknik destek için saklanır.
   • Kullanım istatistikleri hizmet geliştirme için toplanır.

2. Veri Kullanımı
   • Bilgileriniz hizmet kalitesini artırmak için kullanılır.
   • Üçüncü taraflarla paylaşılmaz.
   • İstatistiksel analizler için anonim olarak kullanılabilir.
   • Pazarlama faaliyetleri için izniniz olmadan kullanılmaz.
   • Kişiselleştirilmiş öneriler sunmak için kullanılır.

3. Veri Güvenliği
   • Verileriniz şifrelenerek saklanır.
   • Düzenli güvenlik güncellemeleri yapılır.
   • Güvenlik ihlali durumunda siz bilgilendirilirsiniz.
   • Veri erişimi sıkı kontrol altındadır.
   • Yedekleme sistemleri düzenli olarak test edilir.

4. Çerezler ve Takip
   • Oturum yönetimi için gerekli çerezler kullanılır.
   • Kullanıcı tercihleri yerel olarak saklanır.
   • Üçüncü taraf çerezleri kullanılmaz.
   • Çerez tercihleri kullanıcı tarafından değiştirilebilir.
   • Takip sistemleri şeffaf şekilde kullanılır.

5. Veri Saklama Süresi
   • Kişisel veriler hesap aktif olduğu sürece saklanır.
   • Hesap kapatıldığında veriler 6 ay içinde silinir.
   • Yasal yükümlülükler için gerekli veriler saklanır.
   • İstatistiksel veriler anonim olarak saklanır.
   • Veri silme talepleri 30 gün içinde işleme alınır.
''',
    },
    {
      'title': 'KVKK',
      'icon': Icons.security_outlined,
      'content': '''
1. Veri Sorumlusu
   • WinPoi, kişisel verilerinizin işlenmesinden sorumludur.
   • Verileriniz 6698 sayılı KVKK kapsamında korunmaktadır.
   • Veri işleme faaliyetleri şeffaf şekilde yürütülür.
   • Veri sorumlusu iletişim bilgileri her zaman güncel tutulur.
   • Veri işleme politikaları düzenli olarak gözden geçirilir.

2. Veri İşleme Amaçları
   • Hizmet sunumu ve geliştirme
   • Müşteri ilişkileri yönetimi
   • Yasal yükümlülüklerin yerine getirilmesi
   • Güvenlik ve dolandırıcılık önleme
   • Kullanıcı deneyimini iyileştirme

3. Haklarınız
   • Verilerinize erişim
   • Düzeltme talep etme
   • Silme veya yok etme talep etme
   • İşlemeyi sınırlama talep etme
   • Veri taşınabilirliği talep etme
   • İşlemeye itiraz etme
   • Otomatik kararlara itiraz etme

4. Veri İşleme Şartları
   • Açık rıza
   • Yasal yükümlülük
   • Sözleşme ilişkisi
   • Meşru menfaat
   • Kamu sağlığı
   • Bilimsel araştırma

5. Veri Güvenliği Önlemleri
   • Teknik önlemler
   • İdari önlemler
   • Fiziksel güvenlik
   • Erişim kontrolü
   • Düzenli denetim
''',
    },
    {
      'title': 'Telif Hakkı',
      'icon': Icons.copyright_outlined,
      'content': '''
1. Telif Hakkı Sahipliği
   • WinPoi uygulaması ve içeriği telif hakkı yasaları ile korunmaktadır.
   • Tüm hakları WinPoi'ye aittir.
   • Uygulama içeriği özgün ve benzersizdir.
   • Tasarım ve kodlar özel olarak geliştirilmiştir.
   • Marka ve logolar tescillidir.

2. İçerik Kullanımı
   • Uygulama içeriği kişisel kullanım için sunulmuştur.
   • İçeriğin kopyalanması, dağıtılması veya ticari kullanımı yasaktır.
   • Ekran görüntüleri kişisel kullanım için alınabilir.
   • İçerik paylaşımı için yazılı izin gereklidir.
   • Kullanıcı tarafından oluşturulan içerikler kullanıcıya aittir.

3. İhlal Durumları
   • Telif hakkı ihlali durumunda yasal işlem başlatılabilir.
   • İhlal tespitinde hesap kapatılabilir.
   • Tazminat talepleri söz konusu olabilir.
   • İhlal bildirimleri 24 saat içinde değerlendirilir.
   • İhlal durumunda içerik kaldırılır.

4. Lisans ve İzinler
   • Uygulama kullanımı için lisans gereklidir.
   • Lisans kişisel ve devredilemezdir.
   • Özel kullanım için ek izinler gerekebilir.
   • Lisans ihlali durumunda kullanım hakkı sonlandırılır.
   • Lisans şartları değiştirilebilir.

5. Kullanıcı İçeriği
   • Kullanıcılar tarafından paylaşılan içeriklerden kullanıcı sorumludur.
   • İçerik paylaşımı için telif hakkı kontrolü yapılmalıdır.
   • Uygunsuz içerik paylaşımı yasaktır.
   • İçerik şikayetleri değerlendirilir.
   • İçerik kaldırma talepleri incelenir.
''',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Sözleşmeler',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4ECDC4).withOpacity(0.1),
                        const Color(0xFF845EC2).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: primaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sözleşmeler ve Politikalar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'WinPoi uygulamasını kullanırken uymanız gereken kurallar ve politikalar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Agreements List
              FadeTransition(
                opacity: _contentAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_contentAnimation),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(_agreements.length, (index) {
                        return _buildExpandableCard(
                          title: _agreements[index]['title'],
                          icon: _agreements[index]['icon'],
                          content: _agreements[index]['content'],
                          index: index,
                        );
                      }),
                    ),
                  ),
                ),
              ),
              // Footer Section
              FadeTransition(
                opacity: _contentAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: secondaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Sözleşmeler ve politikalar düzenli olarak güncellenmektedir. En güncel versiyonları uygulama içerisinden takip edebilirsiniz.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Son güncelleme: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required String content,
    required int index,
  }) {
    final isExpanded = _expandedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? null : index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4ECDC4).withOpacity(0.15), // Turkuaz
              const Color(0xFF845EC2).withOpacity(0.10), // Mor
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: secondaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? secondaryColor : Colors.grey[400],
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[50]!,
                      Colors.grey[100]!.withOpacity(0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
