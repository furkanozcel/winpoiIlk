import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı profili oluştur/güncelle
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set(
            data,
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Profil güncelleme hatası: $e');
    }
  }

  // Kullanıcı profilini getir
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Profil getirme hatası: $e');
    }
  }

  // Yarışmaları getir
  Stream<QuerySnapshot> getCompetitions() {
    return _firestore
        .collection('competitions')
        .orderBy('dateTime', descending: true)
        .snapshots();
  }
}
