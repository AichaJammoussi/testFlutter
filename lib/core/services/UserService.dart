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
import 'package:testfront/core/models/user.dart';
import 'package:testfront/core/models/userDTOUser.dart';
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
      final url = Uri.parse('$_baseUrl/api/Profile/$id');
      final headers = await _getHeaders();

      print('🔍 [UserService] Envoi de la requête GET vers : $url');
      print('🧾 Headers : $headers');

      final response = await http.get(url, headers: headers);

      print('📬 [UserService] Statut HTTP : ${response.statusCode}');
      print('📨 [UserService] Corps de la réponse : ${response.body}');

      if (response.statusCode == 200) {
        final dto = ResponseDTO<UserDTO>.fromJson(
          json.decode(response.body),
          (data) => UserDTO.fromJson(data),
        );
        print(
          '✅ [UserService] Données utilisateur récupérées avec succès : ${dto.data}',
        );
        return dto;
      } else {
        print('❌ [UserService] Erreur serveur : ${response.statusCode}');
        return ResponseDTO<UserDTO>(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
          errors: {'http': 'Erreur HTTP ${response.statusCode}'},
        );
      }
    } catch (e) {
      print(
        '🚨 [UserService] Exception lors de la récupération de l\'utilisateur : $e',
      );
      return ResponseDTO<UserDTO>(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }

  Future<ResponseDTO<Userdtouser>> getUserByIdUser(String id) async {
    try {
      final url = Uri.parse('$_baseUrl/api/Profile/user/$id');
      final headers = await _getHeaders();

      print('>>> [getUserByIdUser] URL: $url');
      print('>>> [getUserByIdUser] Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('>>> [getUserByIdUser] Response status: ${response.statusCode}');
      print('>>> [getUserByIdUser] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print('>>> [getUserByIdUser] Decoded JSON: $decoded');

        return ResponseDTO<Userdtouser>.fromJson(
          decoded,
          (data) => Userdtouser.fromJson(data),
        );
      } else {
        return ResponseDTO<Userdtouser>(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
          errors: {'http': 'Erreur HTTP ${response.statusCode}'},
        );
      }
    } catch (e) {
      print('>>> [getUserByIdUser] Exception: $e');
      return ResponseDTO<Userdtouser>(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }
}
