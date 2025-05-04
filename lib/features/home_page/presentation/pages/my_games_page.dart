import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;
import 'package:winpoi/features/home_page/presentation/widgets/countdown_timer.dart';

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
                          Color(0xFFE6F7F6),
                          Color(0xFFF8F9FA),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5FC9BF).withOpacity(0.15),
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
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF8156A0),
                                    Color(0xFF8156A0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8156A0)
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Sonucu Göster',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF8156A0),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Sıralamayı Göster',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: remainingAttempts > 0
                                          ? const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Color(0xFF5FC9BF),
                                                Color(0xFFE28B33),
                                              ],
                                            )
                                          : const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Color(0xFFCCCCCC),
                                                Color(0xFF999999),
                                              ],
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: remainingAttempts > 0
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF5FC9BF)
                                                    .withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: remainingAttempts > 0
                                          ? () => _playGame(
                                              game.id, remainingAttempts)
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
                                      child: Text(
                                        remainingAttempts > 0
                                            ? 'Tekrar Oyna'
                                            : 'Hakkınız Kalmadı',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: remainingAttempts > 0
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.7),
                                        ),
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

  Future<void> _playGame(String participationId, int remainingAttempts) async {
    if (remainingAttempts <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kalan oyun hakkınız bulunmuyor!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authProvider =
          Provider.of<app_provider.AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('participations')
          .doc(participationId)
          .update({
        'remainingAttempts': remainingAttempts - 1,
        'lastPlayedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              remainingAttempts - 1 > 0
                  ? 'Oyun başlatılıyor... Kalan hak: ${remainingAttempts - 1}'
                  : 'Son hakkınızı kullandınız! Oyun başlatılıyor...',
            ),
            backgroundColor:
                remainingAttempts - 1 > 0 ? Colors.green : Colors.orange,
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
}
