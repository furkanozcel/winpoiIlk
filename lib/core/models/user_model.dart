import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final int poiBalance;
  final int totalPrizeCount;
  final int totalGames;
  final int successPoints;
  final DateTime createdAt;
  final String role;
  final String? phoneNumber;
  final String? profilePicture;
  final String? address;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.poiBalance,
    required this.totalPrizeCount,
    required this.totalGames,
    required this.successPoints,
    required this.createdAt,
    this.role = 'user',
    this.phoneNumber,
    this.profilePicture,
    this.address,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      poiBalance: map['poiBalance'] ?? 0,
      totalPrizeCount: map['totalPrizeCount'] ?? 0,
      totalGames: map['totalGames'] ?? 0,
      successPoints: map['successPoints'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      role: map['role'] ?? 'user',
      phoneNumber: map['phoneNumber'],
      profilePicture: map['profilePicture'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'poiBalance': poiBalance,
      'totalPrizeCount': totalPrizeCount,
      'totalGames': totalGames,
      'successPoints': successPoints,
      'createdAt': createdAt,
      'role': role,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'address': address,
    };
  }
}
