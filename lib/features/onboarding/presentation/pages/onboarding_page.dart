import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winpoi/features/auth/presentation/pages/register_page.dart';
import 'package:winpoi/features/game/presentation/pages/game_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  int _currentPage = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: "WinPoi Evreni 🎉",
      description:
          "Yarışma dünyasına adım atmaya hazır mısın? Yeteneklerini konuştur ve harika ödüllerin sahibi ol!",
      icon: Icons.celebration,
      color: Color(0xFFFF6B6B),
      secondaryColor: Color(0xFFFF8E8E),
    ),
    OnboardingItem(
      title: "Ödüller Kazan 🏆",
      description:
          "İstediğin ödülü kazanmak için oyunlara katıl ve yeteneklerini göster. Sanal bir hazine avcısı olmaya hazır mısın?",
      icon: Icons.emoji_events,
      color: Color(0xFF4ECDC4),
      secondaryColor: Color(0xFF7EDFD9),
    ),
    OnboardingItem(
      title: "Arkadaşlarınla Yarış 🤝",
      description:
          "Arkadaşlarınla birlikte yarışmalara katıl, rekabet et ve eğlenceli vakit geçir. Başarılarını paylaş ve ilham ver!",
      icon: Icons.groups,
      color: Color(0xFFFFBE0B),
      secondaryColor: Color(0xFFFFD44C),
    ),
    OnboardingItem(
      title: "Hazır mısın? 🎮",
      description:
          "Büyüleyici WinPoi evrenine adım at. Yeteneklerini keşfet ve ödülleri topla!",
      icon: Icons.play_circle_filled,
      color: Color(0xFF845EC2),
      secondaryColor: Color(0xFFB39CD0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => _currentPage == _pages.length - 1
                ? const GamePage()
                : const RegisterPage()),
      );
    }
  }

  void _onNextPage() {
    if (_currentPage == _pages.length - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _pages[_currentPage].color.withOpacity(0.3),
              _pages[_currentPage].secondaryColor.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                    _animationController.reset();
                    _animationController.forward();
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        page.color,
                        page.secondaryColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: page.color.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    page.icon,
                    size: 90,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  page.title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    page.description,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade700,
                      height: 1.6,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0.0,
                  end: _currentPage == index ? 1.0 : 0.0,
                ),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8 + (20 * value),
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          _pages[_currentPage].color,
                          _pages[_currentPage].secondaryColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _pages[_currentPage].color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _pages[_currentPage].color,
                  _pages[_currentPage].secondaryColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _pages[_currentPage].color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _onNextPage,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _pages.length - 1 ? 'Oyna' : 'Sonraki',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (_currentPage == _pages.length - 1) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ],
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

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color secondaryColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.secondaryColor,
  });
}
