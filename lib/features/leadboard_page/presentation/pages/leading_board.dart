import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/leaderboard_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeadingBoard extends StatefulWidget {
  const LeadingBoard({super.key});

  @override
  State<LeadingBoard> createState() => _LeadingBoardState();
}

class _LeadingBoardState extends State<LeadingBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _podiumScale;
  late Animation<double> _podiumOpacity;
  late Animation<Offset> _podiumSlide;
  late Animation<double> _listOpacity;
  late Animation<Offset> _listSlide;

  // Renk sabitleri
  static const Color primaryColor = Color(0xFF5FC9BF); // Turkuaz
  static const Color secondaryColor = Color(0xFFE28B33); // Turuncu
  static const Color accentColor = Color(0xFF8156A0); // Mor

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _podiumScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _podiumOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _podiumSlide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _listSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    _listOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 1.0, curve: Curves.easeIn)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardProvider>().loadGlobalLeaderboard();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Liderlik Tablosu"),
                  content: const Text(
                    "Bu tablo, en yüksek Poi puanına sahip kullanıcıları gösterir. Daha fazla Poi kazanarak sıralamada yükselebilirsiniz!",
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Anladım"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4E43AC), // Mor
              Color(0xFF43AC9E), // Yeşil
            ],
          ),
        ),
        child: leaderboardProvider.isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Liderlik tablosu yükleniyor...",
                      style: TextStyle(color: primaryColor),
                    ),
                  ],
                ),
              )
            : leaderboardProvider.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          leaderboardProvider.error!,
                          style:
                              TextStyle(color: Colors.grey[800], fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              leaderboardProvider.loadGlobalLeaderboard(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          child: const Text("Tekrar Dene"),
                        ),
                      ],
                    ),
                  )
                : leaderboardProvider.leaderboardData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz kullanıcı yok',
                              style: TextStyle(
                                  color: Colors.grey[800], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : _buildAnimatedLeaderboard(
                        context, leaderboardProvider.leaderboardData),
      ),
    );
  }

  Widget _buildAnimatedLeaderboard(
      BuildContext context, List<Map<String, dynamic>> users) {
    final String currentUserEmail =
        FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase() ?? '';
    final leaderboardProvider =
        Provider.of<LeaderboardProvider>(context, listen: false);
    final sortedUsers = List<Map<String, dynamic>>.from(users)
      ..sort((a, b) =>
          (b['successPoints'] as num).compareTo(a['successPoints'] as num));
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: 36),
          // Podium animasyonu
          SlideTransition(
            position: _podiumSlide,
            child: ScaleTransition(
              scale: _podiumScale,
              child: FadeTransition(
                opacity: _podiumOpacity,
                child: SizedBox(
                  height: 140,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                    ),
                    child: Stack(
                      children: [
                        if (sortedUsers.length > 1)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: _PodiumUserSimple(
                              username:
                                  sortedUsers[1]['username']?.toString() ?? '',
                              point: sortedUsers[1]['successPoints'].toString(),
                              isMain: false,
                              isSecondOrThird: true,
                              maxBoxWidth: 100,
                            ),
                          ),
                        if (sortedUsers.isNotEmpty)
                          Align(
                            alignment: Alignment.topCenter,
                            child: _PodiumUserSimple(
                              username:
                                  sortedUsers[0]['username']?.toString() ?? '',
                              point: sortedUsers[0]['successPoints'].toString(),
                              isMain: true,
                              isSecondOrThird: false,
                              maxBoxWidth: 100,
                            ),
                          ),
                        if (sortedUsers.length > 2)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: _PodiumUserSimple(
                              username:
                                  sortedUsers[2]['username']?.toString() ?? '',
                              point: sortedUsers[2]['successPoints'].toString(),
                              isMain: false,
                              isSecondOrThird: true,
                              maxBoxWidth: 100,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          // Liste animasyonu
          Expanded(
            child: SlideTransition(
              position: _listSlide,
              child: FadeTransition(
                opacity: _listOpacity,
                child: RefreshIndicator(
                  color: primaryColor,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    await leaderboardProvider.loadGlobalLeaderboard();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: sortedUsers.length,
                    itemBuilder: (context, index) {
                      if (index < 3) return const SizedBox.shrink();
                      final user = sortedUsers[index];
                      final isCurrentUser = user['email'] == currentUserEmail;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        decoration: isCurrentUser
                            ? BoxDecoration(
                                color: Colors.amber[50],
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        child: ListTile(
                          dense: true,
                          leading: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: isCurrentUser
                                  ? Colors.grey[900]
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          title: Text(
                            user['username']?.toString() ?? '',
                            style: TextStyle(
                              color: isCurrentUser
                                  ? Colors.grey[900]
                                  : Colors.white,
                              fontWeight: isCurrentUser
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                color: isCurrentUser
                                    ? Colors.grey[900]
                                    : Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user['successPoints'].toString(),
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? Colors.grey[900]
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumUserSimple extends StatelessWidget {
  final String username;
  final String point;
  final bool isMain;
  final bool isSecondOrThird;
  final double maxBoxWidth;

  const _PodiumUserSimple({
    required this.username,
    required this.point,
    required this.isMain,
    this.isSecondOrThird = false,
    this.maxBoxWidth = 100,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double minBoxWidth = 70;
    final double boxWidth = maxBoxWidth.clamp(minBoxWidth, maxBoxWidth);
    final double fontSize = isMain
        ? 20
        : isSecondOrThird
            ? 17
            : 15;
    final double pointFontSize = isMain
        ? 16
        : isSecondOrThird
            ? 14
            : 13;
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 70, maxWidth: 160),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: isMain
                    ? 18
                    : isSecondOrThird
                        ? 14
                        : 8,
                vertical: isMain
                    ? 8
                    : isSecondOrThird
                        ? 6
                        : 4,
              ),
              decoration: BoxDecoration(
                color: isMain
                    ? null
                    : (isSecondOrThird ? null : Colors.transparent),
                gradient: isMain
                    ? LinearGradient(
                        colors: [
                          const Color(0xFFFFB088), // Turuncu açık
                          const Color(0xFFE28B33), // Turuncu koyu
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : isSecondOrThird
                        ? LinearGradient(
                            colors: [
                              const Color(0xFFFFB088).withOpacity(
                                  0.8), // Biraz daha belirgin turuncu açık
                              const Color(0xFFE28B33).withOpacity(
                                  0.8), // Biraz daha belirgin turuncu koyu
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                borderRadius: BorderRadius.circular(isMain
                    ? 16
                    : isSecondOrThird
                        ? 12
                        : 8),
                boxShadow: isMain
                    ? [
                        BoxShadow(
                          color: const Color(0xFFE28B33).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: -1,
                          offset: const Offset(0, -2),
                        ),
                      ]
                    : isSecondOrThird
                        ? [
                            BoxShadow(
                              color: const Color(0xFFE28B33).withOpacity(
                                  0.35), // Gölge opaklığını da artırdım
                              blurRadius: 12,
                              spreadRadius: 0,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                border: isMain
                    ? Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      )
                    : isSecondOrThird
                        ? Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          )
                        : null,
              ),
              child: Text(
                username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isMain
                      ? FontWeight.bold
                      : isSecondOrThird
                          ? FontWeight.w600
                          : FontWeight.w500,
                  fontSize: fontSize,
                  letterSpacing: isMain ? 0.5 : 0.2,
                  shadows: isMain
                      ? [
                          Shadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2))
                        ]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: pointFontSize + 2,
                ),
                const SizedBox(width: 4),
                Text(
                  point,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isMain
                        ? FontWeight.bold
                        : isSecondOrThird
                            ? FontWeight.w600
                            : FontWeight.normal,
                    fontSize: pointFontSize,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
