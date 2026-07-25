import 'package:flutter/material.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final notifications = [
      {
        'title': 'Leave Approved',
        'message': 'Your leave request for Oct 15 has been approved by the HOD.',
        'time': '10 mins ago',
        'isRead': false,
        'type': 'approval',
      },
      {
        'title': 'Room Change',
        'message': 'CS301 has been moved from Room 101 to Room 105 for Period 3.',
        'time': '1 hour ago',
        'isRead': false,
        'type': 'alert',
      },
      {
        'title': 'Timetable Published',
        'message': 'The timetable for Even Semester 2026 has been published.',
        'time': 'Yesterday',
        'isRead': true,
        'type': 'info',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Notification Preferences',
            onPressed: () => _showPreferencesDialog(context, theme),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification, theme);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, ThemeData theme) {
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;
    
    IconData icon;
    Color color;
    
    switch (type) {
      case 'approval':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'alert':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info;
        color = Colors.blue;
    }

    return Card(
      elevation: 0,
      color: isRead ? theme.colorScheme.surface : color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isRead ? theme.colorScheme.outlineVariant : color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification['title'] as String,
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        notification['time'] as String,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification['message'] as String,
                    style: TextStyle(
                      color: isRead ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreferencesDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Preferences'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: true,
              onChanged: (val) {},
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              value: false,
              onChanged: (val) {},
            ),
            SwitchListTile(
              title: const Text('Daily Summary'),
              value: true,
              onChanged: (val) {},
            ),
            SwitchListTile(
              title: const Text('Do Not Disturb (After 6 PM)'),
              value: false,
              onChanged: (val) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
