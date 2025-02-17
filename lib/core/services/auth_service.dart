import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Kullanıcı durumu değişikliklerini dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password ile kayıt
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Kayıt olma hatası: $e');
    }
  }

  // Email/Password ile giriş
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Giriş yapma hatası: $e');
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Çıkış yapma hatası: $e');
    }
  }
}
