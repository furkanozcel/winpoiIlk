import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameHistoryPage extends StatelessWidget {
  const GameHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('gameHistory')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final games = snapshot.data!.docs;

          if (games.isEmpty) {
            return const Center(
              child: Text('Henüz oyun geçmişiniz bulunmuyor'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index].data() as Map<String, dynamic>;
              return _buildGameHistoryCard(
                date: (game['date'] as Timestamp).toDate(),
                gameName: game['gameName'] ?? '',
                result: game['result'] ?? '',
                prize: game['prize'],
                earnedPoi: (game['earnedPoi'] ?? 0).toDouble(),
                rank: game['rank'] ?? 0,
                totalParticipants: game['totalParticipants'] ?? 0,
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
    required dynamic prize,
    required double earnedPoi,
    required int rank,
    required int totalParticipants,
  }) {
    final bool isWinner = result == 'Kazandın!';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isWinner
              ? const Color(0xFFFF6600).withOpacity(0.2)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isWinner
                ? const Color(0xFFFF6600).withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: isWinner
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF6600).withOpacity(0.12),
                        const Color(0xFFFF6600).withOpacity(0.05),
                      ],
                    )
                  : null,
              color: !isWinner ? Colors.grey.shade50 : null,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isWinner
                            ? const Color(0xFFFF6600).withOpacity(0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: isWinner
                            ? const Color(0xFFFF6600)
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        color: isWinner
                            ? const Color(0xFFFF6600)
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isWinner
                        ? LinearGradient(
                            colors: [
                              const Color(0xFFFF6600),
                              const Color(0xFFFF6600).withOpacity(0.9),
                            ],
                          )
                        : null,
                    color: !isWinner ? Colors.grey.shade200 : null,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: isWinner
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF6600).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    result,
                    style: TextStyle(
                      color: isWinner ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  gameName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWinner ? 22 : 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: isWinner
                        ? const Color(0xFFFF6600)
                        : Colors.black.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF6600).withOpacity(0.12),
                        const Color(0xFFFF6600).withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF6600).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6600).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.currency_lira,
                          size: 20,
                          color: Color(0xFFFF6600),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '+$earnedPoi POI',
                        style: TextStyle(
                          color: const Color(0xFFFF6600),
                          fontWeight: FontWeight.w800,
                          fontSize: isWinner ? 20 : 18,
                          letterSpacing: -0.5,
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
