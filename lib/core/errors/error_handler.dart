import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'app_exception.dart';

// Merkezi error handling sınıfı
class ErrorHandler {
  /// Firebase ve diğer hataları AppException'a dönüştürür
  static AppException handleError(dynamic error) {
    // Firebase Auth hataları
    if (error is FirebaseAuthException) {
      return AuthException.fromFirebaseCode(error.code, error.message);
    }

    // Firestore hataları
    if (error is FirebaseException) {
      return DatabaseException.fromFirestoreCode(error.code, error.message);
    }

    // Network hataları
    if (error is SocketException) {
      return const NetworkException(
        message:
            'İnternet bağlantısı sorunu. Lütfen bağlantınızı kontrol edin.',
        code: 'network_error',
      );
    }

    // Format hataları
    if (error is FormatException) {
      return ValidationException(
        message: 'Geçersiz veri formatı: ${error.message}',
        code: 'format_error',
      );
    }

    // Timeout hataları
    if (error is TimeoutException) {
      return const NetworkException(
        message: 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.',
        code: 'timeout_error',
      );
    }

    // AppException zaten doğru formatta ise olduğu gibi döndür
    if (error is AppException) {
      return error;
    }

    // Bilinmeyen hatalar için genel exception
    return BusinessException(
      message: 'Beklenmeyen bir hata oluştu: ${error.toString()}',
      code: 'unknown_error',
      details: error.toString(),
    );
  }

  /// Hata mesajını kullanıcı dostu hale getirir
  static String getUserFriendlyMessage(AppException exception) {
    return exception.message;
  }

  /// Hata türüne göre SnackBar rengi döndürür
  static Color getErrorColor(AppException exception) {
    switch (exception.runtimeType) {
      case const (AuthException):
        return Colors.red.shade600;
      case const (DatabaseException):
        return Colors.orange.shade600;
      case const (NetworkException):
        return Colors.blue.shade600;
      case const (ValidationException):
        return Colors.yellow.shade700;
      case const (BusinessException):
        return Colors.purple.shade600;
      case const (StorageException):
        return Colors.green.shade600;
      default:
        return Colors.red.shade600;
    }
  }

  /// Hata türüne göre ikon döndürür
  static IconData getErrorIcon(AppException exception) {
    switch (exception.runtimeType) {
      case const (AuthException):
        return Icons.security;
      case const (DatabaseException):
        return Icons.storage;
      case const (NetworkException):
        return Icons.wifi_off;
      case const (ValidationException):
        return Icons.warning;
      case const (BusinessException):
        return Icons.business;
      case const (StorageException):
        return Icons.folder;
      default:
        return Icons.error;
    }
  }

  /// Hata türüne göre yeniden deneme gerekip gerekmediğini belirler
  static bool shouldRetry(AppException exception) {
    switch (exception.code) {
      case 'network_error':
      case 'timeout_error':
      case 'unavailable':
      case 'internal':
      case 'aborted':
        return true;
      default:
        return false;
    }
  }

  /// Debug modda konsola detaylı hata bilgisi yazdırır
  static void logError(AppException exception, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('🚨 ERROR: ${exception.code}');
      print('📝 Message: ${exception.message}');
      if (exception.details != null) {
        print('📋 Details: ${exception.details}');
      }
      if (stackTrace != null) {
        print('📍 Stack Trace: $stackTrace');
      }
      print('─' * 50);
    }
  }
}

// Timeout exception sınıfı
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);

  @override
  String toString() => message;
}

// Debug mode kontrolü için helper
bool get kDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}
