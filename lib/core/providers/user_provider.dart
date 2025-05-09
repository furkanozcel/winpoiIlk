import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:winpoi/core/providers/auth_provider.dart' as app_provider;

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;
  final app_provider.AuthProvider _authProvider;

  UserProvider({app_provider.AuthProvider? authProvider})
      : _authProvider = authProvider ?? app_provider.AuthProvider() {
    // Constructor'da auth state değişikliklerini dinle
    _authProvider.authStateChanges.listen((user) {
      if (user != null) {
        loadUserData();
      } else {
        _userData = null;
        notifyListeners();
      }
    });
  }

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isProfileComplete {
    if (_userData == null) return false;
    return _userData!['username'] != null &&
        _userData!['username'].toString().isNotEmpty;
  }

  // Kullanıcı bilgilerini yükle
  Future<void> loadUserData() async {
    final user = _authProvider.currentUser;
    if (user == null) {
      _userData = null;
      _error = "Kullanıcı oturumu bulunamadı";
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _userData = doc.data();
        // Eğer successPoints alanı yoksa, ekle
        if (!_userData!.containsKey('successPoints')) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'successPoints': 0});
          _userData!['successPoints'] = 0;
        }
        _error = null;
      } else {
        _userData = null;
        _error = "Kullanıcı profili bulunamadı";
      }
    } catch (e) {
      _error = "Veri yüklenirken hata oluştu: $e";
      _userData = null;
    } finally {
      _setLoading(false);
    }
  }

  // Kullanıcı bilgilerini güncelle
  Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = _authProvider.currentUser;
    if (user == null) {
      _error = "Kullanıcı oturumu bulunamadı";
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      // Kullanıcı adı güncellenmek isteniyorsa, önce özgünlüğünü kontrol et
      if (data.containsKey('username') &&
          data['username'] != _userData?['username']) {
        final usernameExists = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: data['username'])
            .get();

        if (usernameExists.docs.isNotEmpty) {
          throw "Bu kullanıcı adı zaten kullanımda";
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      // Başarılı olursa, local userData'yı güncelle
      _userData = {...?_userData, ...data};
      _error = null;
    } catch (e) {
      _error = "Profil güncellenirken hata oluştu: $e";
    } finally {
      _setLoading(false);
    }
  }

  // Profil resmi güncelleme işlevi buraya eklenecek

  // Kullanıcı istatistiklerini getir
  Future<Map<String, dynamic>> getUserStats() async {
    final user = _authProvider.currentUser;
    if (user == null) {
      return {
        'totalGames': 0,
        'gamesWon': 0,
        'totalPrizeValue': 0,
      };
    }

    _setLoading(true);
    try {
      // Katılınan yarışmaları say
      final participations = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('participations')
          .get();

      // Kazanılan yarışmaları say
      final wins = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wins')
          .get();

      return {
        'totalGames': participations.docs.length,
        'gamesWon': wins.docs.length,
        'totalPrizeValue': _calculateTotalPrizeValue(wins.docs),
      };
    } catch (e) {
      _error = "İstatistikler yüklenirken hata oluştu: $e";
      return {
        'totalGames': 0,
        'gamesWon': 0,
        'totalPrizeValue': 0,
      };
    } finally {
      _setLoading(false);
    }
  }

  int _calculateTotalPrizeValue(List<QueryDocumentSnapshot> wins) {
    int total = 0;
    for (var win in wins) {
      final prizeValue = win.data() as Map<String, dynamic>;
      total += (prizeValue['prizeValue'] as num?)?.toInt() ?? 0;
    }
    return total;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // AuthProvider'ı güncelle (Provider proxy pattern için)
  void updateAuthProvider(app_provider.AuthProvider authProvider) {
    // Eğer aynı instance değilse güncelle
    if (authProvider != _authProvider) {
      // Eski listener'ı kaldır
      // Yeni authProvider'ı kullan
      _authProvider.authStateChanges.listen((user) {
        if (user != null) {
          loadUserData();
        } else {
          _userData = null;
          notifyListeners();
        }
      });
    }
  }
}
