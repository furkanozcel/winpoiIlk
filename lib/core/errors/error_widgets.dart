import 'package:flutter/material.dart';
import 'app_exception.dart';
import 'error_handler.dart';

/// Hata mesajlarını gösteren SnackBar
class ErrorSnackBar {
  static void show(
    BuildContext context,
    AppException exception, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    final color = ErrorHandler.getErrorColor(exception);
    final icon = ErrorHandler.getErrorIcon(exception);
    final message = ErrorHandler.getUserFriendlyMessage(exception);
    final shouldRetry = ErrorHandler.shouldRetry(exception);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getErrorTitle(exception),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: shouldRetry && onRetry != null
            ? SnackBarAction(
                label: 'Tekrar Dene',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static String _getErrorTitle(AppException exception) {
    switch (exception.runtimeType) {
      case AuthException:
        return 'Kimlik Doğrulama Hatası';
      case DatabaseException:
        return 'Veri Hatası';
      case NetworkException:
        return 'Bağlantı Hatası';
      case ValidationException:
        return 'Geçersiz Veri';
      case BusinessException:
        return 'İşlem Hatası';
      case StorageException:
        return 'Dosya Hatası';
      default:
        return 'Hata';
    }
  }
}

/// Tam sayfa hata gösterimi için widget
class ErrorPageWidget extends StatelessWidget {
  final AppException exception;
  final VoidCallback? onRetry;
  final String? customMessage;

  const ErrorPageWidget({
    super.key,
    required this.exception,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final color = ErrorHandler.getErrorColor(exception);
    final icon = ErrorHandler.getErrorIcon(exception);
    final message =
        customMessage ?? ErrorHandler.getUserFriendlyMessage(exception);
    final shouldRetry = ErrorHandler.shouldRetry(exception);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: color,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                ErrorSnackBar._getErrorTitle(exception),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (shouldRetry && onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Küçük error widget'ı (liste içinde kullanım için)
class InlineErrorWidget extends StatelessWidget {
  final AppException exception;
  final VoidCallback? onRetry;
  final bool compact;

  const InlineErrorWidget({
    super.key,
    required this.exception,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = ErrorHandler.getErrorColor(exception);
    final icon = ErrorHandler.getErrorIcon(exception);
    final message = ErrorHandler.getUserFriendlyMessage(exception);
    final shouldRetry = ErrorHandler.shouldRetry(exception);

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: compact ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ErrorSnackBar._getErrorTitle(exception),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: compact ? 14 : 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: compact ? 12 : 14,
            ),
          ),
          if (shouldRetry && onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Tekrar Dene'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading state sırasında hata gösterimi
class LoadingErrorWidget extends StatelessWidget {
  final AppException exception;
  final VoidCallback? onRetry;

  const LoadingErrorWidget({
    super.key,
    required this.exception,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final color = ErrorHandler.getErrorColor(exception);
    final icon = ErrorHandler.getErrorIcon(exception);
    final message = ErrorHandler.getUserFriendlyMessage(exception);
    final shouldRetry = ErrorHandler.shouldRetry(exception);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (shouldRetry && onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
