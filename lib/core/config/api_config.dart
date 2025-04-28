import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configuration multi-plateforme
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://localhost:7261'; // Web
    } else {
      return 'https://b4a1-102-159-41-181.ngrok-free.app'; // Mobile (émulateur)
    }
  }

  // Endpoints
  static const String login = '/api/Auth/login';
  static const String register = '/api/Auth/register';
}
