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

        transaction.set(participationRef, {
          'competitionId': competition.id,
          'competitionTitle': competition.title,
          'remainingAttempts': 2,
          'joinedAt': FieldValue.serverTimestamp(),
          'endTime': competitionEndTime,
          'lastPlayedAt': FieldValue.serverTimestamp(),
          'poiCost': poiCost,
          'status': 'active',
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Oyun başlatılıyor... Kalan hak: 2 (${competition.poiCost} POI düşüldü)'),
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
          const SizedBox(width: 8),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8156A0),
                      Color(0xFF9B6BB7),
                      Color(0xFF8156A0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8156A0).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wallet,
                      color: Colors.white.withOpacity(0.95),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${userProvider.userData?['poiBalance'] ?? 0}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'POI',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
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
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Ödül resmi
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24),
                                      ),
                                      child: Container(
                                        height: 170,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xFFF7F7F7),
                                              Color(0xFFEDEDED),
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              Colors.white.withOpacity(0.25),
                                              BlendMode.lighten,
                                            ),
                                            child: Image.network(
                                              competition.image,
                                              fit: BoxFit.contain,
                                              height: 150,
                                              width: double.infinity,
                                              alignment: Alignment.center,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                    Icons.broken_image,
                                                    size: 60,
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          // Süre
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE6F7F6),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.timer,
                                                    size: 18,
                                                    color: Color(0xFF5FC9BF)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _getCountdownText(
                                                      competition.endTime),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF5FC9BF),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Ödül adı
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF3E6),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.card_giftcard,
                                                    size: 18,
                                                    color: Color(0xFFE28B33)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  competition.title,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFFE28B33),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          // İncele butonu
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CompetitionDetailPage(
                                                          competition:
                                                              competition),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 0),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text(
                                              'İncele',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF5FC9BF),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 16),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 44,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF5FC9BF),
                                                Color(0xFFE28B33)
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _joinCompetition(competition),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              padding: EdgeInsets.zero,
                                              elevation: 0,
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
}

class CompetitionDetailPage extends StatelessWidget {
  final Competition competition;

  const CompetitionDetailPage({
    super.key,
    required this.competition,
  });

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
