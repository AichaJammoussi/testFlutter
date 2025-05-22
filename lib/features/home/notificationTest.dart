import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testfront/core/models/notification_dto.dart';
import 'package:testfront/core/services/NotificationService.dart';

class NotificationListPage extends StatefulWidget {
  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  @override
  void initState() {
    super.initState();
    // Charger les notifications au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationService>(context, listen: false).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          Consumer<NotificationService>(
            builder: (context, service, child) {
              return IconButton(
                icon: Icon(Icons.done_all),
                onPressed: service.unreadCount > 0 
                  ? () => service.markAllAsRead()
                  : null,
                tooltip: 'Marquer tout comme lu',
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationService>(
        builder: (context, service, child) {
          if (service.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.loadNotifications(),
            child: ListView.builder(
              itemCount: service.notifications.length,
              itemBuilder: (context, index) {
                final notification = service.notifications[index];
                return NotificationTile(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

// 4. Widget pour afficher une notification individuelle
class NotificationTile extends StatelessWidget {
  final NotificationDto notification;

  const NotificationTile({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, service, child) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Icon(
              notification.isRead ? Icons.mail_outline : Icons.mail,
              color: notification.isRead ? Colors.grey : Colors.blue,
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message),
                SizedBox(height: 4),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              if (!notification.isRead) {
                service.markAsRead(notification.id);
              }
              // Vous pouvez ajouter ici la navigation vers le détail
              _handleNotificationTap(context, notification);
            },
            trailing: !notification.isRead
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} jour(s)';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure(s)';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s)';
    } else {
      return 'À l\'instant';
    }
  }

  void _handleNotificationTap(BuildContext context, NotificationDto notification) {
    // Gérer la navigation selon le type de notification
    // Par exemple :
    /*
    switch (notification.type) {
      case 'TASK_ASSIGNED':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailPage(taskId: notification.entityId),
          ),
        );
        break;
      case 'MISSION_UPDATE':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MissionDetailPage(missionId: notification.entityId),
          ),
        );
        break;
      default:
        // Action par défaut
        break;
    }
    */
  }
}