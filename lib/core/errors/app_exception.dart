// WinPoi Uygulaması için özel exception sınıfları

abstract class AppException implements Exception {
  final String message;
  final String code;
  final String? details;

  const AppException({
    required this.message,
    required this.code,
    this.details,
  });

  @override
  String toString() => message;
}

// Kimlik doğrulama hataları
class AuthException extends AppException {
  const AuthException({
    required super.message,
    required super.code,
    super.details,
  });

  // Firebase Auth Error Code'larını kullanıcı dostu mesajlara çevir
  factory AuthException.fromFirebaseCode(String code, [String? details]) {
    switch (code) {
      case 'user-not-found':
        return const AuthException(
          message: 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthException(
          message: 'Hatalı şifre girdiniz.',
          code: 'wrong-password',
        );
      case 'email-already-in-use':
        return const AuthException(
          message: 'Bu e-posta adresi zaten kullanımda.',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthException(
          message: 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.',
          code: 'weak-password',
        );
      case 'invalid-email':
        return const AuthException(
          message: 'Geçersiz e-posta adresi formatı.',
          code: 'invalid-email',
        );
      case 'user-disabled':
        return const AuthException(
          message: 'Bu hesap devre dışı bırakılmış.',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthException(
          message:
              'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin.',
          code: 'too-many-requests',
        );
      case 'operation-not-allowed':
        return const AuthException(
          message: 'Bu işlem şu anda izin verilmiyor.',
          code: 'operation-not-allowed',
        );
      case 'account-exists-with-different-credential':
        return const AuthException(
          message:
              'Bu e-posta adresi farklı bir giriş yöntemi ile kullanılıyor.',
          code: 'account-exists-with-different-credential',
        );
      case 'invalid-credential':
        return const AuthException(
          message: 'Geçersiz kimlik bilgileri.',
          code: 'invalid-credential',
        );
      case 'sign_in_canceled':
        return const AuthException(
          message: 'Giriş işlemi iptal edildi.',
          code: 'sign_in_canceled',
        );
      case 'network_error':
        return const AuthException(
          message:
              'İnternet bağlantısı sorunu. Lütfen bağlantınızı kontrol edin.',
          code: 'network_error',
        );
      default:
        return AuthException(
          message: 'Bilinmeyen kimlik doğrulama hatası: $code',
          code: code,
          details: details,
        );
    }
  }
}

// Veritabanı hataları
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    required super.code,
    super.details,
  });

  factory DatabaseException.fromFirestoreCode(String code, [String? details]) {
    switch (code) {
      case 'permission-denied':
        return const DatabaseException(
          message: 'Bu işlem için yetkiniz yok.',
          code: 'permission-denied',
        );
      case 'not-found':
        return const DatabaseException(
          message: 'Aradığınız veri bulunamadı.',
          code: 'not-found',
        );
      case 'already-exists':
        return const DatabaseException(
          message: 'Bu veri zaten mevcut.',
          code: 'already-exists',
        );
      case 'resource-exhausted':
        return const DatabaseException(
          message: 'Veri limitine ulaşıldı. Lütfen daha sonra tekrar deneyin.',
          code: 'resource-exhausted',
        );
      case 'failed-precondition':
        return const DatabaseException(
          message: 'İşlem koşulları sağlanmadı.',
          code: 'failed-precondition',
        );
      case 'aborted':
        return const DatabaseException(
          message: 'İşlem iptal edildi. Lütfen tekrar deneyin.',
          code: 'aborted',
        );
      case 'out-of-range':
        return const DatabaseException(
          message: 'Geçersiz değer aralığı.',
          code: 'out-of-range',
        );
      case 'unimplemented':
        return const DatabaseException(
          message: 'Bu özellik henüz desteklenmiyor.',
          code: 'unimplemented',
        );
      case 'internal':
        return const DatabaseException(
          message: 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.',
          code: 'internal',
        );
      case 'unavailable':
        return const DatabaseException(
          message:
              'Servis şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
          code: 'unavailable',
        );
      case 'data-loss':
        return const DatabaseException(
          message: 'Veri kaybı tespit edildi.',
          code: 'data-loss',
        );
      case 'unauthenticated':
        return const DatabaseException(
          message: 'Oturum açmanız gerekiyor.',
          code: 'unauthenticated',
        );
      default:
        return DatabaseException(
          message: 'Veritabanı hatası: $code',
          code: code,
          details: details,
        );
    }
  }
}

// İş mantığı hataları
class BusinessException extends AppException {
  const BusinessException({
    required super.message,
    required super.code,
    super.details,
  });
}

// Ağ bağlantı hataları
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    required super.code,
    super.details,
  });
}

// Validasyon hataları
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    required super.code,
    super.details,
  });
}

// Dosya/Depolama hataları
class StorageException extends AppException {
  const StorageException({
    required super.message,
    required super.code,
    super.details,
  });
}
