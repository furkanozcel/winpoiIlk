import 'package:flutter/material.dart';
import 'package:winpoi/features/profile_page/presentation/pages/about_app_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/agreements_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/game_history_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/profile_details_page.dart';
import 'package:winpoi/features/profile_page/presentation/widgets/logout_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Hero(
                  tag: 'profile_header',
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6600),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6600).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String userName = 'Kullanıcı';
                        final userData =
                            snapshot.data?.data() as Map<String, dynamic>? ??
                                {};

                        if (snapshot.hasData && snapshot.data!.exists) {
                          userName =
                              userData['name']?.toString() ?? 'Kullanıcı';
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 500),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: const CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      color: Color(0xFFFF6600),
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // İstatistikler
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSimpleStatCard(
                            icon: Icons.emoji_events,
                            value: '${userData['totalPrizeCount'] ?? 0}',
                            title: 'Kazanılan\nÖdüller',
                          ),
                          _buildSimpleStatCard(
                            icon: Icons.currency_lira,
                            value: '${userData['poiBalance'] ?? 0}',
                            title: 'POI\nBakiyesi',
                          ),
                          _buildSimpleStatCard(
                            icon: Icons.gamepad,
                            value: '${userData['totalGames'] ?? 0}',
                            title: 'Toplam\nOyun',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Menü Listesi
                      _buildSimpleMenuItem(
                        icon: Icons.person_outline,
                        title: 'Profil Bilgileri',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ProfileDetailsPage())),
                      ),
                      _buildSimpleMenuItem(
                        icon: Icons.history,
                        title: 'Oyun Geçmişi',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GameHistoryPage())),
                      ),
                      _buildSimpleMenuItem(
                        icon: Icons.info_outline,
                        title: 'Uygulama Hakkında',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutAppPage())),
                      ),
                      _buildSimpleMenuItem(
                        icon: Icons.description_outlined,
                        title: 'Sözleşmeler',
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AgreementsPage())),
                      ),
                      _buildSimpleMenuItem(
                        icon: Icons.support_agent,
                        title: 'Destek',
                        onTap: () {},
                      ),
                      // Admin menüsü - sadece admin rolüne sahip kullanıcılar için
                      if (userData['role'] == 'admin') ...[
                        _buildSimpleMenuItem(
                          icon: Icons.admin_panel_settings,
                          title: 'Yarışma Yönetimi',
                          onTap: () => Navigator.pushNamed(
                              context, '/admin/competitions'),
                        ),
                      ],
                      _buildSimpleMenuItem(
                        icon: Icons.logout,
                        title: 'Çıkış Yap',
                        onTap: () async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Çıkış Yap'),
                              content: const Text(
                                  'Çıkış yapmak istediğinizden emin misiniz?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('İptal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Çıkış Yap'),
                                ),
                              ],
                            ),
                          );

                          if (result == true && mounted) {
                            try {
                              await FirebaseAuth.instance.signOut();

                              if (mounted) {
                                // Çıkış başarılı mesajı
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Başarıyla çıkış yapıldı'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Login sayfasına yönlendir ve geri dönüşü engelle
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login',
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Çıkış yapılırken hata oluştu: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleStatCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return SafeArea(
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 500),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double animValue, child) {
          return Transform.scale(
            scale: animValue,
            child: Container(
              width: 110,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6600).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFFFF6600),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimpleMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 200),
          tween: Tween<double>(begin: 0.97, end: 1),
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6600).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFFFF6600),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFFFF6600),
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
