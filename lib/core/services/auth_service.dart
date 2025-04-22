import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as client;
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/login_response.dart';
import 'package:testfront/core/models/register_data.dart';

class AuthService {
  final http.Client client;

  AuthService({http.Client? client}) : client = client ?? http.Client();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      if (kDebugMode) print('Login Error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> register(RegisterData userData) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData.toJson()),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      if (kDebugMode) print('Register Error: $e');
      rethrow;
    }
  }

  AuthResponse _handleAuthResponse(http.Response response) {
    final responseData = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return AuthResponse.fromJson(responseData);
    } else {
      throw AuthException(
        message: responseData['message'] ?? 
               (response.statusCode == 400 ? 'Requête invalide' : 'Erreur serveur'),
        statusCode: response.statusCode,
        errors: responseData['errors']?.cast<String, List<String>>(),
      );
    }
  }
}

class AuthException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, List<String>>? errors;

  AuthException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  String get formattedErrors {
    if (errors == null) return message;
    return errors!.entries
      .map((e) => '${e.key}: ${e.value.join(', ')}')
      .join('\n');
  }

  @override
  String toString() => message;
}



  // ... reste du code existant









































































































/*import 'package:http/http.dart' as http;
import 'package:stage_front_end/core/models/login_response.dart';
import 'dart:convert';

import 'package:stage_front_end/core/models/register_data.dart';

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      final errorResponse = jsonDecode(response.body);
      return AuthResponse(
        success: false,
        message: errorResponse['message'] ?? 'Échec de la connexion. Veuillez vérifier vos informations.',
        token: '',
        userId: '',
        userName: '',
        email: '',
        roles: [],
      );
    }
  }

  Future<Map<String, dynamic>> register(RegisterData user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Échec de l\'inscription');
    }
  }
}
*/