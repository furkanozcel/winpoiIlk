import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:winpoi/core/services/auth_service.dart';
import '../errors/async_error_handler.dart';
import '../errors/app_exception.dart';
import '../errors/error_handler.dart';

class AuthProvider extends ChangeNotifier with AsyncErrorHandlerMixin {
  final AuthService _authService = AuthService();
  User? _currentUser;

  AuthProvider() {
    // Otomatik olarak mevcut kullanıcıyı ve auth state değişikliklerini dinle
    _currentUser = _authService.currentUser;
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Email/Password ile giriş
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await runAsync<UserCredential>(() async {
      return await _authService.signInWithEmail(
        email: email,
        password: password,
      );
    });
  }

  // Google ile giriş
  Future<UserCredential?> signInWithGoogle() async {
    return await runAsync<UserCredential>(() async {
      return await _authService.signInWithGoogle();
    });
  }

  // Email/Password ile kayıt
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await runAsync<UserCredential>(() async {
      return await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
    });
  }

  // Çıkış yap
  Future<void> signOut() async {
    await runAsync<void>(() async {
      await _authService.signOut();
    });
  }

  // Şifre sıfırlama
  Future<void> sendPasswordResetEmail({required String email}) async {
    await runAsync<void>(() async {
      await _authService.sendPasswordResetEmail(email: email);
    });
  }

  // Hata durumunda kullanıcı dostu mesaj al
  String? getErrorMessage() {
    if (hasError) {
      return ErrorHandler.getUserFriendlyMessage(error!);
    }
    return null;
  }

  // Retry mekanizması ile giriş
  Future<UserCredential?> signInWithEmailRetry({
    required String email,
    required String password,
    int maxRetries = 2,
  }) async {
    return await runAsyncWithRetry<UserCredential>(
      () => _authService.signInWithEmail(
        email: email,
        password: password,
      ),
      maxRetries: maxRetries,
    );
  }
}
