import 'package:flutter/material.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Bilgileri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Profil düzenleme sayfasına yönlendirme
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profil Fotoğrafı
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange,
                        width: 3,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.orange,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profil Bilgileri Listesi
            _buildInfoCard(
              title: 'Kişisel Bilgiler',
              children: [
                _buildInfoItem(
                  icon: Icons.person_outline,
                  label: 'Ad Soyad',
                  value: 'Ahmet Yılmaz',
                ),
                _buildInfoItem(
                  icon: Icons.alternate_email,
                  label: 'Kullanıcı Adı',
                  value: '@ahmetyilmaz',
                ),
                _buildInfoItem(
                  icon: Icons.email_outlined,
                  label: 'E-posta',
                  value: 'ahmet.yilmaz@email.com',
                ),
                _buildInfoItem(
                  icon: Icons.phone_outlined,
                  label: 'Telefon',
                  value: '+90 555 123 4567',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Oyun İstatistikleri
            _buildInfoCard(
              title: 'Oyun İstatistikleri',
              children: [
                _buildInfoItem(
                  icon: Icons.emoji_events_outlined,
                  label: 'Kazanılan Ödüller',
                  value: '12',
                ),
                _buildInfoItem(
                  icon: Icons.monetization_on_outlined,
                  label: 'Toplam POI',
                  value: '2,450',
                ),
                _buildInfoItem(
                  icon: Icons.gamepad_outlined,
                  label: 'Toplam Oyun',
                  value: '45',
                ),
                _buildInfoItem(
                  icon: Icons.military_tech_outlined,
                  label: 'En Yüksek Sıralama',
                  value: '3. Sıra',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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
}
