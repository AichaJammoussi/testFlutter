import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:testfront/core/models/NotificationCreateDTO.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/services/signalr_client.dart';
import '../config/api_config.dart';
import '../models/notification_dto.dart';
import 'auth_service.dart';

/*
class NotificationService {
  final String _baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  final SignalRService _signalRService;

  NotificationService(this._signalRService) {
    _signalRService.onNotificationReceived = (notification) {
      _notificationStreamController.add(notification);
    };
    _signalRService.startConnection();
  }

  // Stream pour notifications en temps réel
  final StreamController<NotificationDto> _notificationStreamController = StreamController.broadcast();

  Stream<NotificationDto> get notificationsStream => _notificationStreamController.stream;

  Future<void> dispose() async {
    await _signalRService.stopConnection();
    await _notificationStreamController.close();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'accept': '*',
      if (kDebugMode) 'ngrok-skip-browser-warning': 'true',
    };
  }

  Future<ResponseDTO<List<NotificationDto>>> fetchNotifications() async {
    try {
      final headers = await _getHeaders();

      final uri = Uri.parse('$_baseUrl${ApiConfig.notifications}');
      final response = await http.get(uri, headers: headers);

      debugPrint('✅ Statut HTTP: ${response.statusCode}');
      debugPrint('📦 Réponse brute: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final data = decoded['data'];
        if (data is List) {
          final notifications =
              data.map((x) => NotificationDto.fromJson(x)).toList().cast<NotificationDto>();

          return ResponseDTO<List<NotificationDto>>(
            success: decoded['success'] ?? true,
            message: decoded['message'] ?? '',
            data: notifications,
          );
        } else {
          return ResponseDTO(
            success: false,
            message: 'Format inattendu des données.',
          );
        }
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur HTTP ${response.statusCode} lors de la récupération des notifications',
        );
      }
    } catch (e) {
      debugPrint('❌ Exception attrapée: $e');
      return ResponseDTO(success: false, message: 'Exception attrapée: $e');
    }
  }

  Future<ResponseDTO<int>> fetchUnreadCount() async {
    try {
      final headers = await _getHeaders();

      final uri = Uri.parse('$_baseUrl${ApiConfig.notifications}/unread-count');
      final response = await http.get(uri, headers: headers);

      debugPrint('🔢 Statut unread-count: ${response.statusCode}');
      debugPrint('📦 Corps: ${response.body}');

      if (response.statusCode == 200) {
        return ResponseDTO<int>.fromJson(
          json.decode(response.body),
          (data) => data as int,
        );
      } else {
        return ResponseDTO<int>(
          success: false,
          message: 'Erreur lors de la récupération du nombre de notifications non lues',
        );
      }
    } catch (e) {
      return ResponseDTO<int>(success: false, message: 'Exception: $e');
    }
  }

  Future<ResponseDTO<bool>> markNotificationAsRead(int notificationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl${ApiConfig.notifications}/$notificationId/read'),
        headers: headers,
      );

      debugPrint('📬 Marquage comme lu: ${response.statusCode}');
      debugPrint('📦 Corps: ${response.body}');

      return ResponseDTO<bool>.fromJson(
        json.decode(response.body),
        (data) => data as bool,
      );
    } catch (e) {
      return ResponseDTO(success: false, message: 'Exception: $e');
    }
  }

  Future<ResponseDTO<NotificationDto>> createNotification(
    NotificationCreateDTO dto,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl${ApiConfig.notifications}');

      print('📤 Envoi notification → $url');
      print('📄 Corps de la requête : ${json.encode(dto.toJson())}');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(dto.toJson()),
      );

      print('📥 Statut HTTP: ${response.statusCode}');
      print('📥 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // On parse l'objet NotificationDto dans le champ "data"
        return ResponseDTO<NotificationDto>.fromJson(
          decoded,
          (data) => NotificationDto.fromJson(data),
        );
      } else {
        final decoded = response.body.isNotEmpty ? json.decode(response.body) : {};

        print('❌ Erreur API notification: ${decoded['message'] ?? 'Réponse vide'}');

        return ResponseDTO<NotificationDto>(
          success: false,
          message: decoded['message'] ?? 'Erreur lors de la création de la notification',
          errors: decoded['errors'] != null
              ? Map<String, String>.from(decoded['errors'])
              : {"http": "Code HTTP ${response.statusCode}"},
          data: null,
        );
      }
    } catch (e) {
      print('💥 Exception notification: $e');
      return ResponseDTO<NotificationDto>(
        success: false,
        message: 'Exception: ${e.toString()}',
        errors: {"exception": e.toString()},
        data: null,
      );
    }
  }
}
*/
class NotificationService extends ChangeNotifier {
  final String baseUrl;
  final Future<String> Function() getToken; // Now accepts async function

  HubConnection? _hubConnection;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  List<NotificationDto> _notifications = [];
  int _unreadCount = 0;
  bool _isConnected = false;

  List<NotificationDto> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isConnected => _isConnected;

  NotificationService({required this.baseUrl, required this.getToken});

  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeSignalR();
    await loadNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Gérer le tap sur la notification locale
    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _handleNotificationNavigation(data);
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Implémenter la navigation selon le type de notification
    // Par exemple, naviguer vers la page de la tâche ou mission
  }

  Future<void> _initializeSignalR() async {
    try {
      final token = getToken();

      _hubConnection =
          HubConnectionBuilder()
              .withUrl(
                '$baseUrl/notificationHub',
                options: HttpConnectionOptions(
                  accessTokenFactory: () => Future.value(token),
                ),
              )
              .build();

      _hubConnection?.on('ReceiveNotification', (args) {
        if (args != null && args.isNotEmpty) {
          final notificationData = args[0] as Map<String, dynamic>;
          final notification = NotificationDto.fromJson(notificationData);

          _notifications.insert(0, notification);
          _unreadCount++;

          _showLocalNotification(notification);
          notifyListeners();
        }
      });

      _hubConnection?.on('NotificationRead', (args) {
        if (args != null && args.isNotEmpty) {
          final notificationId = args[0] as int;
          final index = _notifications.indexWhere(
            (n) => n.id == notificationId,
          );
          if (index != -1 && !_notifications[index].isRead) {
            _notifications[index] = NotificationDto(
              id: _notifications[index].id,
              title: _notifications[index].title,
              message: _notifications[index].message,
              isRead: true,
              createdAt: _notifications[index].createdAt,
            );
            _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
            notifyListeners();
          }
        }
      });

      _hubConnection?.on('AllNotificationsRead', (args) {
        for (int i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].isRead) {
            _notifications[i] = NotificationDto(
              id: _notifications[i].id,
              title: _notifications[i].title,
              message: _notifications[i].message,
              isRead: true,
              createdAt: _notifications[i].createdAt,
            );
          }
        }
        _unreadCount = 0;
        notifyListeners();
      });

      _hubConnection?.on('NotificationDeleted', (args) {
        if (args != null && args.isNotEmpty) {
          final notificationId = args[0] as int;
          final index = _notifications.indexWhere(
            (n) => n.id == notificationId,
          );
          if (index != -1) {
            if (!_notifications[index].isRead) {
              _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
            }
            _notifications.removeAt(index);
            notifyListeners();
          }
        }
      });

      await _hubConnection?.start();
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur SignalR: $e');
      _isConnected = false;
    }
  }

  Future<void> _showLocalNotification(NotificationDto notification) async {
    const androidDetails = AndroidNotificationDetails(
      'task_notifications',
      'Notifications de tâches',
      channelDescription: 'Notifications pour les tâches et missions',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id,
      notification.title,
      notification.message,
      details,
      payload: jsonEncode({
        'id': notification.id,
        'title': notification.title,
        'message': notification.message,
      }),
    );
  }

  Future<void> loadNotifications({int page = 1, int pageSize = 20}) async {
    try {
      final token = getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notification?page=$page&pageSize=$pageSize'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (page == 1) {
          _notifications =
              data.map((json) => NotificationDto.fromJson(json)).toList();
        } else {
          _notifications.addAll(
            data.map((json) => NotificationDto.fromJson(json)),
          );
        }
        await _loadUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des notifications: $e');
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final token = getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notification/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _unreadCount = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint(
        'Erreur lors du chargement du nombre de notifications non lues: $e',
      );
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final token = getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/api/notification/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // La mise à jour sera gérée par SignalR
      }
    } catch (e) {
      debugPrint('Erreur lors du marquage de la notification: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/api/notification/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // La mise à jour sera gérée par SignalR
      }
    } catch (e) {
      debugPrint('Erreur lors du marquage de toutes les notifications: $e');
    }
  }
}
