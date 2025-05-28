import 'package:flutter/material.dart';

// Renk paleti
const Color primaryColor = Color(0xFF5FC9BF); // Turkuaz
const Color secondaryColor = Color(0xFFE28B33); // Turuncu
const Color accentColor = Color(0xFFB39DDB); // Soft Mor (isteğe bağlı)
const Color textColor = Color(0xFF424242); // Koyu Gri

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: const Text(
                  'Uygulama Hakkında',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    letterSpacing: 0.1,
                  ),
                ),
              );
            },
          ),
          flexibleSpace: null,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Üst Kısım
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 32,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor,
                      secondaryColor,
                    ],
                  ),
                ),
                child: Center(
                  child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: Column(
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Win',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        letterSpacing: -0.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Poi',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        letterSpacing: -0.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.22),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.22),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Versiyon 1.0.0',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: _buildSocialMediaLinks(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildInfoSectionWithAnimation(
                      icon: Icons.info_outline,
                      title: 'WinPoi Nedir?',
                      content:
                          'WinPoi, kullanıcıların eğlenceli yarışmalara katılarak ödüller kazanabildiği bir platformdur. Yarışmalara katılın, POI kazanın ve harika ödüllerin sahibi olun!',
                      delay: 200,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSectionWithAnimation(
                      icon: Icons.emoji_events_outlined,
                      title: 'Yarışma Kuralları',
                      content:
                          '''• Her yarışmaya katılım için minimum POI gereklidir
• Yarışmalar belirli zaman dilimlerinde gerçekleşir
• Her yarışmanın kendine özgü kuralları vardır
• Haksız rekabet oluşturacak davranışlar yasaktır
• Kazananlar sistem tarafından otomatik belirlenir''',
                      delay: 400,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSectionWithAnimation(
                      icon: Icons.currency_exchange_outlined,
                      title: 'POI Sistemi',
                      content: '''• POI'ler yarışmalara katılarak kazanılır
• Kazanılan POI'ler ödül alımında kullanılabilir
• POI transferi yapılamaz
• Minimum çekim limiti 1000 POI'dir
• POI'ler 1 yıl içinde kullanılmalıdır''',
                      delay: 600,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSectionWithAnimation(
                      icon: Icons.contact_support_outlined,
                      title: 'İletişim',
                      content:
                          'E-posta: support@winpoi.com\nWeb: www.winpoi.com',
                      delay: 800,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSectionWithAnimation({
    required IconData icon,
    required String title,
    required String content,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.96),
                    primaryColor.withOpacity(0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: primaryColor.withOpacity(0.10),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.16),
                              secondaryColor.withOpacity(0.10),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          color: secondaryColor.withOpacity(0.85),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          fontFamily: 'Poppins',
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    content,
                    style: TextStyle(
                      color: textColor.withOpacity(0.82),
                      height: 1.55,
                      fontSize: 15.5,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialMediaLinks() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.10),
            secondaryColor.withOpacity(0.07),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryColor.withOpacity(0.13),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [primaryColor, secondaryColor],
            ).createShader(bounds),
            child: const Text(
              'Bizi Takip Edin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: Icons.camera_alt,
                onTap: () {},
                label: 'Instagram',
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                icon: Icons.android,
                onTap: () {},
                label: 'Android',
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                icon: Icons.language,
                onTap: () {},
                label: 'Web',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 1, end: 1),
      builder: (context, scale, child) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.10),
                    secondaryColor.withOpacity(0.07),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: secondaryColor,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: secondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
