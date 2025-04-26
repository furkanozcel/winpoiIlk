import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;
import 'package:winpoi/core/providers/user_provider.dart';
import 'package:winpoi/features/profile_page/presentation/pages/about_app_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/agreements_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/game_history_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/profile_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Profil bilgilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<app_provider.AuthProvider>(context);

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
      ),
      body: userProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6600)))
          : userProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Veri yüklenirken hata oluştu',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => userProvider.loadUserData(),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Üst profil bölümü
                      _buildProfileHeader(context, userProvider.userData),

                      // Ana menü bölümü
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // İstatistikler
                            _buildStatisticsRow(userProvider.userData),

                            const SizedBox(height: 20),

                            // Menü Listesi
                            _buildMenuItems(
                                context, userProvider, authProvider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, Map<String, dynamic>? userData) {
    return Container(
      height: 180,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Color(0xFFFF6600),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            userData?['username']?.toString() ??
                userData?['name']?.toString() ??
                'Kullanıcı',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow(Map<String, dynamic>? userData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSimpleStatCard(
          icon: Icons.emoji_events,
          value: '${userData?['totalPrizeCount'] ?? 0}',
          title: 'Kazanılan\nÖdüller',
        ),
        _buildSimpleStatCard(
          icon: Icons.currency_lira,
          value: '${userData?['poiBalance'] ?? 0}',
          title: 'POI\nBakiyesi',
        ),
        _buildSimpleStatCard(
          icon: Icons.gamepad,
          value: '${userData?['totalGames'] ?? 0}',
          title: 'Toplam\nOyun',
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context, UserProvider userProvider,
      app_provider.AuthProvider authProvider) {
    return Column(
      children: [
        _buildSimpleMenuItem(
          icon: Icons.person_outline,
          title: 'Profil Bilgileri',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileDetailsPage(),
            ),
          ),
        ),
        _buildSimpleMenuItem(
          icon: Icons.history,
          title: 'Oyun Geçmişi',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GameHistoryPage(),
            ),
          ),
        ),
        _buildSimpleMenuItem(
          icon: Icons.info_outline,
          title: 'Uygulama Hakkında',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AboutAppPage(),
            ),
          ),
        ),
        _buildSimpleMenuItem(
          icon: Icons.description_outlined,
          title: 'Sözleşmeler',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgreementsPage(),
            ),
          ),
        ),
        _buildSimpleMenuItem(
          icon: Icons.support_agent,
          title: 'Destek',
          onTap: () {},
        ),
        // Admin menüsü - sadece admin rolüne sahip kullanıcılar için
        if (userProvider.userData?['role'] == 'admin') ...[
          _buildSimpleMenuItem(
            icon: Icons.admin_panel_settings,
            title: 'Yarışma Yönetimi',
            onTap: () => Navigator.pushNamed(context, '/admin/competitions'),
          ),
        ],
        _buildSimpleMenuItem(
          icon: Icons.logout,
          title: 'Çıkış Yap',
          onTap: () => _showLogoutDialog(context, authProvider),
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(
      BuildContext context, app_provider.AuthProvider authProvider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
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
        await authProvider.signOut();

        if (mounted) {
          // Çıkış başarılı mesajı
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Başarıyla çıkış yapıldı'),
              backgroundColor: Colors.green,
            ),
          );

          // Login sayfasına yönlendir
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Çıkış yaparken hata oluştu: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildSimpleStatCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFF6600), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6600),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6600).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFFF6600), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 24,
          color: Colors.grey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
