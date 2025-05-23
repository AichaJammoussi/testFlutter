import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/MissionRapportDto.dart';
import 'package:testfront/core/services/auth_service.dart';

class RapportService {
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

  /// 🔄 Génère le rapport pour une mission
  Future<MissionRapportDto?> genererRapport(int missionId) async {
    try {
      print(
        '🔄 Début de la génération du rapport pour la mission ID: $missionId',
      );

      final headers = await _getHeaders();
      print('📬 Headers obtenus: $headers');

      final url = Uri.parse('$_baseUrl/api/RapportMission/generer/$missionId');
      print('🌐 URL d\'appel: $url');

      final response = await http.get(url, headers: headers);
      print('📥 Code réponse HTTP: ${response.statusCode}');
      print('📦 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        final rapport = MissionRapportDto.fromJson(jsonMap);
        print('✅ Rapport généré avec succès: ${rapport.missionId}');
        return rapport;
      } else {
        print(
          '❌ Erreur HTTP: ${response.statusCode} - ${response.reasonPhrase}',
        );
        throw Exception('Erreur lors du chargement du rapport');
      }
    } catch (e) {
      print('🛑 Exception attrapée dans genererRapport: $e');
      rethrow;
    }
  }

  /// ✅ L'employé valide le rapport
  Future<bool> validerParEmploye(int missionId) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl/api/RapportMission/valider-employe/$missionId');

    print('📤 Envoi de validation du rapport pour la mission $missionId');

    final response = await http.post(url, headers: headers);

    print('📥 Statut de réponse pour validation: ${response.statusCode}');
    print('📥 Corps de la réponse: ${response.body}');

    return response.statusCode == 200;
  }

  /// ❓ Vérifie si tous les employés ont validé
  Future<bool> tousOntValide(int missionId) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl/tous-employes-valides/$missionId');

    print(
      '🔍 Vérification si tous les employés ont validé pour la mission $missionId',
    );

    final response = await http.get(url, headers: headers);

    print('📥 Statut de réponse: ${response.statusCode}');
    print('📥 Corps de la réponse: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Résultat: ${data['tousValides']}');
      return data['tousValides'] == true;
    } else {
      print("❌ Erreur de vérification des validations.");
      return false;
    }
  }

  /// 🛡️ Admin valide ou rejette
  Future<bool> validerParAdmin(int missionId, bool accepte) async {
    final headers = await _getHeaders();

    final url = Uri.parse(
      '$_baseUrl/valider-par-admin/$missionId?accepte=$accepte',
    );
    final response = await http.post(url, headers: await headers);

    return response.statusCode == 200;
  }
}
