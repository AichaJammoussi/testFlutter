import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  // Configuration multi-plateforme
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://localhost:7261'; // Web
    } else {
      return 'https://e360-197-2-87-2.ngrok-free.app'; // Mobile (émulateur)
    }
  }

  String adaptImageUrl(String url) {
    if (kIsWeb) {
      return url; // Web peut utiliser localhost directement
    }

    if (Platform.isAndroid) {
      // Pour l'émulateur Android, on remplace localhost par 10.0.2.2
      return url.replaceAll("localhost", "10.0.2.2");
    }
    if (Platform.isIOS) {
      // Pour iOS, si besoin d'un comportement spécifique (éventuellement utiliser un tunnel ngrok ou autre)
      return url.replaceAll(
        "localhost",
        "127.0.0.1",
      ); // Exemples pour iOS, à personnaliser selon besoin
    }

    // Autres plateformes ( mobile réel, etc.)
    return url;
  }

  // Endpoints
  static const String login = '/api/Auth/login';
  static const String register = '/api/Auth/register';
  static const String userProfil = '/api/Auth/profil';
  static const String role = '/api/Role';

  static const String vehicules = '/api/Vehicule';
  static const String vignettes = '/api/Vignette';
  static const String missions = '/api/Mission';
  static const String notifications = '/api/Notifications';
  static const String taches = '/api/Taches';
  static const String depenses = '/api/Depense';
  static const String remboursements = '/api/Remboursements';
}
