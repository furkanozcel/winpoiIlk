import 'package:flutter/material.dart';

class AgreementsPage extends StatelessWidget {
  const AgreementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sözleşmeler'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAgreementCard(
            title: 'Kullanıcı Sözleşmesi',
            description:
                'WinPoi uygulamasını kullanırken uymanız gereken kurallar ve koşullar.',
            onTap: () {
              // Kullanıcı sözleşmesi detay sayfasına yönlendirme
            },
          ),
          const SizedBox(height: 16),
          _buildAgreementCard(
            title: 'Gizlilik Politikası',
            description:
                'Kişisel verilerinizin nasıl toplandığı, kullanıldığı ve korunduğu hakkında bilgiler.',
            onTap: () {
              // Gizlilik politikası detay sayfasına yönlendirme
            },
          ),
          const SizedBox(height: 16),
          _buildAgreementCard(
            title: 'Yarışma Kuralları',
            description:
                'Yarışmalara katılım kuralları ve ödül kazanma koşulları.',
            onTap: () {
              // Yarışma kuralları detay sayfasına yönlendirme
            },
          ),
          const SizedBox(height: 16),
          _buildAgreementCard(
            title: 'POI Kullanım Koşulları',
            description:
                'POI kazanma ve harcama kuralları hakkında detaylı bilgiler.',
            onTap: () {
              // POI kullanım koşulları detay sayfasına yönlendirme
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
