import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  final bool isCompetitionEnded;

  const CountdownTimer({
    super.key,
    required this.endTime,
    required this.isCompetitionEnded,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.endTime.difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingTime = widget.endTime.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours.abs());
    final minutes = twoDigits(duration.inMinutes.remainder(60).abs());
    final seconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.isCompetitionEnded
          ? 'Sonuçlar Yükleniyor...'
          : _formatDuration(_remainingTime),
      style: TextStyle(
        color:
            widget.isCompetitionEnded ? Colors.grey : const Color(0xFFFF6600),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class MyGamesPage extends StatefulWidget {
  const MyGamesPage({super.key});

  @override
  State<MyGamesPage> createState() => _MyGamesPageState();
}

class _MyGamesPageState extends State<MyGamesPage> {
  Timer? _timer;
  Map<String, Duration> _remainingTimes = {};

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Her saniye kalan süreleri güncelle
        _remainingTimes = _remainingTimes.map((key, value) {
          return MapEntry(key, value - const Duration(seconds: 1));
        });
      }
    });
  }

  Future<void> _playGame(
      BuildContext context, String gameId, int remainingAttempts) async {
    if (remainingAttempts <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu yarışma için hakkınız kalmadı!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('participations')
          .doc(gameId)
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseAuth.instance.currentUser != null
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('participations')
              .snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Bir hata oluştu: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                  'Henüz Bir Oyuna Katılmadınız',
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

        // Yeni veri geldiğinde kalan süreleri güncelle
        snapshot.data!.docs.forEach((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final endTime = (data['endTime'] as Timestamp).toDate();
          _remainingTimes[doc.id] = endTime.difference(DateTime.now());
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final game = snapshot.data!.docs[index];
            final data = game.data() as Map<String, dynamic>;
            final remainingTime = _remainingTimes[game.id] ?? Duration.zero;
            final remainingAttempts = data['remainingAttempts'] as int;

            // Yarışma bitiminden sonraki 15 dakika kontrolü
            final isWithinGracePeriod = remainingTime.inMinutes > -15;

            if (!isWithinGracePeriod) {
              return const SizedBox.shrink();
            }

            final isCompetitionEnded = remainingTime.isNegative;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Opacity(
                opacity:
                    (remainingAttempts > 0 && !isCompetitionEnded) ? 1.0 : 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              data['prizeImage'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['competitionTitle'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isCompetitionEnded
                                          ? 'Yarışma Sona Erdi'
                                          : 'Kalan Hak: $remainingAttempts',
                                      style: TextStyle(
                                        color: isCompetitionEnded
                                            ? Colors.red
                                            : (remainingAttempts > 0
                                                ? Colors.grey.shade600
                                                : Colors.red),
                                        fontSize: 14,
                                        fontWeight: isCompetitionEnded ||
                                                remainingAttempts == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    CountdownTimer(
                                      endTime: (data['endTime'] as Timestamp)
                                          .toDate(),
                                      isCompetitionEnded: isCompetitionEnded,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (remainingAttempts > 0 &&
                                  !isCompetitionEnded)
                              ? () =>
                                  _playGame(context, game.id, remainingAttempts)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (remainingAttempts > 0 && !isCompetitionEnded)
                                    ? const Color(0xFFFF6600)
                                    : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isCompetitionEnded
                                ? 'Yarışma Sona Erdi'
                                : (remainingAttempts > 0
                                    ? 'Oyna'
                                    : 'Hakkınız Bitti'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  (remainingAttempts > 0 && !isCompetitionEnded)
                                      ? Colors.white
                                      : Colors.white70,
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
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
