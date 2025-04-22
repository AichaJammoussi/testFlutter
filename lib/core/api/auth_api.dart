import 'dart:convert';
import 'package:stage_front_end/core/models/login_response.dart';

import 'api_client.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  Future<AuthResponseDTO> login(String email, String password) async {
    final response = await _apiClient.post(
      'auth/login',
      {'email': email, 'password': password},
      requiresAuth: false,
    );

    final jsonData = jsonDecode(response.body);
    return AuthResponseDTO.fromJson(jsonData);
  }

  Future<AuthResponseDTO> register(String email, String password, String confirmPassword, 
      String nom, String prenom, String phoneNumber) async {
    final response = await _apiClient.post(
      'auth/register',
      {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'nom': nom,
        'prenom': prenom,
        'phoneNumber': phoneNumber
      },
      requiresAuth: false,
    );

    final jsonData = jsonDecode(response.body);
    return AuthResponseDTO.fromJson(jsonData);
  }
}