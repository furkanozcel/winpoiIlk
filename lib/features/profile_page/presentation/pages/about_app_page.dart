import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uygulama Hakkında'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo ve Versiyon
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 60,
                      color: Colors.orange.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'WinPoi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Versiyon 1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Uygulama Hakkında Bilgi
            _buildInfoSection(
              title: 'WinPoi Nedir?',
              content:
                  'WinPoi, kullanıcıların eğlenceli yarışmalara katılarak ödüller kazanabildiği bir platformdur. Yarışmalara katılın, POI kazanın ve harika ödüllerin sahibi olun!',
            ),
            const SizedBox(height: 24),

            _buildInfoSection(
              title: 'Nasıl Çalışır?',
              content:
                  '1. Yarışmalara katılın\n2. POI kazanın\n3. Sıralamada yükselin\n4. Ödülleri kazanın',
            ),
            const SizedBox(height: 24),

            _buildInfoSection(
              title: 'İletişim',
              content: 'E-posta: support@winpoi.com\nWeb: www.winpoi.com',
            ),
            const SizedBox(height: 24),

            // Sosyal Medya Linkleri
            _buildSocialMediaLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.facebook,
          onTap: () {
            // Facebook sayfasına yönlendirme
          },
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          icon: Icons.android,
          onTap: () {
            // Play Store sayfasına yönlendirme
          },
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          icon: Icons.language,
          onTap: () {
            // Web sitesine yönlendirme
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.orange,
          size: 24,
        ),
      ),
    );
  }
}
