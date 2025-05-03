import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:winpoi/features/home_page/presentation/pages/home_page.dart';
import 'package:winpoi/features/leadboard_page/presentation/pages/leading_board.dart';
import 'package:winpoi/features/profile_page/presentation/pages/profile_page.dart';

const Color primaryColor = Color(0xFF5FC9BF); // Turkuaz
const Color secondaryColor = Color(0xFFE28B33); // Turuncu
const Color accentColor = Color(0xFF8156A0); // Mor

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Widget> _pages = [
    const HomePage(),
    const LeadingBoard(),
    const ProfilePage(),
  ];

  // NavigationBar item bilgileri
  final List<_NavBarItemData> _navBarItems = const [
    _NavBarItemData(icon: Icons.home_rounded, pageIndex: 0),
    _NavBarItemData(icon: Icons.emoji_events_rounded, pageIndex: 1),
    _NavBarItemData(icon: Icons.person_rounded, pageIndex: 2),
  ];

  Color _getNavBarColor() {
    if (_selectedIndex == 1) {
      return secondaryColor; // Liderlik tablosu (turuncu)
    } else {
      return Colors.white; // Ana sayfa ve profil (beyaz)
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    // Seçili olanı ortada, diğerlerini sola ve sağa yerleştir
    final int selected = _selectedIndex;
    // Ortadaki ikon (floating): seçili
    // Sol ve sağ: diğer iki ikon, sıralama swap mantığıyla
    int left, right;
    if (selected == 0) {
      left = 1;
      right = 2;
    } else if (selected == 1) {
      left = 0;
      right = 2;
    } else {
      left = 0;
      right = 1;
    }
    final List<_NavBarItemData> items = [
      _navBarItems[left],
      _navBarItems[selected],
      _navBarItems[right],
    ];
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOutQuart,
            height: 80,
            decoration: BoxDecoration(
              color: _getNavBarColor(),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 2,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildSideNavItem(items[0]),
                ),
                const SizedBox(width: 60),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildSideNavItem(items[2]),
                ),
              ],
            ),
          ),
          // Ortadaki floating ikon
          Positioned(
            top: -18,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _buildFloatingNavItem(items[1]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavItem(_NavBarItemData item) {
    final bool isSelected = true;
    Color selectedColor = primaryColor;
    return GestureDetector(
      key: ValueKey(item.pageIndex),
      onTap: () => _onItemTapped(item.pageIndex),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          item.icon,
          color: selectedColor,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildSideNavItem(_NavBarItemData item) {
    final bool isSelected = false;
    Color selectedColor = accentColor;
    return GestureDetector(
      key: ValueKey(item.pageIndex),
      onTap: () => _onItemTapped(item.pageIndex),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        child: Icon(
          item.icon,
          color: selectedColor,
          size: 24,
        ),
      ),
    );
  }
}

class _NavBarItemData {
  final IconData icon;
  final int pageIndex;
  const _NavBarItemData({required this.icon, required this.pageIndex});
}
