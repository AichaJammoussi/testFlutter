/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/providers/notification_provider.dart';
import 'package:testfront/features/home/notificationTest.dart';

class NotificationBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationBadge({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: onTap,
            ),
            if (provider.unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    provider.unreadCount > 99 
                      ? '99+' 
                      : provider.unreadCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// Widget pour une liste compacte de notifications (ex: dans un drawer)
class NotificationList extends StatelessWidget {
  final int maxItems;

  const NotificationList({Key? key, this.maxItems = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final notifications = provider.notifications.take(maxItems).toList();

        if (notifications.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Aucune notification',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column(
          children: [
            ...notifications.map((notification) => ListTile(
              dense: true,
              leading: Icon(
                Icons.notifications,
                color: notification.isRead ? Colors.grey : Colors.blue,
                size: 20,
              ),
              title: Text(
                notification.title,
                style: TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                notification.message,
                style: TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                if (!notification.isRead) {
                  provider.markAsRead(notification.id);
                }
              },
            )),
            if (provider.notifications.length > maxItems)
              TextButton(
                onPressed: () {
                  // Naviguer vers l'écran complet des notifications
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(),
                    ),
                  );
                },
                child: Text('Voir toutes les notifications'),
              ),
          ],
        );
      },
    );
  }
}*/

import 'dart:ui';

import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const NotificationBadge({
    Key? key,
    required this.unreadCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white),
          onPressed: onTap,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Center(
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
