import 'package:cloud_firestore/cloud_firestore.dart';

class Competition {
  final String id;
  final String title;
  final String description;
  final String prize;
  final DateTime dateTime;
  final double entryFee;
  final String imageUrl;
  final int participantCount;
  final bool isActive;
  final String status;

  Competition({
    required this.id,
    required this.title,
    required this.description,
    required this.prize,
    required this.dateTime,
    required this.entryFee,
    required this.imageUrl,
    this.participantCount = 0,
    this.isActive = false,
    this.status = 'upcoming',
  });

  factory Competition.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Competition(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      prize: data['prize'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      entryFee: (data['entryFee'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      participantCount: data['participantCount'] ?? 0,
      isActive: data['isActive'] ?? false,
      status: data['status'] ?? 'upcoming',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'prize': prize,
      'dateTime': Timestamp.fromDate(dateTime),
      'entryFee': entryFee,
      'imageUrl': imageUrl,
      'participantCount': participantCount,
      'isActive': isActive,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
