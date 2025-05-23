import 'package:flutter/material.dart';
import 'package:testfront/core/models/notification_dto.dart';
import 'package:testfront/core/services/NotificationService.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationDto> _notifications = [];
  bool _isLoading = false;

  List<NotificationDto> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    final response = await _notificationService.fetchUserNotifications();

    if (response.success && response.data != null) {
      _notifications = response.data!;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    final success = await _notificationService.markAsRead(id);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationDto(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _notificationService.markAllAsRead();
    if (success) {
      _notifications = _notifications.map((n) => NotificationDto(
        id: n.id,
        title: n.title,
        message: n.message,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();

      notifyListeners();
    }
  }

  void addNotification(NotificationDto notification) {
    _notifications.insert(0, notification); // On ajoute en haut de la liste
    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }
}
