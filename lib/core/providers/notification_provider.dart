import 'package:flutter/material.dart';
import 'package:testfront/core/models/notification_dto.dart';
import 'package:testfront/core/services/NotificationService.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;

  List<NotificationDto> _notifications = [];
  int _unreadCount = 0;

  NotificationProvider(this._notificationService) {
    _listenToNotifications();
    fetchNotifications();
    fetchUnreadCount();
  }

  List<NotificationDto> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void _listenToNotifications() {
    _notificationService.notificationsStream.listen((notification) {
      _notifications.insert(0, notification);
      _unreadCount++;
      notifyListeners();
    });
  }

  Future<void> fetchNotifications() async {
    final response = await _notificationService.fetchNotifications();
    if (response.success && response.data != null) {
      _notifications = response.data!;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    final response = await _notificationService.fetchUnreadCount();
    if (response.success && response.data != null) {
      _unreadCount = response.data!;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final response = await _notificationService.markNotificationAsRead(notificationId);
    if (response.success) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationDto(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    }
  }
}
