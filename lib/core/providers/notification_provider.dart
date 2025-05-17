// providers/notification_provider.dart
import 'package:flutter/foundation.dart';
import 'package:testfront/core/models/NotificationCreateDTO.dart';
import 'package:testfront/core/services/NotificationService.dart';
import '../models/notification_dto.dart';
import '../models/response_dto.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  String? _error;
  Map<String, String> _fieldErrors = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, String> get fieldErrors => _fieldErrors;

  List<NotificationDto> _notifications = [];
  int _unreadCount = 0;

  List<NotificationDto> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    notifyListeners();

    final response = await _notificationService.fetchNotifications(userId);
    if (response.success && response.data != null) {
      _notifications = response.data!;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUnreadCount(String userId) async {
    final response = await _notificationService.fetchUnreadCount(userId);
    if (response.success && response.data != null) {
      _unreadCount = response.data!;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    final result = await _notificationService.markNotificationAsRead(id);
    if (result.success && result.data == true) {
      _notifications =
          _notifications.map((n) {
            if (n.id == id)
              return NotificationDto(
                id: n.id,
                title: n.title,
                message: n.message,
                isRead: true,
                createdAt: n.createdAt,
              );
            return n;
          }).toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  Future<bool> createNotification(NotificationCreateDTO dto) async {
    _isLoading = true;
    _error = null;
    _fieldErrors = {};
    notifyListeners();

    final response = await _notificationService.createNotification(dto);

    if (response.success) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      _fieldErrors = response.errors ?? {};
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
