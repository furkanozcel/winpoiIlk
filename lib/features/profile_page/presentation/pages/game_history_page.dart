import 'package:flutter/material.dart';

class GameHistoryPage extends StatelessWidget {
  const GameHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyun Geçmişi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filtreleme seçenekleri
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Örnek veri sayısı
        itemBuilder: (context, index) {
          return _buildGameHistoryCard(
            date: DateTime.now().subtract(Duration(days: index)),
            gameName: 'iPhone 15 Pro Yarışması',
            result: index % 3 == 0 ? 'Kazandın!' : 'Kaybettin',
            prize: index % 3 == 0 ? 'iPhone 15 Pro' : null,
            earnedPoi: (100 - (index * 5)).toDouble(),
            rank: index + 1,
            totalParticipants: 150,
          );
        },
      ),
    );
  }

  Widget _buildGameHistoryCard({
    required DateTime date,
    required String gameName,
    required String result,
    String? prize,
    required double earnedPoi,
    required int rank,
    required int totalParticipants,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // Üst Kısım - Tarih ve Sonuç
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result == 'Kazandın!'
                  ? Colors.green.shade50
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: result == 'Kazandın!'
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result,
                    style: TextStyle(
                      color: result == 'Kazandın!'
                          ? Colors.green.shade700
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Oyun Detayları
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Sıralama ve Katılımcı Sayısı
                Row(
                  children: [
                    Icon(
                      Icons.leaderboard,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$rank. sıra',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalParticipants katılımcı',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Kazanılan Ödül ve POI
                Row(
                  children: [
                    if (prize != null) ...[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.card_giftcard,
                                size: 16,
                                color: Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  prize,
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+$earnedPoi POI',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
