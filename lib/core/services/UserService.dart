import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
import 'package:testfront/core/models/UserDto.dart';
import 'package:testfront/core/models/auth_storage.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/models/tache_creation_dto.dart';
import 'package:testfront/core/models/tache_dto.dart';
import 'package:testfront/core/services/auth_service.dart';

class UserService {
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

  ResponseDTO<T> _handleError<T>(dynamic e) {
    debugPrint('TacheService Error: $e');
    return ResponseDTO(
      success: false,
      message: e is Exception ? e.toString() : 'Erreur inconnue',
    );
  }
   Future<ResponseDTO<UserDTO>> getUserById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/Employe/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return ResponseDTO<UserDTO>.fromJson(
          json.decode(response.body),
          (data) => UserDTO.fromJson(data),
        );
      } else {
        return ResponseDTO<UserDTO>(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
          errors: {'http': 'Erreur HTTP ${response.statusCode}'},
        );
      }
    } catch (e) {
      return ResponseDTO<UserDTO>(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }
}
