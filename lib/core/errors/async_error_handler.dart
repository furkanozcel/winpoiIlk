import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'app_exception.dart';
import 'error_handler.dart';
import 'error_widgets.dart';

/// Async işlemler için result wrapper
class AsyncResult<T> {
  final T? data;
  final AppException? error;
  final bool isLoading;

  const AsyncResult._({
    this.data,
    this.error,
    this.isLoading = false,
  });

  // Factory constructors
  const AsyncResult.loading() : this._(isLoading: true);
  const AsyncResult.success(T data) : this._(data: data);
  const AsyncResult.error(AppException error) : this._(error: error);

  // Getters
  bool get hasData => data != null;
  bool get hasError => error != null;
  bool get isSuccess => hasData && !hasError && !isLoading;

  // When methods for data handling
  R fold<R>({
    required R Function() loading,
    required R Function(T data) success,
    required R Function(AppException error) error,
  }) {
    if (isLoading) return loading();
    if (hasError) return error(this.error!);
    if (hasData) return success(data as T);
    return loading();
  }

  // Widget builder
  Widget buildWidget({
    required Widget Function() loading,
    required Widget Function(T data) success,
    required Widget Function(AppException error) error,
  }) {
    if (isLoading) return loading();
    if (hasError) return error(this.error!);
    if (hasData) return success(data as T);
    return loading();
  }
}

/// Future için extension
extension FutureErrorHandling<T> on Future<T> {
  /// Hataları otomatik olarak yakalayıp AppException'a dönüştürür
  Future<AsyncResult<T>> handleErrors() async {
    try {
      final result = await this;
      return AsyncResult.success(result);
    } catch (error, stackTrace) {
      final appException = ErrorHandler.handleError(error);
      ErrorHandler.logError(appException, stackTrace: stackTrace);
      return AsyncResult.error(appException);
    }
  }

  /// Timeout ekler ve hataları handle eder
  Future<AsyncResult<T>> handleErrorsWithTimeout(Duration timeout) async {
    try {
      final result = await this.timeout(timeout);
      return AsyncResult.success(result);
    } on TimeoutException catch (error, stackTrace) {
      final appException = ErrorHandler.handleError(error);
      ErrorHandler.logError(appException, stackTrace: stackTrace);
      return AsyncResult.error(appException);
    } catch (error, stackTrace) {
      final appException = ErrorHandler.handleError(error);
      ErrorHandler.logError(appException, stackTrace: stackTrace);
      return AsyncResult.error(appException);
    }
  }

  /// Hata durumunda SnackBar gösterir
  Future<T?> catchWithSnackBar(BuildContext context,
      {VoidCallback? onRetry}) async {
    try {
      return await this;
    } catch (error, stackTrace) {
      final appException = ErrorHandler.handleError(error);
      ErrorHandler.logError(appException, stackTrace: stackTrace);

      if (context.mounted) {
        ErrorSnackBar.show(context, appException, onRetry: onRetry);
      }
      return null;
    }
  }

  /// Retry mekanizması ile birlikte hata handling
  Future<AsyncResult<T>> withRetry({
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final result = await this;
        return AsyncResult.success(result);
      } catch (error, stackTrace) {
        attempts++;
        final appException = ErrorHandler.handleError(error);

        if (attempts >= maxRetries || !ErrorHandler.shouldRetry(appException)) {
          ErrorHandler.logError(appException, stackTrace: stackTrace);
          return AsyncResult.error(appException);
        }

        // Exponential backoff
        await Future.delayed(delay * attempts);
      }
    }

    return AsyncResult.error(const NetworkException(
      message: 'Maksimum deneme sayısına ulaşıldı',
      code: 'max_retries_exceeded',
    ));
  }
}

/// ChangeNotifier için error handling mixin
mixin AsyncErrorHandlerMixin on ChangeNotifier {
  AppException? _error;
  bool _isLoading = false;

  AppException? get error => _error;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;

  /// Loading state'i ayarlar
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      if (loading) {
        _error = null; // Loading başlarken error'u temizle
      }
      notifyListeners();
    }
  }

  /// Error state'i ayarlar
  void setError(AppException? error) {
    if (_error != error) {
      _error = error;
      _isLoading = false; // Error varsa loading'i durdur
      notifyListeners();
    }
  }

  /// Error'u temizler
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  /// Async işlemi güvenli şekilde çalıştırır
  Future<T?> runAsync<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
  }) async {
    if (showLoading) setLoading(true);
    clearError();

    try {
      final result = await operation();
      if (showLoading) setLoading(false);
      return result;
    } catch (error, stackTrace) {
      final appException = ErrorHandler.handleError(error);
      ErrorHandler.logError(appException, stackTrace: stackTrace);
      setError(appException);
      return null;
    }
  }

  /// Retry ile async işlem
  Future<T?> runAsyncWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool showLoading = true,
  }) async {
    if (showLoading) setLoading(true);
    clearError();

    final result = await operation().withRetry(
      maxRetries: maxRetries,
      delay: delay,
    );

    return result.fold<T?>(
      loading: () {
        if (showLoading) setLoading(false);
        return null;
      },
      success: (data) {
        if (showLoading) setLoading(false);
        return data;
      },
      error: (error) {
        setError(error);
        return null;
      },
    );
  }
}

/// Global hata yakalama için helper
class GlobalErrorHandler {
  static void initialize() {
    // Flutter framework hataları
    FlutterError.onError = (FlutterErrorDetails details) {
      final appException = ErrorHandler.handleError(details.exception);
      ErrorHandler.logError(appException, stackTrace: details.stack);
    };

    // Async hataları
    PlatformDispatcher.instance.onError = (error, stack) {
      final appException = ErrorHandler.handleError(error);
      ErrorHandler.logError(appException, stackTrace: stack);
      return true;
    };
  }
}
