import 'package:flutter/material.dart';
import 'package:winpoi/features/profile_page/presentation/pages/about_app_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/agreements_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/game_history_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/profile_details_page.dart';
import 'package:winpoi/features/profile_page/presentation/widgets/logout_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.shade400,
                      Colors.orange.shade600,
                    ],
                  ),
                ),
              ),
              title: const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.orange),
                  ),
                  SizedBox(width: 12),
                  Text('Ahmet Yılmaz'),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İstatistikler
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.emoji_events,
                          title: 'Kazanılan Ödüller',
                          value: '12',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.monetization_on,
                          title: 'POI Bakiyesi',
                          value: '2,450',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.gamepad,
                          title: 'Toplam Oyun',
                          value: '45',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Menü Listesi
                  _buildMenuSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orange, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Profil Bilgileri',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileDetailsPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Oyun Geçmişi',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GameHistoryPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Uygulama Hakkında',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AboutAppPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'Sözleşmeler',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AgreementsPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.support_agent,
            title: 'Destek',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Çıkış Yap',
            textColor: Colors.red,
            onTap: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => const LogoutDialog(),
              );

              if (result == true) {
                // Çıkış işlemleri burada yapılacak
                // Örneğin:
                // - Token'ı sil
                // - Kullanıcı verilerini temizle
                // - Login sayfasına yönlendir
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: textColor ?? Colors.grey.shade700,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
    );
  }
}
