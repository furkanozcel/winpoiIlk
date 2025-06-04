import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/services/notification_models.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Ayarları'),
        backgroundColor: const Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bildirim ayarları yüklenirken hata oluştu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.checkPermissionStatus(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Permission Status Card
              _buildPermissionCard(context, provider),
              const SizedBox(height: 16),

              // Main Toggle
              _buildMainToggleCard(context, provider),
              const SizedBox(height: 16),

              // Notification Types
              if (provider.settings.isEnabled) ...[
                _buildNotificationTypesCard(context, provider),
                const SizedBox(height: 16),
              ],

              // Advanced Settings
              if (provider.settings.isEnabled) ...[
                _buildAdvancedSettingsCard(context, provider),
                const SizedBox(height: 16),
              ],

              // Debug Section (only in debug mode)
              if (provider.settings.isEnabled) ...[
                _buildDebugCard(context, provider),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionCard(
      BuildContext context, NotificationProvider provider) {
    final hasPermission = provider.hasPermission;
    final permissionStatus = provider.permissionStatus;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasPermission ? Icons.verified : Icons.warning,
                  color: hasPermission ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bildirim İzni',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getPermissionStatusText(permissionStatus),
              style: TextStyle(
                color: hasPermission
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
            if (!hasPermission) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => provider.requestPermission(),
                  child: const Text('İzin İste'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainToggleCard(
      BuildContext context, NotificationProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.notifications,
              color: provider.settings.isEnabled ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tüm Bildirimler',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Tüm bildirimleri açın veya kapatın',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: provider.settings.isEnabled,
              onChanged: provider.hasPermission
                  ? (value) => provider.toggleAllNotifications(value)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypesCard(
      BuildContext context, NotificationProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bildirim Türleri',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildNotificationTypeSwitch(
              context,
              'Yarışma Bildirimleri',
              'Yeni yarışmalar ve yarışma güncellemeleri',
              Icons.emoji_events,
              provider.settings.contestNotifications,
              (value) => provider.toggleNotificationType(
                  NotificationMessageType.contest, value),
            ),
            _buildNotificationTypeSwitch(
              context,
              'Oyun Bildirimleri',
              'Oyun başlangıcı ve bitişi bildirimleri',
              Icons.sports_esports,
              provider.settings.gameNotifications,
              (value) => provider.toggleNotificationType(
                  NotificationMessageType.gameStart, value),
            ),
            _buildNotificationTypeSwitch(
              context,
              'Sıralama Bildirimleri',
              'Sıralama değişiklikleri ve liderlik tablosu',
              Icons.leaderboard,
              provider.settings.rankingNotifications,
              (value) => provider.toggleNotificationType(
                  NotificationMessageType.ranking, value),
            ),
            _buildNotificationTypeSwitch(
              context,
              'Ödül Bildirimleri',
              'Ödül kazanma ve ödül dağıtımı',
              Icons.card_giftcard,
              provider.settings.prizeNotifications,
              (value) => provider.toggleNotificationType(
                  NotificationMessageType.prize, value),
            ),
            _buildNotificationTypeSwitch(
              context,
              'Sistem Bildirimleri',
              'Uygulama güncellemeleri ve duyurular',
              Icons.settings,
              provider.settings.systemNotifications,
              (value) => provider.toggleNotificationType(
                  NotificationMessageType.system, value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTypeSwitch(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: value ? Colors.blue : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsCard(
      BuildContext context, NotificationProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gelişmiş Ayarlar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildNotificationTypeSwitch(
              context,
              'Ses',
              'Bildirim sesi çalar',
              Icons.volume_up,
              provider.settings.soundEnabled,
              (value) => provider.updateSettings(
                provider.settings.copyWith(soundEnabled: value),
              ),
            ),
            _buildNotificationTypeSwitch(
              context,
              'Titreşim',
              'Bildirim geldiğinde titreşim',
              Icons.vibration,
              provider.settings.vibrationEnabled,
              (value) => provider.updateSettings(
                provider.settings.copyWith(vibrationEnabled: value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugCard(BuildContext context, NotificationProvider provider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test ve Hata Ayıklama',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (provider.fcmToken != null) ...[
              Text(
                'FCM Token:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  provider.fcmToken!,
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => provider.sendTestNotification(),
                    child: const Text('Test Bildirimi'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => provider.refreshToken(),
                    child: const Text('Token Yenile'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPermissionStatusText(NotificationPermissionStatus status) {
    switch (status) {
      case NotificationPermissionStatus.authorized:
        return 'Bildirimler için izin verildi';
      case NotificationPermissionStatus.denied:
        return 'Bildirimler için izin reddedildi';
      case NotificationPermissionStatus.notDetermined:
        return 'Bildirim izni henüz istenmedi';
      case NotificationPermissionStatus.provisional:
        return 'Geçici bildirim izni verildi';
    }
  }
}
