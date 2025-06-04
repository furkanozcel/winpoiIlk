import 'package:equatable/equatable.dart';

/// Push notification message model
class NotificationMessage extends Equatable {
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final DateTime receivedAt;
  final NotificationMessageType type;

  const NotificationMessage({
    this.title,
    this.body,
    this.data,
    this.imageUrl,
    required this.receivedAt,
    this.type = NotificationMessageType.general,
  });

  factory NotificationMessage.fromMap(Map<String, dynamic> map) {
    return NotificationMessage(
      title: map['title'] as String?,
      body: map['body'] as String?,
      data: map['data'] as Map<String, dynamic>?,
      imageUrl: map['imageUrl'] as String?,
      receivedAt: DateTime.now(),
      type: NotificationMessageType.fromString(
        map['type'] as String? ?? 'general',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'data': data,
      'imageUrl': imageUrl,
      'receivedAt': receivedAt.toIso8601String(),
      'type': type.name,
    };
  }

  @override
  List<Object?> get props => [title, body, data, imageUrl, receivedAt, type];
}

/// Notification message türleri
enum NotificationMessageType {
  general('general'),
  contest('contest'),
  gameStart('game_start'),
  gameEnd('game_end'),
  ranking('ranking'),
  prize('prize'),
  system('system');

  const NotificationMessageType(this.name);
  final String name;

  static NotificationMessageType fromString(String value) {
    return NotificationMessageType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => NotificationMessageType.general,
    );
  }
}

/// Notification permission durumu
enum NotificationPermissionStatus {
  authorized,
  denied,
  notDetermined,
  provisional,
}

/// Notification ayarları
class NotificationSettings extends Equatable {
  final bool isEnabled;
  final bool contestNotifications;
  final bool gameNotifications;
  final bool rankingNotifications;
  final bool prizeNotifications;
  final bool systemNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationSettings({
    this.isEnabled = true,
    this.contestNotifications = true,
    this.gameNotifications = true,
    this.rankingNotifications = true,
    this.prizeNotifications = true,
    this.systemNotifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      isEnabled: map['isEnabled'] as bool? ?? true,
      contestNotifications: map['contestNotifications'] as bool? ?? true,
      gameNotifications: map['gameNotifications'] as bool? ?? true,
      rankingNotifications: map['rankingNotifications'] as bool? ?? true,
      prizeNotifications: map['prizeNotifications'] as bool? ?? true,
      systemNotifications: map['systemNotifications'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'contestNotifications': contestNotifications,
      'gameNotifications': gameNotifications,
      'rankingNotifications': rankingNotifications,
      'prizeNotifications': prizeNotifications,
      'systemNotifications': systemNotifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? isEnabled,
    bool? contestNotifications,
    bool? gameNotifications,
    bool? rankingNotifications,
    bool? prizeNotifications,
    bool? systemNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      contestNotifications: contestNotifications ?? this.contestNotifications,
      gameNotifications: gameNotifications ?? this.gameNotifications,
      rankingNotifications: rankingNotifications ?? this.rankingNotifications,
      prizeNotifications: prizeNotifications ?? this.prizeNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object> get props => [
        isEnabled,
        contestNotifications,
        gameNotifications,
        rankingNotifications,
        prizeNotifications,
        systemNotifications,
        soundEnabled,
        vibrationEnabled,
      ];
}

/// FCM Token bilgisi
class FCMToken extends Equatable {
  final String token;
  final DateTime lastUpdated;
  final String platform;

  const FCMToken({
    required this.token,
    required this.lastUpdated,
    required this.platform,
  });

  factory FCMToken.fromMap(Map<String, dynamic> map) {
    return FCMToken(
      token: map['token'] as String,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      platform: map['platform'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'lastUpdated': lastUpdated.toIso8601String(),
      'platform': platform,
    };
  }

  @override
  List<Object> get props => [token, lastUpdated, platform];
}
