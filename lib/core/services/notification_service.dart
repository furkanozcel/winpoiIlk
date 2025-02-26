import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotificationToAllUsers({
    required String title,
    required String message,
    required String type,
  }) async {
    // Tüm kullanıcıların ID'lerini al
    final usersSnapshot = await _firestore.collection('users').get();

    // Her kullanıcı için bildirim ekle
    for (var userDoc in usersSnapshot.docs) {
      await _firestore
          .collection('users')
          .doc(userDoc.id)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }
}
