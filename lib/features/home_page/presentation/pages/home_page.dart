import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;
import 'package:winpoi/core/providers/firestore_provider.dart';
import 'package:winpoi/core/providers/user_provider.dart';
import 'package:winpoi/features/home_page/data/models/competition.dart';
import 'package:winpoi/features/notifications/presentation/pages/notifications_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:winpoi/features/home_page/presentation/pages/my_games_page.dart';
import 'package:winpoi/features/home_page/presentation/widgets/countdown_timer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  int? expandedIndex;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  Animation<double>? _fadeAnimation;
  late Timer _cleanupTimer;
  bool _isUsernameDialogShown = false;
  late AnimationController _listAnimationController;
  late Animation<double> _listSlideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupAnimations();
    _setupCleanupTimer();
    // Build işlemi tamamlandıktan sonra username kontrolü yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowUsernameDialog();
    });
  }

  Future<void> _checkAndShowUsernameDialog() async {
    final authProvider =
        Provider.of<app_provider.AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData();

      // Kullanıcı dokümanı yoksa veya username alanı yoksa veya boşsa
      if (!userProvider.isProfileComplete) {
        if (!_isUsernameDialogShown) {
          _isUsernameDialogShown = true;
          _showUsernameDialog();
        }
      }
    }
  }

  Future<void> _showUsernameDialog() async {
    final usernameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isUsernameValid = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Kullanıcı Adı Oluştur'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Uygulamayı kullanmaya başlamak için bir kullanıcı adı oluşturmalısınız.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      isUsernameValid = true;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kullanıcı adı boş bırakılamaz';
                    }
                    if (value.trim().length < 3) {
                      return 'Kullanıcı adı en az 3 karakter olmalıdır';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                      return 'Kullanıcı adı sadece harf, rakam ve alt çizgi içerebilir';
                    }
                    if (!isUsernameValid) {
                      return 'Bu kullanıcı adı zaten kullanılıyor';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final username = usernameController.text.trim();
                  final authProvider = Provider.of<app_provider.AuthProvider>(
                      context,
                      listen: false);
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);

                  if (authProvider.currentUser != null) {
                    try {
                      // UserProvider üzerinden güncelle
                      await userProvider.updateUserData({
                        'username': username,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Kullanıcı adı başarıyla oluşturuldu'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hata oluştu: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                }
              },
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _listSlideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutQuart,
    ));

    _fadeController.forward();
    _listAnimationController.forward();
  }

  void _setupCleanupTimer() {
    // Her 5 dakikada bir biten yarışmaları kontrol et ve sil
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      Provider.of<FirestoreProvider>(context, listen: false)
          .deleteExpiredCompetitions();
    });
  }

  void _scrollToSelectedContent(int index) {
    if (!_scrollController.hasClients) return;

    // Mevcut scroll pozisyonunu al
    final currentPosition = _scrollController.offset;

    // Kartın yüksekliğini ve ekstra boşluk için değer ekle
    final targetScroll = currentPosition + 200.0;

    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _joinCompetition(Competition competition) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Kullanıcının POI bakiyesini kontrol et
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final currentPoi = userDoc.data()?['poiBalance'] ?? 0;
      final poiCost = competition.poiCost;

      // Yetersiz POI durumunda farklı dialog göster
      if (currentPoi < poiCost) {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFD4F4F1), // Soft turkuaz
                      Color(0xFFE6D4F4), // Soft mor
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ECDC4).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // İkon ve Başlık
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Color(0xFF2D3436),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Başlık
                    const Text(
                      'POI\'yi veren düdüğü çalar!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Açıklama
                    Text(
                      'Bu oyuna katılmak için ${poiCost} POI gerekiyor.\n\nCüzdan Durumu: $currentPoi POI',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2D3436),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Mağaza Butonu
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4ECDC4), // Turkuaz
                            Color(0xFF845EC2), // Mor
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4ECDC4).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Mağaza sayfasına yönlendir
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Mağaza',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return;
      }

      // Normal onay kutusunu göster
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFD4F4F1), // Soft turkuaz
                  Color(0xFFE6D4F4), // Soft mor
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // İkon ve Başlık
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline_rounded,
                    color: Color(0xFF2D3436),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                // Başlık
                const Text(
                  'Oyunu Başlat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Açıklama
                Text(
                  'Bu oyuna katılmak için ${competition.poiCost} POI bakiyenizden düşülecektir.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2D3436),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Butonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // İptal Butonu
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Onay Butonu
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4ECDC4), // Turkuaz
                            Color(0xFF845EC2), // Mor
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4ECDC4).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kullanıcı oturumu bulunamadı'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          // Kullanıcının POI bakiyesini kontrol et
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();

                          final currentPoi = userDoc.data()?['poiBalance'] ?? 0;
                          final poiCost = competition.poiCost;

                          // Yetersiz POI durumunda farklı dialog göster
                          if (currentPoi < poiCost) {
                            if (context.mounted) {
                              await showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFFD4F4F1), // Soft turkuaz
                                          Color(0xFFE6D4F4), // Soft mor
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4ECDC4)
                                              .withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Kapatma butonu
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              color: Color(0xFF2D3436),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.warning_rounded,
                                            color: Color(0xFF2D3436),
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'POI\'yi veren düdüğü çalar!',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2D3436),
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Bu oyuna katılmak için ${poiCost} POI gerekiyor.\n\nCüzdan Durumu: $currentPoi POI',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFF2D3436),
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF4ECDC4), // Turkuaz
                                                Color(0xFF845EC2), // Mor
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF4ECDC4)
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              // TODO: Mağaza sayfasına yönlendir
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 32,
                                                vertical: 16,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Mağaza',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            return;
                          }

                          // Normal onay kutusunu göster
                          final bool? confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFD4F4F1), // Soft turkuaz
                                      Color(0xFFE6D4F4), // Soft mor
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4ECDC4)
                                          .withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Kapatma butonu
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          color: Color(0xFF2D3436),
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.play_circle_outline_rounded,
                                        color: Color(0xFF2D3436),
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Oyunu Başlat',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2D3436),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Bu oyuna katılmak için ${competition.poiCost} POI bakiyenizden düşülecektir.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF2D3436),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF4ECDC4), // Turkuaz
                                            Color(0xFF845EC2), // Mor
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF4ECDC4)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Oyna',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          if (confirmed == true) {
                            _joinCompetition(competition);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Oyna',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Kullanıcı onaylamadıysa işlemi iptal et
      if (confirmed != true) return;

      // Yarışmanın aktif olup olmadığını kontrol et
      if (!competition.isActive) {
        throw Exception('Bu yarışma süresi dolmuş');
      }

      // Transaction ile atomik işlem yap
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Kullanıcı dokümanını oku
        final userDoc = await transaction
            .get(FirebaseFirestore.instance.collection('users').doc(user.uid));

        if (!userDoc.exists) {
          throw Exception('Kullanıcı bilgileri bulunamadı');
        }

        // Kullanıcının aynı yarışmaya daha önce katılıp katılmadığını kontrol et
        final existingParticipationQuery = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('participations')
            .where('competitionId', isEqualTo: competition.id)
            .limit(1);

        final existingParticipation = await existingParticipationQuery.get();
        if (existingParticipation.docs.isNotEmpty) {
          throw Exception('Bu yarışmaya zaten katıldınız');
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        final currentBalance = userData['poiBalance'] ?? 0;
        final poiCost = competition.poiCost;

        if (currentBalance < poiCost) {
          throw Exception(
              'Yetersiz POI bakiyesi. Gerekli: $poiCost POI, Mevcut: $currentBalance POI');
        }

        // Yarışma dokümanını kontrol et
        final competitionDoc = await transaction.get(FirebaseFirestore.instance
            .collection('competitions')
            .doc(competition.id));

        if (!competitionDoc.exists) {
          throw Exception('Yarışma bulunamadı');
        }

        final competitionData = competitionDoc.data() as Map<String, dynamic>;
        final competitionEndTime =
            (competitionData['endTime'] as Timestamp).toDate();

        if (DateTime.now().isAfter(competitionEndTime)) {
          throw Exception('Bu yarışma süresi dolmuş');
        }

        // POI bakiyesini düş
        transaction.update(
            FirebaseFirestore.instance.collection('users').doc(user.uid),
            {'poiBalance': FieldValue.increment(-poiCost)});

        // Yarışmaya katılım kaydı oluştur
        final participationRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('participations')
            .doc();

        // Hak sayısını belirle (katılım anındaki kalan süreye göre)
        final now = DateTime.now();
        final duration = competitionEndTime.difference(now);
        final int totalAttempts = duration.inHours >= 10 ? 3 : 2;

        transaction.set(participationRef, {
          'competitionId': competition.id,
          'competitionTitle': competition.title,
          'remainingAttempts': totalAttempts,
          'joinedAt': FieldValue.serverTimestamp(),
          'endTime': competitionEndTime,
          'lastPlayedAt': FieldValue.serverTimestamp(),
          'poiCost': poiCost,
          'status': 'active',
        });
        // İlk hak otomatik olarak kullanılsın
        transaction.update(participationRef, {
          'remainingAttempts': totalAttempts - 1,
          'lastPlayedAt': FieldValue.serverTimestamp(),
        });

        // Yarışmanın katılımcı sayısını artır
        transaction.update(
            FirebaseFirestore.instance
                .collection('competitions')
                .doc(competition.id),
            {'participantCount': FieldValue.increment(1)});

        // Toplam oyun sayısını artır
        transaction.update(
            FirebaseFirestore.instance.collection('users').doc(user.uid),
            {'totalGames': FieldValue.increment(1)});
      });

      // UserProvider'ı güncelle
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.loadUserData();

        final kalanHak =
            competition.endTime.difference(DateTime.now()).inHours >= 10
                ? 2
                : 1;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Oyun başlatılıyor... Kalan hak: $kalanHak (${competition.poiCost} POI düşüldü)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreProvider = Provider.of<FirestoreProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF845EC2), // Mor
                        Color(0xFF9B6BB7), // Orta ton mor
                        Color(0xFF845EC2), // Mor
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF845EC2).withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wallet,
                        color: Colors.white.withOpacity(0.9),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${userProvider.userData?['poiBalance'] ?? 0}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'POI',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Spacer(),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF4ECDC4), // Turkuaz
                  Color(0xFF845EC2), // Mor
                ],
              ).createShader(bounds),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Win',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Poi',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Color(0xFF845EC2)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF845EC2),
              indicatorWeight: 3,
              labelColor: const Color(0xFF845EC2),
              unselectedLabelColor: const Color(0xFF845EC2).withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
                fontFamily: 'Poppins',
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                letterSpacing: 0.5,
                fontFamily: 'Poppins',
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Oyunlar'),
                Tab(text: 'Oyunlarım'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Yarışmalar sekmesi
                StreamBuilder<List<Competition>>(
                  stream: firestoreProvider.getActiveCompetitions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Hata: ${snapshot.error}'),
                      );
                    }

                    final competitions = snapshot.data ?? [];

                    if (competitions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 120,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Şu anda aktif yarışma bulunmuyor',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Yarışmaları göster
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: competitions.length,
                      itemBuilder: (context, index) {
                        final competition = competitions[index];
                        final isExpanded = index == expandedIndex;

                        return AnimatedBuilder(
                          animation: _listAnimationController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                  0,
                                  _listSlideAnimation.value *
                                      (1 - (index / competitions.length))),
                              child: child,
                            );
                          },
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Yarışma resmi
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                        child: Container(
                                          color: Colors.white,
                                          child: AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: Image.network(
                                              competition.image,
                                              fit: BoxFit.contain,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Container(
                                                  color: Colors.white,
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                      color: const Color(
                                                          0xFF5FC9BF),
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.white,
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.error_outline,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                  ),
                                                );
                                              },
                                              frameBuilder: (context,
                                                  child,
                                                  frame,
                                                  wasSynchronouslyLoaded) {
                                                if (wasSynchronouslyLoaded)
                                                  return child;
                                                return AnimatedOpacity(
                                                  opacity:
                                                      frame != null ? 1.0 : 0.0,
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  curve: Curves.easeOut,
                                                  child: child,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Görsel yüklenirken veya hata durumunda gradient overlay
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.1),
                                                Colors.transparent,
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.1),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Yarışma bilgileri
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Geri sayım ve incele butonu
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(
                                                        0xFFD4F4F1), // Soft turkuaz
                                                    Color(
                                                        0xFFE6D4F4), // Soft mor
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  width: 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF4ECDC4)
                                                            .withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.timer,
                                                    size: 14,
                                                    color: Color(0xFF2D3436),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  DefaultTextStyle(
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF2D3436),
                                                    ),
                                                    child: CountdownTimer(
                                                      endTime:
                                                          competition.endTime,
                                                      isCompetitionEnded: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color(
                                                          0xFFD4F4F1), // Soft turkuaz
                                                      Color(
                                                          0xFFE6D4F4), // Soft mor
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xFF4ECDC4)
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .card_giftcard_rounded,
                                                      size: 16,
                                                      color: Color(0xFF2D3436),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        competition.title,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Color(0xFF2D3436),
                                                          letterSpacing: 0.3,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => Dialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24),
                                                    ),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                      constraints:
                                                          BoxConstraints(
                                                        minHeight:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.4,
                                                        maxHeight:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Color(
                                                                0xFFD4F4F1), // Soft turkuaz
                                                            Color(
                                                                0xFFE6D4F4), // Soft mor
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(
                                                                    0xFF4ECDC4)
                                                                .withOpacity(
                                                                    0.2),
                                                            blurRadius: 20,
                                                            offset:
                                                                const Offset(
                                                                    0, 10),
                                                          ),
                                                        ],
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              24),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Başlık
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        12),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.3),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.5),
                                                                    width: 1,
                                                                  ),
                                                                ),
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .card_giftcard_rounded,
                                                                  size: 32,
                                                                  color: Color(
                                                                      0xFF2D3436),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 16),
                                                              Expanded(
                                                                child: Text(
                                                                  competition
                                                                      .title,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFF2D3436),
                                                                    letterSpacing:
                                                                        0.5,
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 24),
                                                          // Oynama Puanı
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.5),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                            0xFFE28B33)
                                                                        .withOpacity(
                                                                            0.2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .star_rounded,
                                                                    color: Color(
                                                                        0xFFE28B33),
                                                                    size: 24,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                                const Text(
                                                                  'Oynama Puanı:',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Color(
                                                                        0xFF2D3436),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 8),
                                                                Text(
                                                                  '${competition.poiCost ?? 100} POI',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        0xFFE28B33),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 24),
                                                          // Ürün Detayları
                                                          Flexible(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(20),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.3),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.5),
                                                                  width: 1,
                                                                ),
                                                              ),
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Text(
                                                                  competition
                                                                      .description,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color(
                                                                        0xFF2D3436),
                                                                    height: 1.6,
                                                                    letterSpacing:
                                                                        0.3,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 24),
                                                          // Oyna butonu
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  const LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                      0xFF4ECDC4), // Turkuaz
                                                                  Color(
                                                                      0xFF845EC2), // Mor
                                                                ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: const Color(
                                                                          0xFF4ECDC4)
                                                                      .withOpacity(
                                                                          0.3),
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 4),
                                                                ),
                                                              ],
                                                            ),
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                _joinCompetition(
                                                                    competition);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                shadowColor: Colors
                                                                    .transparent,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            16),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16),
                                                                ),
                                                              ),
                                                              child: const Text(
                                                                'Oyna',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16),
                                                          // Bilgi Notu
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.5),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                            0xFF4ECDC4)
                                                                        .withOpacity(
                                                                            0.2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .info_outline_rounded,
                                                                    size: 20,
                                                                    color: Color(
                                                                        0xFF4ECDC4),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                                Expanded(
                                                                  child: Text(
                                                                    'En iyi yaptığınız süre sıralamada yer alır.',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                      color: Color(
                                                                          0xFF2D3436),
                                                                      height:
                                                                          1.4,
                                                                      letterSpacing:
                                                                          0.2,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color(
                                                          0xFFD4F4F1), // Soft turkuaz
                                                      Color(
                                                          0xFFE6D4F4), // Soft mor
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xFF4ECDC4)
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.search_rounded,
                                                      size: 16,
                                                      color: Color(0xFF2D3436),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text(
                                                      'İncele',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF2D3436),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // Oyna butonu
                                        _buildPlayButton(competition),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                // Oyunlarım sekmesi
                const MyGamesPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    _cleanupTimer.cancel();
    _listAnimationController.dispose();
    super.dispose();
  }

  // Geri sayım widget'ını oluştur
  String _getCountdownText(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return 'Bitti';
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(difference.inHours);
    final minutes = twoDigits(difference.inMinutes.remainder(60));
    final seconds = twoDigits(difference.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }

  Widget _buildPlayButton(Competition competition) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4ECDC4), // Turkuaz
              Color(0xFF845EC2), // Mor
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4ECDC4).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _joinCompetition(competition),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
          child: const Text(
            'Oyna',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class CompetitionDetailPage extends StatelessWidget {
  final Competition competition;

  const CompetitionDetailPage({
    Key? key,
    required this.competition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5FC9BF),
        title: const Text(
          'Yarışma Detayları',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Yarışma resmi
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                competition.image,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    competition.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'En iyi yaptığınız süre sıralamada yer alır.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Yarışmaya katılma işlemi
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5FC9BF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Yarışmaya Katıl',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
