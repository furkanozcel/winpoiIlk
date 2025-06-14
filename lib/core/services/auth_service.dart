import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    // ClientId kullanmıyoruz, bu hataya neden olabiliyor
  );

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
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code, e.message);
    } catch (e) {
      throw ErrorHandler.handleError(e);
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
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code, e.message);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Google ile giriş
  Future<UserCredential> signInWithGoogle() async {
    try {
      print("Google Sign-In başlatılıyor...");

      // Önce mevcut oturumları temizle
      await _googleSignIn.signOut();

      // Google ile oturum açma işlemi başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google Sign-In iptal edildi: Kullanıcı işlemi iptal etti");
        throw const AuthException(
          message: 'Google oturum açma işlemi iptal edildi',
          code: 'sign_in_canceled',
        );
      }

      try {
        print("Google authentication başlatılıyor: ${googleUser.email}");
        // Google oturum açma bilgilerini al
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Token bilgilerini kontrol et (güvenlik için sadece ilk 10 karakter)
        if (googleAuth.accessToken != null) {
          print(
              "Access Token alındı: ${googleAuth.accessToken!.substring(0, min(10, googleAuth.accessToken!.length))}...");
        } else {
          print("Access Token alınamadı!");
        }

        if (googleAuth.idToken != null) {
          print(
              "ID Token alındı: ${googleAuth.idToken!.substring(0, min(10, googleAuth.idToken!.length))}...");
        } else {
          print("ID Token alınamadı!");
        }

        // Her iki token da null ise hata fırlat
        if (googleAuth.accessToken == null && googleAuth.idToken == null) {
          throw const AuthException(
            message: 'Google kimlik bilgileri alınamadı',
            code: 'invalid-credential',
          );
        }

        // Google kimlik bilgilerini Firebase'e gönder
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print("Firebase ile oturum açılıyor...");
        // Firebase Authentication ile oturum aç
        final userCredential = await _auth.signInWithCredential(credential);
        print("Firebase oturumu açıldı: ${userCredential.user?.uid}");

        // Kullanıcı veritabanında var mı kontrol et, yoksa oluştur
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          print("Yeni kullanıcı Firestore'a kaydediliyor...");
          await _createUserDocument(userCredential.user!);
          print("Kullanıcı Firestore'a kaydedildi");
        } else {
          print("Mevcut kullanıcı, Firestore kaydı gerekmiyor");
        }

        return userCredential;
      } on FirebaseAuthException catch (e) {
        print('Google authentication error: $e');
        throw AuthException.fromFirebaseCode(e.code, e.message);
      } catch (e) {
        print('Google authentication error: $e');
        throw ErrorHandler.handleError(e);
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      print('Google sign-in error: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  // Kullanıcı dokümanı oluştur
  Future<void> _createUserDocument(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'username': '',
        'poiBalance': 0,
        'totalPrizeCount': 0,
        'totalGames': 0,
        'successPoints': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
    } on FirebaseException catch (e) {
      throw DatabaseException.fromFirestoreCode(e.code, e.message);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Google oturumunu kapat
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code, e.message);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  // Şifre sıfırlama e-postası gönder
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code, e.message);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}

// Yardımcı fonksiyon
int min(int a, int b) {
  return a < b ? a : b;
}
