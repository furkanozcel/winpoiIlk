import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../errors/async_error_handler.dart';
import '../services/notification_service_interface.dart';
import '../services/firebase_notification_service.dart';
import '../services/notification_models.dart';

/// Push notification state'ini yöneten provider
class NotificationProvider extends ChangeNotifier with AsyncErrorHandlerMixin {
  final NotificationServiceInterface _notificationService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  String? _fcmToken;
  NotificationPermissionStatus _permissionStatus =
      NotificationPermissionStatus.notDetermined;
  NotificationSettings _settings = const NotificationSettings();
  List<NotificationMessage> _recentNotifications = [];
  bool _isInitialized = false;

  // Stream subscriptions
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _notificationClickSubscription;
  StreamSubscription? _tokenRefreshSubscription;
  StreamSubscription? _authSubscription;

  NotificationProvider({NotificationServiceInterface? notificationService})
      : _notificationService =
            notificationService ?? FirebaseNotificationService() {
    _initialize();
  }

  // Getters
  String? get fcmToken => _fcmToken;
  NotificationPermissionStatus get permissionStatus => _permissionStatus;
  NotificationSettings get settings => _settings;
  List<NotificationMessage> get recentNotifications =>
      List.unmodifiable(_recentNotifications);
  bool get isInitialized => _isInitialized;
  bool get hasPermission =>
      _permissionStatus == NotificationPermissionStatus.authorized;

  /// Provider'ı başlatır
  Future<void> _initialize() async {
    await runAsync(() async {
      setLoading(true);

      // Authentication listener'ı kur
      _setupAuthListener();

      // Notification service'i başlat
      await _initializeNotificationService();

      // Mevcut kullanıcı varsa token'ı kaydet
      final currentUser = _auth.currentUser;
      if (currentUser != null && _fcmToken != null) {
        await _notificationService.saveTokenToFirestore(
            _fcmToken!, currentUser.uid);
      }

      // Settings'i yükle
      await _loadSettings();

      // Stream listeners'ı kur
      _setupListeners();

      // Terminated state'den gelen notification'ı kontrol et
      await _checkInitialMessage();

      _isInitialized = true;
      setLoading(false);
    });
  }

  void _setupAuthListener() {
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      if (user != null && _fcmToken != null) {
        // Kullanıcı giriş yaptı, token'ı kaydet
        await _notificationService.saveTokenToFirestore(_fcmToken!, user.uid);
        await _subscribeToUserTopics(user.uid);
      } else if (user == null && _fcmToken != null) {
        // Kullanıcı çıkış yaptı, token'ı temizle
        await _unsubscribeFromAllTopics();
      }
    });
  }

  Future<void> _initializeNotificationService() async {
    try {
      _fcmToken = await _notificationService.initializeAndGetToken();
      _permissionStatus = await _notificationService.checkPermissionStatus();

      debugPrint('FCM Token: $_fcmToken');
      debugPrint('Permission Status: $_permissionStatus');
    } catch (e) {
      debugPrint('Notification service initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _loadSettings() async {
    try {
      _settings = await _notificationService.getNotificationSettings();
    } catch (e) {
      debugPrint('Settings loading failed: $e');
      // Default settings kullan
    }
  }

  void _setupListeners() {
    // Notification received listener
    _notificationSubscription =
        _notificationService.onNotificationReceived.listen(
      (NotificationMessage message) {
        _addRecentNotification(message);
        debugPrint('Notification received: ${message.title}');
      },
      onError: (error) {
        debugPrint('Notification received error: $error');
      },
    );

    // Notification clicked listener
    _notificationClickSubscription =
        _notificationService.onNotificationClicked.listen(
      (NotificationMessage message) {
        _handleNotificationClick(message);
        debugPrint('Notification clicked: ${message.title}');
      },
      onError: (error) {
        debugPrint('Notification click error: $error');
      },
    );

    // Token refresh listener
    _tokenRefreshSubscription = _notificationService.onTokenRefresh.listen(
      (String newToken) async {
        _fcmToken = newToken;
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          await _notificationService.saveTokenToFirestore(
              newToken, currentUser.uid);
        }
        notifyListeners();
        debugPrint('FCM Token refreshed: $newToken');
      },
      onError: (error) {
        debugPrint('Token refresh error: $error');
      },
    );
  }

  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await _notificationService.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }
    } catch (e) {
      debugPrint('Initial message check failed: $e');
    }
  }

  void _addRecentNotification(NotificationMessage message) {
    _recentNotifications.insert(0, message);

    // En fazla 50 notification tut
    if (_recentNotifications.length > 50) {
      _recentNotifications = _recentNotifications.take(50).toList();
    }

    notifyListeners();
  }

  void _handleNotificationClick(NotificationMessage message) {
    // Navigation logic burada olacak
    // Notification türüne göre farklı sayfalar açılabilir

    switch (message.type) {
      case NotificationMessageType.contest:
        // Contest sayfasına yönlendir
        debugPrint('Navigating to contest page: ${message.data}');
        break;
      case NotificationMessageType.gameStart:
      case NotificationMessageType.gameEnd:
        // Game sayfasına yönlendir
        debugPrint('Navigating to game page: ${message.data}');
        break;
      case NotificationMessageType.ranking:
        // Leaderboard sayfasına yönlendir
        debugPrint('Navigating to leaderboard page: ${message.data}');
        break;
      case NotificationMessageType.prize:
        // Prize sayfasına yönlendir
        debugPrint('Navigating to prize page: ${message.data}');
        break;
      default:
        // Default navigation
        debugPrint('Default notification handling: ${message.data}');
        break;
    }

    // Recent notifications'a ekle (click durumu için)
    _addRecentNotification(message);
  }

  /// Permission isteme
  Future<bool> requestPermission() async {
    final result = await runAsync(() async {
      _permissionStatus = await _notificationService.requestPermission();
      return hasPermission;
    });
    return result ?? false;
  }

  /// Permission durumunu kontrol etme
  Future<void> checkPermissionStatus() async {
    await runAsync(() async {
      _permissionStatus = await _notificationService.checkPermissionStatus();
    });
  }

  /// FCM token'ı yenileme
  Future<void> refreshToken() async {
    await runAsync(() async {
      _fcmToken = await _notificationService.refreshToken();

      final currentUser = _auth.currentUser;
      if (currentUser != null && _fcmToken != null) {
        await _notificationService.saveTokenToFirestore(
            _fcmToken!, currentUser.uid);
      }

      notifyListeners();
    });
  }

  /// Notification settings'ini güncelleme
  Future<void> updateSettings(NotificationSettings newSettings) async {
    await runAsync(() async {
      await _notificationService.saveNotificationSettings(newSettings);
      _settings = newSettings;
    });
  }

  /// Belirli bir notification türünü açma/kapatma
  Future<void> toggleNotificationType(
      NotificationMessageType type, bool enabled) async {
    NotificationSettings newSettings;

    switch (type) {
      case NotificationMessageType.contest:
        newSettings = _settings.copyWith(contestNotifications: enabled);
        break;
      case NotificationMessageType.gameStart:
      case NotificationMessageType.gameEnd:
        newSettings = _settings.copyWith(gameNotifications: enabled);
        break;
      case NotificationMessageType.ranking:
        newSettings = _settings.copyWith(rankingNotifications: enabled);
        break;
      case NotificationMessageType.prize:
        newSettings = _settings.copyWith(prizeNotifications: enabled);
        break;
      case NotificationMessageType.system:
        newSettings = _settings.copyWith(systemNotifications: enabled);
        break;
      default:
        return; // General type için toggle yok
    }

    await updateSettings(newSettings);
  }

  /// Tüm notifications'ı açma/kapatma
  Future<void> toggleAllNotifications(bool enabled) async {
    final newSettings = _settings.copyWith(isEnabled: enabled);
    await updateSettings(newSettings);
  }

  /// Topic'e subscribe olma
  Future<void> subscribeToTopic(String topic) async {
    await runAsync(() async {
      await _notificationService.subscribeToTopic(topic);
    });
  }

  /// Topic'ten unsubscribe olma
  Future<void> unsubscribeFromTopic(String topic) async {
    await runAsync(() async {
      await _notificationService.unsubscribeFromTopic(topic);
    });
  }

  /// Kullanıcı topic'lerine subscribe olma
  Future<void> _subscribeToUserTopics(String userId) async {
    try {
      // Genel topic'ler
      await _notificationService.subscribeToTopic('all_users');

      // Kullanıcı-specific topic
      await _notificationService.subscribeToTopic('user_$userId');

      // Settings'e göre topic'ler
      if (_settings.contestNotifications) {
        await _notificationService.subscribeToTopic('contests');
      }
      if (_settings.gameNotifications) {
        await _notificationService.subscribeToTopic('games');
      }
      if (_settings.rankingNotifications) {
        await _notificationService.subscribeToTopic('rankings');
      }
      if (_settings.prizeNotifications) {
        await _notificationService.subscribeToTopic('prizes');
      }
    } catch (e) {
      debugPrint('Topic subscription failed: $e');
    }
  }

  /// Tüm topic'lerden unsubscribe olma
  Future<void> _unsubscribeFromAllTopics() async {
    try {
      final topics = ['all_users', 'contests', 'games', 'rankings', 'prizes'];

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _notificationService.removeTokenFromFirestore(currentUser.uid);
        topics.add('user_${currentUser.uid}');
      }

      for (final topic in topics) {
        await _notificationService.unsubscribeFromTopic(topic);
      }
    } catch (e) {
      debugPrint('Topic unsubscription failed: $e');
    }
  }

  /// Recent notifications'ı temizleme
  void clearRecentNotifications() {
    _recentNotifications.clear();
    notifyListeners();
  }

  /// Belirli bir notification'ı silme
  void removeNotification(NotificationMessage message) {
    _recentNotifications.remove(message);
    notifyListeners();
  }

  /// Test notification gönderme (debug için)
  Future<void> sendTestNotification() async {
    if (kDebugMode) {
      final testMessage = NotificationMessage(
        title: 'Test Notification',
        body: 'Bu bir test notification mesajıdır.',
        receivedAt: DateTime.now(),
        type: NotificationMessageType.general,
      );

      await _notificationService.showLocalNotification(testMessage);
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationClickSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    _authSubscription?.cancel();
    _notificationService.dispose();
    super.dispose();
  }
}
