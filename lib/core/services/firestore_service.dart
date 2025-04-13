import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:winpoi/core/models/user_model.dart';
import 'package:winpoi/features/home_page/data/models/competition.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı profili oluştur/güncelle
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    // Username varsa ve değiştiyse, önce kullanılabilirliğini kontrol et
    if (data.containsKey('username')) {
      final isAvailable = await isUsernameAvailable(data['username']);
      if (!isAvailable) {
        throw 'Bu kullanıcı adı zaten kullanımda';
      }
    }

    await _firestore.collection('users').doc(userId).set(
          data,
          SetOptions(merge: true),
        );
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

  // Yarışma koleksiyonu referansı
  final _competitionsRef =
      FirebaseFirestore.instance.collection('competitions');

  // Yeni yarışma ekleme
  Future<void> addCompetition(Competition competition) async {
    try {
      await _competitionsRef.add(competition.toFirestore());
    } catch (e) {
      throw Exception('Yarışma eklenirken hata oluştu: $e');
    }
  }

  // Yarışma güncelleme
  Future<void> updateCompetition(String id, Map<String, dynamic> data) async {
    try {
      await _competitionsRef.doc(id).update(data);
    } catch (e) {
      throw Exception('Yarışma güncellenirken hata oluştu: $e');
    }
  }

  // Yarışma silme
  Future<void> deleteCompetition(String id) async {
    try {
      await _competitionsRef.doc(id).delete();
    } catch (e) {
      throw Exception('Yarışma silinirken hata oluştu: $e');
    }
  }

  // Tüm yarışmaları getir
  Stream<List<Competition>> getCompetitions() {
    return _competitionsRef
        .where('endTime', isGreaterThan: Timestamp.now())
        .orderBy('endTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Competition.fromFirestore(doc))
            .toList());
  }

  // Aktif yarışmaları getir (endTime'ı gelmemiş olanlar)
  Stream<List<Competition>> getActiveCompetitions() {
    return _competitionsRef
        .where('endTime', isGreaterThan: Timestamp.now())
        .orderBy('endTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Competition.fromFirestore(doc))
            .toList());
  }

  // Gelecek yarışmaları getir (endTime'ı gelmemiş olanlar)
  Stream<List<Competition>> getUpcomingCompetitions() {
    return _competitionsRef
        .where('endTime', isGreaterThan: Timestamp.now())
        .orderBy('endTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Competition.fromFirestore(doc))
            .toList());
  }

  // Biten yarışmaları sil
  Future<void> deleteExpiredCompetitions() async {
    try {
      final now = Timestamp.now();
      final expiredCompetitions =
          await _competitionsRef.where('endTime', isLessThan: now).get();

      for (var doc in expiredCompetitions.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Biten yarışmalar silinirken hata oluştu: $e');
    }
  }

  // Username kontrolü için yeni metod
  Future<bool> isUsernameAvailable(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  // Kullanıcı adına göre kullanıcı getirme metodu
  Future<UserModel?> getUserByUsername(String username) async {
    final doc = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (doc.docs.isEmpty) return null;

    return UserModel.fromMap(doc.docs.first.id, doc.docs.first.data());
  }

  Future<void> incrementParticipantCount(String competitionId) async {
    try {
      await _firestore.collection('competitions').doc(competitionId).update({
        'participantCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Katılımcı sayısı güncellenirken hata oluştu: $e');
    }
  }
}
