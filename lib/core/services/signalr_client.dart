import 'dart:async';
import 'dart:convert';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/notification_dto.dart';
import 'auth_service.dart';

class SignalRService {
  final AuthService _authService = AuthService();

  HubConnection? _hubConnection;

  /// Callback appelé à chaque notification reçue
  void Function(NotificationDto notification)? onNotificationReceived;
  String _baseUrl = ApiConfig.baseUrl;

  /// URL de ton hub SignalR (remplace par ta vraie URL)
  final String _hubUrl = 'https://localhost:7261/signalr/notificationhub';

  /// Démarre la connexion SignalR
  Future<void> startConnection() async {
    final token = await _authService.getAuthToken();

    if (token == null) {
      print('[SignalR] Token non disponible, impossible de se connecter');
      return;
    }

    _hubConnection!.onclose(({error}) {
      print('[SignalR] Connexion fermée: $error');
      // Implémenter une reconnexion si nécessaire
    });

    _hubConnection!.on('ReceiveNotification', (List<Object?>? arguments) {
      _handleIncomingNotification(arguments);
    });

    try {
      await _hubConnection!.start();
      print('[SignalR] Connexion démarrée');
    } catch (e) {
      print('[SignalR] Erreur de connexion: $e');
    }
  }

  /// Arrête proprement la connexion
  Future<void> stopConnection() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      print('[SignalR] Connexion stoppée');
      _hubConnection = null;
    }
  }

  /// Gère la réception des notifications
  void _handleIncomingNotification(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    final rawData = arguments[0];

    try {
      late NotificationDto notification;

      if (rawData is Map<String, dynamic>) {
        notification = NotificationDto.fromJson(rawData);
      } else if (rawData is Map) {
        notification = NotificationDto.fromJson(
          Map<String, dynamic>.from(rawData),
        );
      } else if (rawData is String) {
        final Map<String, dynamic> map = json.decode(rawData);
        notification = NotificationDto.fromJson(map);
      } else {
        print('[SignalR] Type inattendu reçu: ${rawData.runtimeType}');
        return;
      }

      onNotificationReceived?.call(notification);
    } catch (e) {
      print('[SignalR] Erreur lors du parsing notification: $e');
    }
  }

  /// Envoi d'une notification (optionnel)
  Future<void> sendNotification(
    String userId,
    NotificationDto notification,
  ) async {
    if (_hubConnection == null ||
        _hubConnection!.state != HubConnectionState.Connected) {
      print('[SignalR] Pas connecté, impossible d\'envoyer la notification');
      return;
    }
    try {
      await _hubConnection!.invoke(
        'SendNotificationToUser',
        args: [userId, notification.toJson()],
      );
      print('[SignalR] Notification envoyée');
    } catch (e) {
      print('[SignalR] Erreur lors de l\'envoi: $e');
    }
  }
}
