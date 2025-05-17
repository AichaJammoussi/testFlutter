// services/notification_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:testfront/core/models/NotificationCreateDTO.dart';
import 'package:testfront/core/models/response.dart';
import '../config/api_config.dart';
import '../models/notification_dto.dart';
import 'auth_service.dart';

class NotificationService {
  final String _baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'accept': '*/*',
      if (kDebugMode) 'ngrok-skip-browser-warning': 'true',
    };
  }

  Future<ResponseDTO<List<NotificationDto>>> fetchNotifications(
    String userId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.notifications}/user/$userId'),
        headers: headers,
      );

      debugPrint('✅ Statut HTTP: ${response.statusCode}');
      debugPrint('📦 Réponse brute: ${response.body}');

      if (response.statusCode == 200) {
        return ResponseDTO<List<NotificationDto>>.fromJson(
          json.decode(response.body),
          (data) => List<NotificationDto>.from(
            data.map((x) => NotificationDto.fromJson(x)),
          ),
        );
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur lors de la récupération des notifications',
        );
      }
    } catch (e) {
      return ResponseDTO(success: false, message: 'Exception: $e');
    }
  }

  Future<ResponseDTO<int>> fetchUnreadCount(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '$_baseUrl${ApiConfig.notifications}/user/$userId/unread-count',
        ),
        headers: headers,
      );

      debugPrint('🔢 Statut unread-count: ${response.statusCode}');
      debugPrint('📦 Corps: ${response.body}');

      if (response.statusCode == 200) {
        return ResponseDTO<int>.fromJson(
          json.decode(response.body),
          (data) => data as int,
        );
      } else {
        return ResponseDTO(
          success: false,
          message:
              'Erreur lors de la récupération du nombre de notifications non lues',
        );
      }
    } catch (e) {
      return ResponseDTO(success: false, message: 'Exception: $e');
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
        final decoded =
            response.body.isNotEmpty ? json.decode(response.body) : {};

        print(
          '❌ Erreur API notification: ${decoded['message'] ?? 'Réponse vide'}',
        );

        return ResponseDTO<NotificationDto>(
          success: false,
          message:
              decoded['message'] ??
              'Erreur lors de la création de la notification',
          errors:
              decoded['errors'] != null
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
