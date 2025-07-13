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
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF4E43AC), // Mor
              Color(0xFF43AC9E), // Yeşil
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
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
        actions: [
          IconButton(
            icon: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF4E43AC),
                  Color(0xFF43AC9E),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white, // Shader ile override
              ),
            ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withOpacity(0.25),
          ),
        ),
      ),
      body: Expanded(
        child: _buildAnimatedLeaderboard(
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
      top: true,
      bottom: false,
      child: Column(
        children: [
          const SizedBox(height: 15), // Divider'dan sonra küçük boşluk
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
                      final user = sortedUsers[index];
                      final isFirst = index == 0;
                      final isSecond = index == 1;
                      final isThird = index == 2;
                      return Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: (isFirst || isSecond || isThird) ? 6 : 2),
                        decoration: (isFirst || isSecond || isThird)
                            ? BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFD4F4F1),
                                    Color(0xFFE6D4F4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              )
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  (index + 1).toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: isFirst
                                        ? 26
                                        : isSecond
                                            ? 24
                                            : isThird
                                                ? 22
                                                : 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  user['username']?.toString() ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: isFirst
                                        ? 24
                                        : isSecond
                                            ? 22
                                            : isThird
                                                ? 20
                                                : 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 38,
                                    child: Text(
                                      user['successPoints'].toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        fontSize: isFirst
                                            ? 24
                                            : isSecond
                                                ? 22
                                                : isThird
                                                    ? 20
                                                    : 16,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.workspace_premium,
                                    color: Colors.black,
                                    size: isFirst
                                        ? 24
                                        : isSecond
                                            ? 22
                                            : isThird
                                                ? 20
                                                : 16,
                                  ),
                                ],
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
          // Sabit mevcut kullanıcı kutusu
          Builder(
            builder: (context) {
              final currentUserIndex =
                  sortedUsers.indexWhere((u) => u['email'] == currentUserEmail);
              if (currentUserIndex == -1) return const SizedBox.shrink();
              final user = sortedUsers[currentUserIndex];
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                decoration: BoxDecoration(
                  color: Color(0xFFF7A278),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          (currentUserIndex + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user['username']?.toString() ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 38,
                            child: Text(
                              user['successPoints'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
