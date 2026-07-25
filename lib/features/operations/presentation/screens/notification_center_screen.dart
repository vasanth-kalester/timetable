import 'package:flutter/material.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock notifications
    final notifications = [
      {
        'title': 'Substitution Approved',
        'message': 'Your substitution request for CS301-T1 on Oct 14 has been approved. Dr. Priya will take the class.',
        'type': 'substitution',
        'time': '10 mins ago',
        'isRead': false,
      },
      {
        'title': 'Room Change Alert',
        'message': 'Your class ME101 on Oct 14 has been moved from Lab 3 to Room 204 due to maintenance.',
        'type': 'change',
        'time': '1 hour ago',
        'isRead': false,
      },
      {
        'title': 'New Substitution Assignment',
        'message': 'You have been assigned as a substitute for CS201 on Oct 12, Period 3.',
        'type': 'substitution',
        'time': '2 days ago',
        'isRead': true,
      },
      {
        'title': 'Event Scheduled',
        'message': 'A Guest Lecture is scheduled in the Seminar Hall on Oct 15. Your class CS401 has been relocated.',
        'type': 'info',
        'time': '3 days ago',
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all as read'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification, theme);
        },
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, ThemeData theme) {
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] as String;
    
    IconData icon;
    Color color;
    
    switch (type) {
      case 'substitution':
        icon = Icons.person_search;
        color = Colors.blue;
        break;
      case 'change':
        icon = Icons.swap_horiz;
        color = Colors.orange;
        break;
      case 'alert':
        icon = Icons.warning_amber_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.grey;
    }

    return Container(
      color: isRead ? Colors.transparent : theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              notification['title'] as String,
              style: TextStyle(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            Text(
              notification['time'] as String,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            notification['message'] as String,
            style: TextStyle(
              color: isRead ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
            ),
          ),
        ),
        trailing: !isRead
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          // Mark as read
        },
      ),
    );
  }
}
