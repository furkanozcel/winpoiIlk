import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;
import 'package:winpoi/core/providers/firestore_provider.dart';
import 'package:winpoi/core/providers/user_provider.dart';
import 'package:winpoi/core/services/notification_service.dart';
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

    _fadeController.forward();
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

      // Yarışmaya katılım kaydı oluştur
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('participations')
          .add({
        'competitionId': competition.id,
        'competitionTitle': competition.title,
        'remainingAttempts': 2,
        'joinedAt': FieldValue.serverTimestamp(),
        'endTime': competition.endTime,
        'lastPlayedAt': FieldValue.serverTimestamp(),
      });

      // Yarışmanın katılımcı sayısını artır
      await FirebaseFirestore.instance
          .collection('competitions')
          .doc(competition.id)
          .update({
        'participantCount': FieldValue.increment(1),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oyun başlatılıyor... Kalan hak: 2'),
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
        elevation: 0,
        backgroundColor: const Color(0xFF5FC9BF),
        title: const Row(
          children: [
            Text(
              'Win',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              'Poi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
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
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 8),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF8156A0),
              indicatorWeight: 3,
              labelColor: const Color(0xFF8156A0),
              unselectedLabelColor: const Color(0xFF8156A0).withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.5,
                fontFamily: 'Poppins',
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                letterSpacing: 0.5,
                fontFamily: 'Poppins',
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Yarışmalar'),
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

                        return AnimatedSize(
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
                                      borderRadius: const BorderRadius.vertical(
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
                                                    color:
                                                        const Color(0xFF5FC9BF),
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
                                            frameBuilder: (context, child,
                                                frame, wasSynchronouslyLoaded) {
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF5FC9BF)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFF5FC9BF)
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.timer,
                                                  size: 14,
                                                  color: Color(0xFF5FC9BF),
                                                ),
                                                const SizedBox(width: 4),
                                                DefaultTextStyle(
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF5FC9BF),
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
                                                color: const Color(0xFFE28B33)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color(0xFFE28B33)
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.card_giftcard_rounded,
                                                    size: 16,
                                                    color: Color(0xFFE28B33),
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
                                                            Color(0xFFE28B33),
                                                        letterSpacing: 0.3,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF5FC9BF)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: TextButton.icon(
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
                                                            Color(0xFF5FC9BF),
                                                            Color(0xFFE28B33),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(24),
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
                                                              const Icon(
                                                                Icons
                                                                    .card_giftcard_rounded,
                                                                size: 28,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              const SizedBox(
                                                                  width: 12),
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
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 20),

                                                          // Katılım Puanı
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 20,
                                                              vertical: 16,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                      0xFF8156A0)
                                                                  .withOpacity(
                                                                      0.3),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              border:
                                                                  Border.all(
                                                                color: const Color(
                                                                        0xFF8156A0)
                                                                    .withOpacity(
                                                                        0.5),
                                                              ),
                                                            ),
                                                            child: Wrap(
                                                              alignment:
                                                                  WrapAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  WrapCrossAlignment
                                                                      .center,
                                                              spacing: 12,
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .stars_rounded,
                                                                  size: 28,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                const Text(
                                                                  'Katılım Puanı:',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '100 Poi',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.95),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 20),

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
                                                                        0.15),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.3),
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
                                                                    color: Colors
                                                                        .white,
                                                                    height: 1.6,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 20),

                                                          // Oyna Butonu
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.1),
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
                                                                        .white,
                                                                shadowColor: Colors
                                                                    .transparent,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            18),
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
                                                                  color: Color(
                                                                      0xFFE28B33),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16),

                                                          // Bilgi Notu
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .info_outline_rounded,
                                                                size: 16,
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.7),
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Expanded(
                                                                child: Text(
                                                                  'Her yarışmada 3 hakkınız bulunur. En iyi süreniz sıralamada yer alır.',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.7),
                                                                    height: 1.4,
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
                                              },
                                              icon: const Icon(
                                                Icons.search_rounded,
                                                size: 18,
                                                color: Color(0xFF5FC9BF),
                                              ),
                                              label: const Text(
                                                'İncele',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF5FC9BF),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Oyna butonu
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Color(0xFF5FC9BF),
                                              Color(0xFFE28B33),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF5FC9BF)
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _joinCompetition(competition),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Oyna',
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
                        'Her yarışmada 3 hakkınız bulunur.',
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
