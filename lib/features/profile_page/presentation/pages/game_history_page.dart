import 'package:flutter/material.dart';

class GameHistoryPage extends StatelessWidget {
  const GameHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> gameNames = [
      'MacBook Pro M3 Yarışması',
      'Samsung S24 Ultra Yarışması',
      'PlayStation 5 Yarışması',
      'iPad Pro M2 Yarışması',
      'Asus ROG Gaming Laptop Yarışması',
      'iPhone 15 Pro Max Yarışması',
      'Dell XPS 15 Yarışması',
      'Nintendo Switch OLED Yarışması',
      'AirPods Pro 2 Yarışması',
      'MSI Titan GT77 Yarışması',
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Oyun Geçmişi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFFF6600),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: gameNames.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildGameHistoryCard(
                    date: DateTime.now().subtract(Duration(days: index)),
                    gameName: gameNames[index],
                    result: index % 3 == 0 ? 'Kazandın!' : 'Kaybettin',
                    earnedPoi: (100 - (index * 5)).toDouble(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGameHistoryCard({
    required DateTime date,
    required String gameName,
    required String result,
    required double earnedPoi,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Üst Kısım - Tarih ve Sonuç
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: result == 'Kazandın!'
                  ? const Color(0xFFFF6600).withOpacity(0.08)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: result == 'Kazandın!'
                            ? const Color(0xFFFF6600).withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: result == 'Kazandın!'
                            ? const Color(0xFFFF6600)
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        color: result == 'Kazandın!'
                            ? const Color(0xFFFF6600)
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: result == 'Kazandın!'
                        ? const Color(0xFFFF6600)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: result == 'Kazandın!'
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF6600).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    result,
                    style: TextStyle(
                      color: result == 'Kazandın!'
                          ? Colors.white
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Oyun Detayları
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Kazanılan POI
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6600).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFF6600).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6600).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.currency_lira,
                          size: 18,
                          color: Color(0xFFFF6600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '+$earnedPoi POI',
                        style: const TextStyle(
                          color: Color(0xFFFF6600),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
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
