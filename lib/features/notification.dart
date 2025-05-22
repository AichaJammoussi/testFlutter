import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/providers/notification_provider.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications (${notificationProvider.unreadCount})'),
      ),
      body: ListView.builder(
        itemCount: notificationProvider.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationProvider.notifications[index];
          return ListTile(
            title: Text(notification.title),
            subtitle: Text(notification.message),
            trailing: notification.isRead ? null : Icon(Icons.circle, color: Colors.red, size: 10),
            onTap: () {
              if (!notification.isRead) {
                notificationProvider.markAsRead(notification.id);
              }
            },
          );
        },
      ),
    );
  }
}
