import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:winpoi/features/home_page/data/models/competition.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Örnek veri
    final competitions = [
      Competition(
        id: '1',
        title: 'iPhone 15 Pro Yarışması',
        description:
            'Şehrin en heyecanlı hazine avında iPhone 15 Pro senin olsun! 🎮',
        prize: 'iPhone 15 Pro',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        entryFee: 49.99,
        imageUrl: 'https://example.com/iphone15.jpg',
        participantCount: 156,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('WinPoi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Bildirimler sayfasına yönlendirme
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: competitions.length,
        itemBuilder: (context, index) {
          return CompetitionCard(competition: competitions[index]);
        },
      ),
    );
  }
}

class CompetitionCard extends StatelessWidget {
  final Competition competition;

  const CompetitionCard({
    super.key,
    required this.competition,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yarışma Görseli
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    competition.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.orange.shade100,
                        child: const Center(
                          child: Icon(
                            Icons.emoji_events,
                            size: 50,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${competition.participantCount} Katılımcı',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ödül
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🎁 ${competition.prize}',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Yarışma Başlığı
                Text(
                  competition.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Yarışma Açıklaması
                Text(
                  competition.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                // Tarih ve Saat
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy HH:mm')
                          .format(competition.dateTime),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Katılım Ücreti ve Katıl Butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Katılım Ücreti',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${competition.entryFee.toStringAsFixed(2)} ₺',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Katıl butonuna basıldığında yapılacak işlemler
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'KATIL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
