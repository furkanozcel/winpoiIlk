import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/services/notification_models.dart';
import 'package:intl/intl.dart';

class NotificationListWidget extends StatelessWidget {
  const NotificationListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.recentNotifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz bildirim yok',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bildirimler geldiğinde burada görünecek',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Clear All Button
            if (provider.recentNotifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Son Bildirimler (${provider.recentNotifications.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () =>
                          _showClearConfirmation(context, provider),
                      child: const Text('Tümünü Temizle'),
                    ),
                  ],
                ),
              ),

            // Notifications List
            Expanded(
              child: ListView.builder(
                itemCount: provider.recentNotifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.recentNotifications[index];
                  return NotificationTile(
                    notification: notification,
                    onDismiss: () => provider.removeNotification(notification),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearConfirmation(
      BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bildirimleri Temizle'),
        content:
            const Text('Tüm bildirimleri silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearRecentNotifications();
              Navigator.of(context).pop();
            },
            child: const Text('Temizle'),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationMessage notification;
  final VoidCallback onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.receivedAt.millisecondsSinceEpoch.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getNotificationColor(notification.type),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            notification.title ?? 'Bildirim',
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.body != null) ...[
                Text(
                  notification.body!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(notification.receivedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getNotificationTypeText(notification.type),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getNotificationColor(notification.type),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  onDismiss();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16),
                    SizedBox(width: 8),
                    Text('Sil'),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _handleNotificationTap(context, notification),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationMessageType type) {
    switch (type) {
      case NotificationMessageType.contest:
        return Colors.orange;
      case NotificationMessageType.gameStart:
      case NotificationMessageType.gameEnd:
        return Colors.blue;
      case NotificationMessageType.ranking:
        return Colors.purple;
      case NotificationMessageType.prize:
        return Colors.green;
      case NotificationMessageType.system:
        return Colors.grey;
      case NotificationMessageType.general:
        return Colors.blueGrey;
    }
  }

  IconData _getNotificationIcon(NotificationMessageType type) {
    switch (type) {
      case NotificationMessageType.contest:
        return Icons.emoji_events;
      case NotificationMessageType.gameStart:
        return Icons.play_arrow;
      case NotificationMessageType.gameEnd:
        return Icons.stop;
      case NotificationMessageType.ranking:
        return Icons.leaderboard;
      case NotificationMessageType.prize:
        return Icons.card_giftcard;
      case NotificationMessageType.system:
        return Icons.settings;
      case NotificationMessageType.general:
        return Icons.notifications;
    }
  }

  String _getNotificationTypeText(NotificationMessageType type) {
    switch (type) {
      case NotificationMessageType.contest:
        return 'Yarışma';
      case NotificationMessageType.gameStart:
        return 'Oyun Başladı';
      case NotificationMessageType.gameEnd:
        return 'Oyun Bitti';
      case NotificationMessageType.ranking:
        return 'Sıralama';
      case NotificationMessageType.prize:
        return 'Ödül';
      case NotificationMessageType.system:
        return 'Sistem';
      case NotificationMessageType.general:
        return 'Genel';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} sa önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  void _handleNotificationTap(
      BuildContext context, NotificationMessage notification) {
    // Notification türüne göre navigasyon
    switch (notification.type) {
      case NotificationMessageType.contest:
        // Contest sayfasına git
        debugPrint('Navigate to contest: ${notification.data}');
        break;
      case NotificationMessageType.gameStart:
      case NotificationMessageType.gameEnd:
        // Game sayfasına git
        debugPrint('Navigate to game: ${notification.data}');
        break;
      case NotificationMessageType.ranking:
        // Leaderboard sayfasına git
        debugPrint('Navigate to leaderboard: ${notification.data}');
        break;
      case NotificationMessageType.prize:
        // Prize sayfasına git
        debugPrint('Navigate to prize: ${notification.data}');
        break;
      default:
        // Default action
        _showNotificationDetails(context, notification);
        break;
    }
  }

  void _showNotificationDetails(
      BuildContext context, NotificationMessage notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title ?? 'Bildirim'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notification.body != null) ...[
              Text(notification.body!),
              const SizedBox(height: 16),
            ],
            Text(
              'Alınma Zamanı: ${DateFormat('dd/MM/yyyy HH:mm').format(notification.receivedAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (notification.data != null && notification.data!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Veri: ${notification.data}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
