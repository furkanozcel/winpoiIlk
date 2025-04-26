import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get leaderboardData => _leaderboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Genel liderlik tablosunu yükle
  Future<void> loadGlobalLeaderboard() async {
    _setLoading(true);
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('totalPrizeCount', descending: true)
          .limit(20)
          .get();

      _leaderboardData = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'userId': doc.id,
          'username': data['username'] ?? 'Kullanıcı',
          'totalPrizeCount': data['totalPrizeCount'] ?? 0,
          'poiBalance': data['poiBalance'] ?? 0,
          'totalGames': data['totalGames'] ?? 0,
        };
      }).toList();

      _error = null;
    } catch (e) {
      _error = "Liderlik tablosu yüklenirken hata oluştu: $e";
      _leaderboardData = [];
    } finally {
      _setLoading(false);
    }
  }

  // Belirli bir yarışma için liderlik tablosunu yükle
  Future<void> loadContestLeaderboard(String contestId) async {
    _setLoading(true);
    try {
      // Yarışma katılımlarını al
      final QuerySnapshot participations = await FirebaseFirestore.instance
          .collectionGroup('participations')
          .where('competitionId', isEqualTo: contestId)
          .orderBy('bestTime')
          .limit(20)
          .get();

      // Kullanıcı bilgilerini getir
      List<Map<String, dynamic>> leaderboard = [];
      for (var doc in participations.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = doc.reference.parent.parent!.id;

        // Kullanıcı bilgilerini al
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          leaderboard.add({
            'userId': userId,
            'username': userData['username'] ?? 'Kullanıcı',
            'bestTime': data['bestTime'] ?? 0,
            'lastPlayedAt': data['lastPlayedAt'],
          });
        }
      }

      _leaderboardData = leaderboard;
      _error = null;
    } catch (e) {
      _error = "Yarışma liderlik tablosu yüklenirken hata oluştu: $e";
      _leaderboardData = [];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
