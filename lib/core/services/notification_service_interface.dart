import 'notification_models.dart';

/// Push notification servisi için abstract interface
abstract class NotificationServiceInterface {
  /// FCM token'ını başlatır ve alır
  Future<String?> initializeAndGetToken();

  /// FCM token'ını yeniler
  Future<String?> refreshToken();

  /// Notification permission'ı ister
  Future<NotificationPermissionStatus> requestPermission();

  /// Mevcut permission durumunu kontrol eder
  Future<NotificationPermissionStatus> checkPermissionStatus();

  /// Foreground notification listener'ını başlatır
  void setupForegroundNotificationHandling();

  /// Background notification handler'ını ayarlar
  void setupBackgroundNotificationHandling();

  /// App terminated state'den gelen notification'ı handle eder
  Future<NotificationMessage?> getInitialMessage();

  /// Notification settings'ini kaydeder
  Future<void> saveNotificationSettings(NotificationSettings settings);

  /// Notification settings'ini alır
  Future<NotificationSettings> getNotificationSettings();

  /// FCM token'ını Firestore'a kaydeder
  Future<void> saveTokenToFirestore(String token, String userId);

  /// FCM token'ını Firestore'dan siler
  Future<void> removeTokenFromFirestore(String userId);

  /// Specific topic'e subscribe olur
  Future<void> subscribeToTopic(String topic);

  /// Specific topic'ten unsubscribe olur
  Future<void> unsubscribeFromTopic(String topic);

  /// Local notification gösterir (foreground durumu için)
  Future<void> showLocalNotification(NotificationMessage message);

  /// Notification handling stream'ini dinler
  Stream<NotificationMessage> get onNotificationReceived;

  /// Notification click stream'ini dinler
  Stream<NotificationMessage> get onNotificationClicked;

  /// Token refresh stream'ini dinler
  Stream<String> get onTokenRefresh;

  /// Service'i temizler
  Future<void> dispose();
}
