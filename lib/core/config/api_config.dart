import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configuration multi-plateforme
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://localhost:7261'; // Web
    } else {
      return 'https://45ed-102-158-13-36.ngrok-free.app'; // Mobile (émulateur)
    }
  }

  // Endpoints
  static const String login = '/api/Auth/login';
  static const String register = '/api/Auth/register';
  static const String userProfil = '/api/Auth/profil';
  static const String role = '/api/Role';

  static const String vehicules = '/api/Vehicule';
}
