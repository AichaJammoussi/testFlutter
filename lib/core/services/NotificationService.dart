import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/services/auth_service.dart';
import 'package:testfront/core/models/notification_dto.dart';

class NotificationService {
  final String _baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (kDebugMode) 'ngrok-skip-browser-warning': 'true',
    };
  }

  // 📨 Récupérer les notifications utilisateur
  Future<ResponseDTO<List<NotificationDto>>> fetchUserNotifications() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/notifications/user'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      final notifications = data.map((e) => NotificationDto.fromJson(e)).toList();
      return ResponseDTO(success: true, data: notifications, message: body['message']);
    } else {
      return ResponseDTO(success: false, message: "Erreur lors de la récupération");
    }
  }

  // 🔔 Créer une notification
  Future<bool> createNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      "userId": userId,
      "title": title,
      "message": message,
    });

    final response = await http.post(
      Uri.parse('$_baseUrl/api/notifications'),
      headers: headers,
      body: body,
    );

    return response.statusCode == 200;
  }

  // ✅ Marquer une notification comme lue
  Future<bool> markAsRead(int id) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/api/notifications/$id/read'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  // ✅ Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/api/notifications/mark-all-read'),
      headers: headers,
    );

    return response.statusCode == 200;
  }
}
