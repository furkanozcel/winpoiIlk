import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;
import 'package:winpoi/core/providers/user_provider.dart';
import 'package:winpoi/features/profile_page/presentation/pages/about_app_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/agreements_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/profile_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _menuController;
  late Animation<double> _headerFade;
  late Animation<double> _headerScale;
  late Animation<double> _menuFade;
  late Animation<double> _menuScale;

  @override
  void initState() {
    super.initState();
    // Profil bilgilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _headerFade =
        CurvedAnimation(parent: _headerController, curve: Curves.easeInOut);
    _headerScale = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    _menuFade =
        CurvedAnimation(parent: _menuController, curve: Curves.easeInOut);
    _menuScale = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _menuController, curve: Curves.easeOutBack),
    );

    _headerController.forward().then((_) => _menuController.forward());
  }

  @override
  void dispose() {
    _headerController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<app_provider.AuthProvider>(context);

    // Tema renkleri
    const Color primaryColor = Color(0xFF5FC9BF); // Turkuaz
    const Color secondaryColor = Color(0xFFE28B33); // Turuncu
    const Color backgroundColor = Color(0xFFF5F5F5); // Açık Gri
    const Color textColor = Color(0xFF424242); // Koyu Gri

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Row(
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
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
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
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => userProvider.loadUserData(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      FadeTransition(
                        opacity: _headerFade,
                        child: ScaleTransition(
                          scale: _headerScale,
                          child: _buildProfileHeaderWithStats(
                              userProvider.userData),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _menuFade,
                        child: ScaleTransition(
                          scale: _menuScale,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildMenuItems(
                                context, userProvider, authProvider),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeaderWithStats(Map<String, dynamic>? userData) {
    const Color primaryColor = Color(0xFF5FC9BF); // Turkuaz
    const Color secondaryColor = Color(0xFFE28B33); // Turuncu
    const Color textColor = Color(0xFF424242);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    userData?['username']?.toString() ??
                        userData?['name']?.toString() ??
                        'Kullanıcı',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8156A0),
                        const Color(0xFF9B6BB7),
                        const Color(0xFF8156A0),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
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
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${userData?['poiBalance'] ?? 0}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 18,
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
                          fontSize: 14,
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStatCard(
                icon: Icons.emoji_events,
                value: '${userData?['totalPrizeCount'] ?? 0}',
                title: 'Kazanılan\nÖdüller',
                iconColor: Colors.white,
                bgColor: Colors.white.withOpacity(0.12),
                textColor: Colors.white,
              ),
              _buildSimpleStatCard(
                icon: Icons.workspace_premium,
                value: '${userData?['successPoints'] ?? 0}',
                title: 'Başarı\nPuanı',
                iconColor: Colors.white,
                bgColor: Colors.white.withOpacity(0.12),
                textColor: Colors.white,
              ),
              _buildSimpleStatCard(
                icon: Icons.gamepad,
                value: '${userData?['totalGames'] ?? 0}',
                title: 'Toplam\nOyun',
                iconColor: Colors.white,
                bgColor: Colors.white.withOpacity(0.12),
                textColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, UserProvider userProvider,
      app_provider.AuthProvider authProvider) {
    const Color primaryColor = Color(0xFF5FC9BF);
    const Color textColor = Color(0xFF424242);

    final items = [
      {
        'icon': Icons.person_outline,
        'title': 'Profil Bilgileri',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProfileDetailsPage()),
            ),
      },
      {
        'icon': Icons.info_outline,
        'title': 'Uygulama Hakkında',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutAppPage()),
            ),
      },
      {
        'icon': Icons.description_outlined,
        'title': 'Sözleşmeler',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AgreementsPage()),
            ),
      },
      {
        'icon': Icons.support_agent,
        'title': 'Destek',
        'onTap': () {},
      },
      if (userProvider.userData?['role'] == 'admin')
        {
          'icon': Icons.admin_panel_settings,
          'title': 'Yarışma Yönetimi',
          'onTap': () => Navigator.pushNamed(context, '/admin/competitions'),
        },
      {
        'icon': Icons.logout,
        'title': 'Çıkış Yap',
        'onTap': () => _showLogoutDialog(context, authProvider),
        'iconColor': Colors.redAccent,
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(
            item['icon'] as IconData,
            color: item['iconColor'] as Color? ?? primaryColor,
          ),
          title: Text(
            item['title'] as String,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          onTap: item['onTap'] as VoidCallback,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          tileColor: Colors.white,
          dense: true,
        );
      },
    );
  }

  Widget _buildSimpleStatCard({
    required IconData icon,
    required String value,
    required String title,
    required Color iconColor,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
}
