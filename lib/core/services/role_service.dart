import 'dart:convert';
import 'package:http/http.dart' as http;

class RoleService {
  final String baseUrl = 'https://localhost:7261/api';

  // Headers sans authentification
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

  // Récupérer tous les rôles
  Future<Map<String, dynamic>> getAllRoles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/role'),
        headers: getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // Créer un nouveau rôle
  Future<Map<String, dynamic>> createRole(String roleName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Role'),
        headers: getHeaders(),
        body: jsonEncode(roleName),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // Les autres méthodes (sans le token)
  Future<Map<String, dynamic>> updateRole(
      String roleId, String newRoleName) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Role/$roleId'),
        headers: getHeaders(),
        body: jsonEncode(newRoleName),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteRole(String roleId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/Role/$roleId'),
        headers: getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> assignRolesToUser(
      String userId, List<String> roles) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Role/assign-roles'),
        headers: getHeaders(),
        body: jsonEncode({
          'userId': userId,
          'roles': roles,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> getUserRoles(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Role/user/$userId'),
        headers: getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  Future<Map<String, dynamic>> getAllUsersWithRoles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Role/users-with-roles'),
        headers: getHeaders(),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}
