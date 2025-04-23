import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configuration multi-plateforme
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://localhost:7261'; // Web
    } else {
      return 'https://10.0.2.2:7261'; // Mobile (émulateur)
    }
  }

  // Endpoints
  static const String login = '/api/Auth/login';
  static const String register = '/api/Auth/register';
}
