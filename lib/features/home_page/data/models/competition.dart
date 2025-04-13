import 'package:cloud_firestore/cloud_firestore.dart';

class Competition {
  final String id;
  final String title;
  final String description;
  final double entryFee;
  final DateTime endTime;
  final String image;
  final int participantCount;

  Competition({
    required this.id,
    required this.title,
    required this.description,
    required this.entryFee,
    required this.endTime,
    required this.image,
    this.participantCount = 0,
  });

  factory Competition.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Competition(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      entryFee: (data['entryFee'] ?? 0).toDouble(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      image: data['image'] ?? '',
      participantCount: data['participantCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'entryFee': entryFee,
      'endTime': Timestamp.fromDate(endTime),
      'image': image,
      'participantCount': participantCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isActive => DateTime.now().isBefore(endTime);
}
