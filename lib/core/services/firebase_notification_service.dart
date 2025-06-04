import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart'
    hide NotificationSettings;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../errors/error_handler.dart';
import 'notification_service_interface.dart';
import 'notification_models.dart';

/// Firebase Cloud Messaging servisi implementasyonu
class FirebaseNotificationService implements NotificationServiceInterface {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream controllers
  final StreamController<NotificationMessage> _notificationController =
      StreamController<NotificationMessage>.broadcast();
  final StreamController<NotificationMessage> _notificationClickController =
      StreamController<NotificationMessage>.broadcast();
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();

  static const String _settingsKey = 'notification_settings';
  static const String _androidChannelId = 'winpoi_notifications';
  static const String _androidChannelName = 'WinPoi Notifications';
  static const String _androidChannelDescription =
      'WinPoi uygulamasindan gelen bildirimler';

  bool _isInitialized = false;

  @override
  Future<String?> initializeAndGetToken() async {
    try {
      if (_isInitialized) {
        return await _firebaseMessaging.getToken();
      }

      // Local notifications'i baslat
      await _initializeLocalNotifications();

      // Permission iste
      await requestPermission();

      // Foreground ve background handlers'i ayarla
      setupForegroundNotificationHandling();
      setupBackgroundNotificationHandling();

      // Token refresh listener'i ayarla
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _tokenRefreshController.add(token);
      });

      _isInitialized = true;

      // Token'i al ve dondur
      return await _firebaseMessaging.getToken();
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    // Android initialization
    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');

    // iOS initialization
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        // Handle iOS local notification
      },
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Notification'a tiklandiginda cagrilir
        if (response.payload != null) {
          final Map<String, dynamic> data = jsonDecode(response.payload!);
          final message = NotificationMessage.fromMap(data);
          _notificationClickController.add(message);
        }
      },
    );

    // Android notification channel olustur
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  @override
  Future<String?> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      return await _firebaseMessaging.getToken();
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return _convertAuthorizationStatus(settings.authorizationStatus);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  @override
  Future<NotificationPermissionStatus> checkPermissionStatus() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return _convertAuthorizationStatus(settings.authorizationStatus);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  NotificationPermissionStatus _convertAuthorizationStatus(
      AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return NotificationPermissionStatus.authorized;
      case AuthorizationStatus.denied:
        return NotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return NotificationPermissionStatus.notDetermined;
      case AuthorizationStatus.provisional:
        return NotificationPermissionStatus.provisional;
    }
  }

  @override
  void setupForegroundNotificationHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message alindi: ${message.messageId}');

      final notificationMessage = _convertRemoteMessage(message);
      _notificationController.add(notificationMessage);

      // Foreground'da notification goster
      if (message.notification != null) {
        showLocalNotification(notificationMessage);
      }
    });
  }

  @override
  void setupBackgroundNotificationHandling() {
    // App background'da iken notification'a tiklandiginda
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Background message clicked: ${message.messageId}');

      final notificationMessage = _convertRemoteMessage(message);
      _notificationClickController.add(notificationMessage);
    });
  }

  @override
  Future<NotificationMessage?> getInitialMessage() async {
    try {
      final RemoteMessage? message =
          await _firebaseMessaging.getInitialMessage();

      if (message != null) {
        debugPrint(
            'App terminated state den message alindi: ${message.messageId}');
        return _convertRemoteMessage(message);
      }

      return null;
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  NotificationMessage _convertRemoteMessage(RemoteMessage message) {
    return NotificationMessage(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      imageUrl: message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      receivedAt: DateTime.now(),
      type: NotificationMessageType.fromString(
        message.data['type'] as String? ?? 'general',
      ),
    );
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toMap());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
        return NotificationSettings.fromMap(settingsMap);
      }

      return const NotificationSettings(); // Default settings
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      return const NotificationSettings(); // Fallback to default
    }
  }

  @override
  Future<void> saveTokenToFirestore(String token, String userId) async {
    try {
      final fcmToken = FCMToken(
        token: token,
        lastUpdated: DateTime.now(),
        platform: Platform.isAndroid ? 'android' : 'ios',
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(Platform.isAndroid ? 'android' : 'ios')
          .set(fcmToken.toMap());

      debugPrint('FCM token Firestore a kaydedildi: $userId');
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  @override
  Future<void> removeTokenFromFirestore(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('fcmTokens')
          .doc(Platform.isAndroid ? 'android' : 'ios')
          .delete();

      debugPrint('FCM token Firestore dan silindi: $userId');
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Topic e subscribe olundu: $topic');
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Topic ten unsubscribe olundu: $topic');
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  @override
  Future<void> showLocalNotification(NotificationMessage message) async {
    try {
      final settings = await getNotificationSettings();
      if (!settings.isEnabled) return;

      // Notification turune gore filtrele
      bool shouldShow = false;
      switch (message.type) {
        case NotificationMessageType.contest:
          shouldShow = settings.contestNotifications;
          break;
        case NotificationMessageType.gameStart:
        case NotificationMessageType.gameEnd:
          shouldShow = settings.gameNotifications;
          break;
        case NotificationMessageType.ranking:
          shouldShow = settings.rankingNotifications;
          break;
        case NotificationMessageType.prize:
          shouldShow = settings.prizeNotifications;
          break;
        case NotificationMessageType.system:
          shouldShow = settings.systemNotifications;
          break;
        case NotificationMessageType.general:
          shouldShow = true;
          break;
      }

      if (!shouldShow) return;

      const androidDetails = AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFF4ECDC4),
        ledOnMs: 1000,
        ledOffMs: 500,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        message.title ?? 'WinPoi',
        message.body ?? '',
        notificationDetails,
        payload: jsonEncode(message.toMap()),
      );
    } catch (e) {
      final exception = ErrorHandler.handleError(e);
      ErrorHandler.logError(exception);
      throw exception;
    }
  }

  @override
  Stream<NotificationMessage> get onNotificationReceived =>
      _notificationController.stream;

  @override
  Stream<NotificationMessage> get onNotificationClicked =>
      _notificationClickController.stream;

  @override
  Stream<String> get onTokenRefresh => _tokenRefreshController.stream;

  @override
  Future<void> dispose() async {
    await _notificationController.close();
    await _notificationClickController.close();
    await _tokenRefreshController.close();
  }
}

/// Background message handler (top-level function olmali)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message alindi: ${message.messageId}');

  // Background'da notification handling logic'i burada olabilir
  // Ornegin: local database'e kaydetme, vb.
}
