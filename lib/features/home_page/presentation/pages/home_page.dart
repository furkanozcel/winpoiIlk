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
      final authProvider =
          Provider.of<app_provider.AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final firestoreProvider =
          Provider.of<FirestoreProvider>(context, listen: false);

      // Yarışmaya katılım işlemini FirestoreProvider üzerinden yapalım
      await firestoreProvider.joinCompetition(competition);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Oyun başlatılıyor... İlk hakkınızı kullandınız. Kalan hak: 2'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
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
        backgroundColor: const Color(0xFFFF6600),
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
            color: const Color(0xFFFF6600),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Yarışmalar'),
                Tab(text: 'Oyunum'),
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
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Yarışma resmi
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.network(
                                      competition.image,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                ),

                                // Yarışma bilgileri
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Başlık ve geri sayım
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              competition.title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          _buildCountdown(competition.endTime),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Açık/kapalı göstergesi ve genişletme butonu
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 14,
                                                  color: Colors.green.shade700,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Aktif',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Colors.green.shade700,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                if (isExpanded) {
                                                  expandedIndex = null;
                                                } else {
                                                  expandedIndex = index;
                                                  _scrollToSelectedContent(
                                                      index);
                                                }
                                              });
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  const Color(0xFFFF6600),
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(0, 0),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  isExpanded
                                                      ? 'Kapat'
                                                      : 'Detaylar',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Icon(
                                                  isExpanded
                                                      ? Icons
                                                          .keyboard_arrow_up_rounded
                                                      : Icons
                                                          .keyboard_arrow_down_rounded,
                                                  size: 24,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Genişletilmiş detay kısmı
                                      if (isExpanded) ...[
                                        const SizedBox(height: 16),
                                        const Divider(),
                                        const SizedBox(height: 16),
                                        Text(
                                          competition.description,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
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
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed:
                                                firestoreProvider.isLoading
                                                    ? null
                                                    : () => _joinCompetition(
                                                        competition),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFFFF6600),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: firestoreProvider.isLoading
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Yarışmaya Katıl',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
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
                // Oyunum sekmesi
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
  Widget _buildCountdown(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return const Text(
        'Bitti',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    String countdownText;
    if (days > 0) {
      countdownText = '$days gün $hours sa';
    } else if (hours > 0) {
      countdownText = '$hours sa $minutes dk';
    } else {
      countdownText = '$minutes dk';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6600).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6600).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            size: 14,
            color: Color(0xFFFF6600),
          ),
          const SizedBox(width: 4),
          Text(
            countdownText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6600),
            ),
          ),
        ],
      ),
    );
  }
}
