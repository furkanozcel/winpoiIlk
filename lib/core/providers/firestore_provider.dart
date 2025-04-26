import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;
import 'package:winpoi/core/services/firestore_service.dart';
import 'package:winpoi/features/home_page/data/models/competition.dart';

class FirestoreProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final app_provider.AuthProvider _authProvider;
  bool _isLoading = false;

  FirestoreProvider({app_provider.AuthProvider? authProvider})
      : _authProvider = authProvider ?? app_provider.AuthProvider();

  bool get isLoading => _isLoading;

  // Kullanıcı profili güncelleme
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    _setLoading(true);
    try {
      await _firestoreService.updateUserProfile(
        userId: userId,
        data: data,
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı profili getirme
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    _setLoading(true);
    try {
      return await _firestoreService.getUserProfile(userId);
    } finally {
      _setLoading(false);
    }
  }

  // Yarışmaya katılma
  Future<void> joinCompetition(Competition competition) async {
    _setLoading(true);
    try {
      final user = _authProvider.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      // Kullanıcının bu yarışmaya daha önce katılıp katılmadığını kontrol et
      final participationDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('participations')
          .doc(competition.id)
          .get();

      if (participationDoc.exists) {
        throw Exception('Bu yarışmaya zaten katıldınız');
      }

      // Yarışmaya katılımı kaydet - ilk hak kullanılmış olarak başlat
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('participations')
          .doc(competition.id)
          .set({
        'competitionId': competition.id,
        'competitionTitle': competition.title,
        'prizeImage': competition.image,
        'endTime': competition.endTime,
        'remainingAttempts':
            2, // Toplam 3 haktan 1'i kullanılmış olarak başlıyor
        'lastPlayedAt':
            FieldValue.serverTimestamp(), // İlk oyun zamanını kaydet
        'bestTime': null,
      });

      // Toplam oyun sayısını 1 artır
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final int totalGames = (userData['totalGames'] ?? 0) + 1;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'totalGames': totalGames,
        });
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Yeni yarışma ekleme
  Future<void> addCompetition(Competition competition) async {
    _setLoading(true);
    try {
      await _firestoreService.addCompetition(competition);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Yarışma güncelleme
  Future<void> updateCompetition(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _firestoreService.updateCompetition(id, data);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Aktif yarışmaları getir
  Stream<List<Competition>> getActiveCompetitions() {
    final now = DateTime.now();
    return FirebaseFirestore.instance
        .collection('competitions')
        .where('endTime', isGreaterThan: now)
        .orderBy('endTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Competition.fromFirestore(doc))
          .toList();
    });
  }

  // Süresi dolmuş yarışmaları temizle
  Future<void> deleteExpiredCompetitions() async {
    _setLoading(true);
    try {
      final now = DateTime.now();
      final snapshot = await FirebaseFirestore.instance
          .collection('competitions')
          .where('endTime', isLessThan: now)
          .get();

      // Batch işlemi başlat
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Batch işlemini çalıştır
      await batch.commit();
      notifyListeners();
    } catch (e) {
      print('Yarışmaları temizleme hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
