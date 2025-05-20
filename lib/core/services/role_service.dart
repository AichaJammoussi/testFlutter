import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/RoleDto.dart';
import 'package:testfront/core/models/UserRoleAssignmentDTO.dart';
import 'package:testfront/core/models/UserRoleAssignmentMultiDTO.dart';
import 'package:testfront/core/models/UserRolesDTO.dart';
import 'package:testfront/core/models/response.dart';

import 'package:testfront/core/services/auth_service.dart';

class RoleService {
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
    debugPrint('RoleService Error: $e');
    return ResponseDTO(
      success: false,
      message: e is Exception ? e.toString() : 'Erreur inconnue',
    );
  }

  Future<ResponseDTO<List<RoleDTO>>> fetchRoles() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.role}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<List<RoleDTO>>.fromJson(
          json.decode(response.body),
          (data) => List<RoleDTO>.from(data.map((x) => RoleDTO.fromJson(x))),
        );
      }
      return _handleError('Code ${response.statusCode}');
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseDTO<RoleDTO>> createRole(String roleName) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'roleName': roleName, // Correspond au nom attendu par le backend
      });

      debugPrint('Envoi au backend: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.role}'),
        headers: {
          ...headers,
          'Content-Type':
              'application/json', // Assurez-vous que ce header est présent
        },
        body: body,
      );

      debugPrint(
        'Réponse du backend: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return ResponseDTO<RoleDTO>.fromJson(
          decoded,
          (data) => RoleDTO.fromJson(data),
        );
      }
      return ResponseDTO(
        success: false,
        message: 'Erreur ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Erreur createRole: $e');
      return ResponseDTO(success: false, message: e.toString());
    }
  }

  // 3️⃣ Met à jour un rôle
  Future<ResponseDTO<RoleDTO>> updateRole(String roleId, String newName) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'NewRoleName': newName, // Correspond au champ du DTO
      });

      final response = await http.put(
        Uri.parse('$_baseUrl${ApiConfig.role}/$roleId'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ResponseDTO<RoleDTO>.fromJson(
          decoded,
          (data) => RoleDTO.fromJson(data),
        );
      }
      return ResponseDTO(
        success: false,
        message: 'Erreur ${response.statusCode}',
      );
    } catch (e) {
      return ResponseDTO(success: false, message: e.toString());
    }
  }

  // 4️⃣ Supprime un rôle
  Future<ResponseDTO<RoleDTO>> deleteRole(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl${ApiConfig.role}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO.fromJson(
          json.decode(response.body),
          (data) => RoleDTO.fromJson(data),
        );
      }

      return _handleError('Erreur ${response.statusCode}');
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseDTO<List<UserRolesDTO>>> getUsersByRole(
    String roleName,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
        '$_baseUrl${ApiConfig.role}/users-by-role/$roleName',
      );

      print('[API CALL] GET $url');
      print('[HEADERS] $headers');

      final response = await http.get(url, headers: headers);

      print('[RESPONSE STATUS] ${response.statusCode}');
      print('[RESPONSE BODY] ${response.body}');

      if (response.statusCode == 200) {
        return ResponseDTO<List<UserRolesDTO>>.fromJson(
          json.decode(response.body),
          (data) => List<UserRolesDTO>.from(
            data.map((x) => UserRolesDTO.fromJson(x)),
          ),
        );
      } else {
        print('[ERROR] Status code: ${response.statusCode}');
        return ResponseDTO(
          success: false,
          message: 'Erreur ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[EXCEPTION] $e');
      return ResponseDTO(success: false, message: e.toString());
    }
  }

  Future<ResponseDTO<UserRoleAssignmentDTO>> assignRolesToUser(
    UserRoleAssignmentDTO dto,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.role}/assign-roles'),
        headers: headers,
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 200) {
        return ResponseDTO<UserRoleAssignmentDTO>.fromJson(
          json.decode(response.body),
          (data) => UserRoleAssignmentDTO.fromJson(data),
        );
      }
      return _handleError('Code ${response.statusCode}');
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<ResponseDTO<UserRoleAssignmentMultiDTO>> assignRolesToMultipleUsers(
    List<String> userIds,
    List<String> roles,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({'userIds': userIds, 'roles': roles});

      debugPrint('Envoi au backend: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.role}/assign-roles-to-multiple-users'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint(
        'Réponse du backend: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return ResponseDTO<UserRoleAssignmentMultiDTO>.fromJson(
          decoded,
          (data) => UserRoleAssignmentMultiDTO.fromJson(data),
        );
      }
      return ResponseDTO(
        success: false,
        message: 'Erreur ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('Erreur assignRolesToMultipleUsers: $e');
      return ResponseDTO(success: false, message: e.toString());
    }
  }

  /*// Nouvelle méthode pour supprimer un rôle d'un utilisateur
  Future<ResponseDTO> removeRoleFromUser(String userId, String roleName) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
        '$_baseUrl${ApiConfig.role}/remove/$userId/$roleName',
      );

      debugPrint('[API CALL] DELETE $url');

      final response = await http.delete(url, headers: headers);

      debugPrint('[RESPONSE STATUS] ${response.statusCode}');
      debugPrint('[RESPONSE BODY] ${response.body}');

      if (response.statusCode == 200) {
        return ResponseDTO.fromJson(
          json.decode(response.body),
          (data) => null, // Pas de données à parser pour une suppression
        );
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[EXCEPTION] $e');
      return ResponseDTO(
        success: false,
        message: 'Erreur lors de la suppression: ${e.toString()}',
      );
    }
  }
*/

  Future<ResponseDTO<List<UserRolesDTO>>> getAllUsersWithRoles() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.role}/users-with-roles'),
        headers: headers,
      );

      debugPrint(
        'Réponse du backend: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        return ResponseDTO<List<UserRolesDTO>>.fromJson(
          json.decode(response.body),
          (data) => List<UserRolesDTO>.from(
            data.map((x) => UserRolesDTO.fromJson(x)),
          ),
        );
      }
      return _handleError('Code ${response.statusCode}');
    } catch (e) {
      debugPrint(
        'Erreur lors de la récupération des utilisateurs avec leurs rôles: $e',
      );
      return _handleError(e);
    }
  }

  Future<ResponseDTO> removeRoleFromUser(String userId, String roleName) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
        '$_baseUrl${ApiConfig.role}/remove/$userId/$roleName',
      );

      debugPrint('[API CALL] DELETE $url');

      final response = await http.delete(url, headers: headers);

      debugPrint('[RESPONSE STATUS] ${response.statusCode}');
      debugPrint('[RESPONSE BODY] ${response.body}');

      if (response.statusCode == 200) {
        return ResponseDTO.fromJson(
          json.decode(response.body),
          (data) => null, // Pas de données à parser pour une suppression
        );
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[EXCEPTION] $e');
      return ResponseDTO(
        success: false,
        message: 'Erreur lors de la suppression: ${e.toString()}',
      );
    }
  }

  // 6️⃣ Récupère les utilisateurs avec leurs rôles

  Future<ResponseDTO<List<String>>> getUserRoles(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.role}/users/$userId/roles'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<List<String>>.fromJson(
          json.decode(response.body),
          (data) => List<String>.from(data),
        );
      }
      return ResponseDTO<List<String>>(
        success: false,
        message: 'Erreur ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      return ResponseDTO<List<String>>(
        success: false,
        message: 'Erreur lors de la récupération des rôles: ${e.toString()}',
      );
    }
  }
  
}

/*
  Future<ResponseDTO<List<UserRolesDTO>>> getUsersByRole(String roleName) async {
  try {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/Roles/users-by-role/$roleName'),
      headers: headers,
    );

     if (response.statusCode == 200) {
        return ResponseDTO.fromJson(
          json.decode(response.body),
          (data) => RoleDTO.fromJson(data),
        );
    }
    return ResponseDTO(success: false);
  } catch (e) {
    debugPrint('Erreur getUsersByRole: $e');
    return ResponseDTO(success: false);
  }
}

  // 7️⃣ Récupère les rôles d'un utilisateur spécifique
  Future<ResponseDTO<List<String>>> getUserRoles(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.role}/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<List<String>>.fromJson(
          json.decode(response.body),
          (data) => List<String>.from(data),
        );
      }
      return _handleError('Code ${response.statusCode}');
    } catch (e) {
      return _handleError(e);
    }
  }
}*/
