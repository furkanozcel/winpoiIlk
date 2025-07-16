import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;
import 'package:winpoi/core/providers/user_provider.dart';
import 'package:winpoi/features/profile_page/presentation/pages/about_app_page.dart';
import 'package:winpoi/features/profile_page/presentation/pages/agreements_page.dart'
    as agreements;
import 'package:winpoi/features/profile_page/presentation/widgets/logout_dialog.dart';
import 'package:winpoi/features/notifications/presentation/pages/notifications_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

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
      duration: const Duration(milliseconds: 600),
    );
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerFade =
        CurvedAnimation(parent: _headerController, curve: Curves.easeInOut);
    _headerScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    _menuFade =
        CurvedAnimation(parent: _menuController, curve: Curves.easeInOut);
    _menuScale = Tween<double>(begin: 0.95, end: 1.0).animate(
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

    return Scaffold(
      body: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withOpacity(0.25),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: userProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : userProvider.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 48,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Veri yüklenirken hata oluştu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => userProvider.loadUserData(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.2),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  child: const Text('Tekrar Dene'),
                                ),
                              ],
                            ),
                          )
                        : CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              // App Bar
                              SliverAppBar(
                                expandedHeight: 0,
                                floating: false,
                                pinned: true,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                title: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFF4E43AC), // Mor
                                      Color(0xFF43AC9E), // Yeşil
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ).createShader(bounds),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Win',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Poi',
                                        style: GoogleFonts.quicksand(
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
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Color(0xFF4E43AC),
                                          Color(0xFF43AC9E),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ).createShader(bounds),
                                      child: const Icon(
                                        Icons.notifications_outlined,
                                        color:
                                            Colors.white, // Shader ile override
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationsPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              // AppBar'ın hemen altına Divider
                              SliverToBoxAdapter(
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey.withOpacity(0.25),
                                ),
                              ),
                              // Profil İçeriği
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    FadeTransition(
                                      opacity: _headerFade,
                                      child: ScaleTransition(
                                        scale: _headerScale,
                                        child: _buildModernProfileHeader(
                                            userProvider.userData),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    FadeTransition(
                                      opacity: _menuFade,
                                      child: ScaleTransition(
                                        scale: _menuScale,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: _buildModernMenuItems(context,
                                              userProvider, authProvider),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernProfileHeader(Map<String, dynamic>? userData) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD4F4F1), // Açık turkuaz
            Color(0xFFE6D4F4), // Açık pembe
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Kullanıcı Adı ve Düzenleme Butonu
          Row(
            children: [
              Flexible(
                child: Text(
                  userData?['username']?.toString() ??
                      userData?['name']?.toString() ??
                      'Kullanıcı',
                  style: GoogleFonts.quicksand(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showEditUsernameDialog(userData),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7A278).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFFF7A278),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // İstatistik Kartları
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.leaderboard_rounded,
                  value: '${userData?['successPoints'] ?? 0}',
                  label: 'Başarı Puanı',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4ECDC4), // Turkuaz
                      Color(0xFF44A08D), // Koyu turkuaz
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.workspace_premium,
                  value: '${userData?['level'] ?? 1}',
                  label: 'Seviye',
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF845EC2), // Mor
                      Color(0xFFD65DB1), // Pembe
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMenuItems(BuildContext context, UserProvider userProvider,
      app_provider.AuthProvider authProvider) {
    final items = [
      {
        'icon': Icons.card_giftcard,
        'title': 'Hediyelerim',
        'subtitle': 'Kazandığınız ödülleri görün',
        'onTap': () {},
        'color': const Color(0xFFF7A278),
      },
      {
        'icon': Icons.info_outline,
        'title': 'Uygulama Hakkında',
        'subtitle': 'Uygulama bilgileri ve sürüm',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutAppPage()),
            ),
        'color': const Color(0xFFF7A278),
      },
      {
        'icon': Icons.description_outlined,
        'title': 'Sözleşmeler',
        'subtitle': 'Kullanım şartları ve gizlilik',
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const agreements.AgreementsPage()),
            ),
        'color': const Color(0xFFF7A278),
      },
      if (userProvider.userData?['role'] == 'admin')
        {
          'icon': Icons.admin_panel_settings,
          'title': 'Yarışma Yönetimi',
          'subtitle': 'Admin paneli ve yarışma ayarları',
          'onTap': () => Navigator.pushNamed(context, '/admin/competitions'),
          'color': const Color(0xFFF7A278),
        },
      {
        'icon': Icons.logout,
        'title': 'Çıkış Yap',
        'subtitle': 'Hesabınızdan güvenli çıkış',
        'onTap': () => _showLogoutDialog(context, authProvider),
        'color': Colors.redAccent,
      },
      {
        'icon': Icons.delete_forever,
        'title': 'Hesabı Sil',
        'subtitle': 'Hesabınızı kalıcı olarak silin',
        'onTap': () {}, // İşlevsiz
        'color': Colors.red,
      },
    ];

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            leading: Icon(
              item['icon'] as IconData,
              color: item['color'] as Color,
              size: 22,
            ),
            title: Text(
              item['title'] as String,
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            subtitle: Text(
              item['subtitle'] as String,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 20,
            ),
            onTap: item['onTap'] as VoidCallback,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _showEditUsernameDialog(Map<String, dynamic>? userData) async {
    final controller =
        TextEditingController(text: userData?['username']?.toString() ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kullanıcı Adını Düzenle',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  labelStyle: const TextStyle(
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        final newUsername = controller.text.trim();
                        if (newUsername.isEmpty) return;
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({'username': newUsername});
                        }
                        Navigator.pop(context, newUsername);
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
                        'Kaydet',
                        style: TextStyle(
                          fontSize: 16,
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
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {}); // Güncellenen kullanıcı adı anında görünsün
    }
  }

  Future<void> _showLogoutDialog(
      BuildContext context, app_provider.AuthProvider authProvider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const LogoutDialog(),
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

          // Auth sayfasına yönlendir
          Navigator.of(context).pushReplacementNamed('/auth');
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
