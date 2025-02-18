import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileDetailsPage extends StatelessWidget {
  const ProfileDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı bulunamadı')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil Detayları'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          // Debug için
          print('User ID: $userId');
          print('Has data: ${snapshot.hasData}');
          print('Data exists: ${snapshot.data?.exists}');
          print('Data: ${snapshot.data?.data()}');

          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Kullanıcı bilgileri bulunamadı'));
          }

          // Güvenli veri dönüşümü
          final userData =
              (snapshot.data?.data() ?? {}) as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kişisel Bilgiler',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          icon: Icons.person_outline,
                          label: 'Ad Soyad',
                          value:
                              userData['name']?.toString() ?? 'Belirtilmemiş',
                        ),
                        const Divider(),
                        _buildInfoItem(
                          icon: Icons.alternate_email,
                          label: 'Kullanıcı Adı',
                          value:
                              '@${userData['username']?.toString() ?? 'Belirtilmemiş'}',
                        ),
                        const Divider(),
                        _buildInfoItem(
                          icon: Icons.email_outlined,
                          label: 'E-posta',
                          value:
                              userData['email']?.toString() ?? 'Belirtilmemiş',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oyun İstatistikleri',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          icon: Icons.emoji_events_outlined,
                          label: 'Kazanılan Ödüller',
                          value: userData['totalPrizeCount']?.toString() ?? '0',
                        ),
                        const Divider(),
                        _buildInfoItem(
                          icon: Icons.monetization_on_outlined,
                          label: 'Toplam POI',
                          value: userData['poiBalance']?.toString() ?? '0',
                        ),
                        const Divider(),
                        _buildInfoItem(
                          icon: Icons.gamepad_outlined,
                          label: 'Toplam Oyun',
                          value: userData['totalGames']?.toString() ?? '0',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
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
