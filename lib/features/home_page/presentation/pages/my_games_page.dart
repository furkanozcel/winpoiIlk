import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;
import 'package:winpoi/features/home_page/presentation/widgets/countdown_timer.dart';
import 'package:winpoi/features/home_page/data/models/competition.dart';

enum GameStatus {
  active,
  completed,
  expired,
}

class MyGamesPage extends StatefulWidget {
  const MyGamesPage({super.key});

  @override
  State<MyGamesPage> createState() => _MyGamesPageState();
}

class _MyGamesPageState extends State<MyGamesPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_provider.AuthProvider>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: authProvider.currentUser != null
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(authProvider.currentUser!.uid)
              .collection('participations')
              .snapshots()
          : null,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Bir hata oluştu: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text(
              'Oyunlarınız yükleniyor...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.gamepad_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Oynamakta olduğunuz oyun yoktur',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Katıldığınız oyunlar burada görünecek',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            // Yarışmaları sırala
            final sortedDocs = snapshot.data!.docs.toList()
              ..sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                // Önce biten yarışmaları en alta al
                final aEndTime = (aData['endTime'] as Timestamp).toDate();
                final bEndTime = (bData['endTime'] as Timestamp).toDate();
                final aRemainingTime = aEndTime.difference(DateTime.now());
                final bRemainingTime = bEndTime.difference(DateTime.now());

                if (aRemainingTime.isNegative && !bRemainingTime.isNegative)
                  return 1;
                if (!aRemainingTime.isNegative && bRemainingTime.isNegative)
                  return -1;

                // Sonra hakkı kalmayan yarışmaları en alta al
                final aRemainingAttempts = aData['remainingAttempts'] as int;
                final bRemainingAttempts = bData['remainingAttempts'] as int;

                if (aRemainingAttempts == 0 && bRemainingAttempts > 0) return 1;
                if (aRemainingAttempts > 0 && bRemainingAttempts == 0)
                  return -1;

                // Son olarak katılım zamanına göre sırala (en son katılan en üstte)
                final aJoinedAt = aData['joinedAt'] as Timestamp?;
                final bJoinedAt = bData['joinedAt'] as Timestamp?;

                if (aJoinedAt == null && bJoinedAt == null) return 0;
                if (aJoinedAt == null) return 1;
                if (bJoinedAt == null) return -1;

                return bJoinedAt.compareTo(aJoinedAt);
              });

            final game = sortedDocs[index];
            final data = game.data() as Map<String, dynamic>;
            final endTime = (data['endTime'] as Timestamp).toDate();
            final remainingTime = endTime.difference(DateTime.now());
            final remainingAttempts = data['remainingAttempts'] as int;

            if (!_isWithinGracePeriod(remainingTime)) {
              return const SizedBox.shrink();
            }

            final isCompetitionEnded = _isCompetitionEnded(remainingTime);

            return Stack(
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD4F4F1), // Daha belirgin Soft Turkuaz
                          Color(0xFFE6D4F4), // Daha belirgin Soft Mor
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ECDC4).withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  data['competitionTitle'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3436),
                                  ),
                                ),
                              ),
                              if (!isCompetitionEnded)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE28B33)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE28B33)
                                            .withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.refresh,
                                          size: 16, color: Color(0xFFE28B33)),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$remainingAttempts Hak',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFE28B33),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE28B33).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color:
                                      const Color(0xFFE28B33).withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer,
                                    size: 20, color: Color(0xFFE28B33)),
                                const SizedBox(width: 8),
                                DefaultTextStyle(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE28B33),
                                  ),
                                  child: CountdownTimer(
                                    endTime: endTime,
                                    isCompetitionEnded: isCompetitionEnded,
                                    color: const Color(0xFFE28B33),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (isCompetitionEnded)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.leaderboard_rounded,
                                        color: Color(0xFF5FC9BF)),
                                    label: const Text(
                                      'Sonucu Göster',
                                      style: TextStyle(
                                        color: Color(0xFF5FC9BF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFF5FC9BF), width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(
                                                      0xFFD4F4F1), // Soft turkuaz
                                                  Color(0xFFE6D4F4), // Soft mor
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF4ECDC4)
                                                      .withOpacity(0.2),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: const Icon(
                                                    Icons.map_rounded,
                                                    color: Color(0xFF2D3436),
                                                    size: 32,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                const Text(
                                                  'Haritayı Gör',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF2D3436),
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Icon(Icons.map_rounded,
                                                    size: 80,
                                                    color: Color(0xFF5FC9BF)),
                                                const SizedBox(height: 16),
                                                const Text(
                                                  'Bu yarışmanın oynandığı harita burada gösterilecek. (Şu an temsili harita)',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF2D3436),
                                                    height: 1.4,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(
                                                            0xFFFFB088), // Soft but vibrant orange light
                                                        Color(
                                                            0xFFE28B33), // Soft but vibrant orange dark
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(
                                                                0xFFE28B33)
                                                            .withOpacity(0.35),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shadowColor:
                                                          Colors.transparent,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Kapat',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.map_rounded,
                                        color: Color(0xFF5FC9BF)),
                                    label: const Text(
                                      'Haritayı Gör',
                                      style: TextStyle(
                                        color: Color(0xFF5FC9BF),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFF5FC9BF), width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                SizedBox(
                                  width: 160,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFD4F4F1), // Soft turkuaz
                                          Color(0xFFE6D4F4), // Soft mor
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4ECDC4)
                                              .withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.leaderboard_rounded,
                                              size: 16,
                                              color: Color(0xFF2D3436),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Sıralamayı Göster',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2D3436),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: remainingAttempts > 0
                                            ? const [
                                                Color(0xFF4ECDC4), // Turkuaz
                                                Color(0xFF845EC2), // Mor
                                              ]
                                            : [
                                                Colors.grey.shade300,
                                                Colors.grey.shade400,
                                              ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: remainingAttempts > 0
                                            ? Colors.white.withOpacity(0.5)
                                            : Colors.grey.shade400
                                                .withOpacity(0.5),
                                        width: 1,
                                      ),
                                      boxShadow: remainingAttempts > 0
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF4ECDC4)
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: remainingAttempts > 0
                                          ? () => _replayGame({
                                                ...data,
                                                'id': game.id,
                                              })
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.replay_rounded,
                                              size: 16,
                                              color: remainingAttempts > 0
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            remainingAttempts > 0
                                                ? 'Tekrar Oyna'
                                                : 'Hakkınız Kalmadı',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: remainingAttempts > 0
                                                  ? Colors.white
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isWithinGracePeriod(Duration remainingTime) {
    return remainingTime.inMinutes > -15;
  }

  bool _isCompetitionEnded(Duration remainingTime) {
    return remainingTime.isNegative;
  }

  Future<void> _replayGame(Map<String, dynamic> game) async {
    try {
      final authProvider =
          Provider.of<app_provider.AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Onay kutusunu göster
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFD4F4F1), // Soft turkuaz
                  Color(0xFFE6D4F4), // Soft mor
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.replay_rounded,
                    color: Color(0xFFE28B33), // Turuncu renk
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Oyuna Gir',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bu oyuna tekrar girmek istediğinize emin misiniz?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2D3436),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'İptal',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFB088), // Soft but vibrant orange light
                            Color(0xFFE28B33), // Soft but vibrant orange dark
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE28B33).withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Oyna',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (confirmed != true) return;

      // Önce katılım dokümanını kontrol et
      final participationDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('participations')
          .doc(game['id'])
          .get();

      if (!participationDoc.exists) {
        throw Exception('Katılım kaydı bulunamadı');
      }

      final participationData = participationDoc.data() as Map<String, dynamic>;
      final remainingAttempts = participationData['remainingAttempts'] as int;

      if (remainingAttempts <= 0) {
        throw Exception('Kalan hak sayınız yetersiz');
      }

      // Yarışmanın durumunu kontrol et
      final competitionDoc = await FirebaseFirestore.instance
          .collection('competitions')
          .doc(game['competitionId'])
          .get();

      if (!competitionDoc.exists) {
        throw Exception('Yarışma bulunamadı');
      }

      final competitionData = competitionDoc.data() as Map<String, dynamic>;
      final competitionEndTime =
          (competitionData['endTime'] as Timestamp).toDate();

      if (DateTime.now().isAfter(competitionEndTime)) {
        throw Exception('Bu yarışma süresi dolmuş');
      }

      // Katılım dokümanını güncelle
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('participations')
          .doc(game['id'])
          .update({
        'remainingAttempts': FieldValue.increment(-1),
        'lastPlayedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oyun başlatılıyor...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildGameCard(Map<String, dynamic> game) {
    final competition = game['competition'] as Competition;
    final participation = game['participation'] as Map<String, dynamic>;
    final remainingAttempts = participation['remainingAttempts'] ?? 0;
    final endTime = (participation['endTime'] as Timestamp).toDate();
    final isActive = endTime.isAfter(DateTime.now());
    final status = _getGameStatus(endTime, remainingAttempts);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Oyun Resmi ve Durum Etiketi
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      competition.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFF4ECDC4),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Durum Etiketi
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
                  // Oyun Başlığı
                  Text(
                    competition.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Bilgi Satırları
                  _buildInfoRow(
                    Icons.timer_outlined,
                    'Kalan Süre',
                    _getCountdownText(endTime),
                    const Color(0xFF4ECDC4),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.games_outlined,
                    'Kalan Hak',
                    '$remainingAttempts',
                    const Color(0xFF845EC2),
                  ),
                  const SizedBox(height: 16),
                  // Devam Et Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isActive ? () => _continueGame(game) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? const Color(0xFF4ECDC4)
                            : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isActive ? 'Devam Et' : 'Süresi Doldu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getStatusText(GameStatus status) {
    switch (status) {
      case GameStatus.active:
        return 'Aktif';
      case GameStatus.completed:
        return 'Tamamlandı';
      case GameStatus.expired:
        return 'Süresi Doldu';
    }
  }

  Color _getStatusColor(GameStatus status) {
    switch (status) {
      case GameStatus.active:
        return const Color(0xFF4ECDC4);
      case GameStatus.completed:
        return const Color(0xFF845EC2);
      case GameStatus.expired:
        return Colors.grey.shade600;
    }
  }

  GameStatus _getGameStatus(DateTime endTime, int remainingAttempts) {
    if (!endTime.isAfter(DateTime.now())) {
      return GameStatus.expired;
    }
    if (remainingAttempts <= 0) {
      return GameStatus.completed;
    }
    return GameStatus.active;
  }

  String _getCountdownText(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return 'Süresi Doldu';
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(difference.inHours);
    final minutes = twoDigits(difference.inMinutes.remainder(60));
    final seconds = twoDigits(difference.inSeconds.remainder(60));

    return '$hours:$minutes:$seconds';
  }

  void _continueGame(Map<String, dynamic> game) {
    // Oyunu devam ettirme mantığı
    final competition = game['competition'] as Competition;
    // TODO: Oyun sayfasına yönlendirme
  }
}
