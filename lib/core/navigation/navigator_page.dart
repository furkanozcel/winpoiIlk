import 'package:flutter/material.dart';
import 'package:winpoi/features/home_page/presentation/pages/home_page.dart';
import 'package:winpoi/features/leadboard_page/presentation/pages/leading_board.dart';
import 'package:winpoi/features/profile_page/presentation/pages/profile_page.dart';

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({super.key});

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const LeadingBoard(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Liderlik Tablosu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
