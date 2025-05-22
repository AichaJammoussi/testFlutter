import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/RemboursementDTO.dart';
import 'package:testfront/core/models/StatutRemboursement.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/services/auth_service.dart';

class RemboursementService {
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

  Future<ResponseDTO<RemboursementDTO>> creerOuMettreAJourDemande(
    int missionId,
  ) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$_baseUrl/api/Remboursements/demande/$missionId');

    try {
      final response = await http.post(url, headers: headers);
      debugPrint('📤 POST: $url');
      debugPrint('📥 Status Code: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ResponseDTO<RemboursementDTO>.fromJson(
          data,
          (json) => RemboursementDTO.fromJson(json),
        );
      } else {
        return ResponseDTO<RemboursementDTO>(
          success: false,
          message: data['message'] ?? 'Erreur serveur',
          errors: data['errors'],
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur API: $e');
      return ResponseDTO<RemboursementDTO>(
        success: false,
        message: 'Erreur de connexion : $e',
      );
    }
  }

  Future<bool> changerStatutRemboursement(
    int id,
    StatutRemboursement statut,
  ) async {
    final headers = await _getHeaders();

    // Envoyer l'index (int) de l'enum, pas une string
    final body = jsonEncode(statut.index);
    print(
      "🔄 Envoi du statut indexé : ${statut.index} pour remboursement ID: $id",
    );

    final response = await http.put(
      Uri.parse('$_baseUrl${ApiConfig.remboursements}/$id/statut'),
      headers: headers,
      body: body,
    );

    print(
      "📤 Requête PUT vers ${Uri.parse('$_baseUrl${ApiConfig.remboursements}/$id/statut')}",
    );
    print("📦 Corps envoyé : $body");
    print("📨 Code réponse : ${response.statusCode}");
    print("📨 Réponse : ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Échec de la mise à jour du statut');
    }
  }

  Future<ResponseDTO<List<RemboursementDTO>>> getMesRemboursements() async {
    final headers = await _getHeaders();

    final url = Uri.parse('$_baseUrl${ApiConfig.remboursements}/employe');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      List<dynamic> dataList = jsonBody['data'] ?? [];
      List<RemboursementDTO> remboursements =
          dataList.map((e) => RemboursementDTO.fromJson(e)).toList();

      return ResponseDTO<List<RemboursementDTO>>(
        success: jsonBody['success'],
        message: jsonBody['message'],
        data: remboursements,
        errors: jsonBody['errors'],
      );
    } else {
      return ResponseDTO<List<RemboursementDTO>>(
        success: false,
        message: 'Erreur HTTP: ${response.statusCode}',
        data: null,
        errors: null,
      );
    }
  }

  Future<List<RemboursementDTO>> getTousLesRemboursements() async {
    final headers = await _getHeaders();

    final url = Uri.parse('$_baseUrl${ApiConfig.remboursements}');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResult = json.decode(response.body);

      if (jsonResult['success'] == true && jsonResult['data'] != null) {
        final List<dynamic> data = jsonResult['data'];
        return data.map((item) => RemboursementDTO.fromJson(item)).toList();
      } else {
        throw Exception('Erreur de récupération : ${jsonResult['message']}');
      }
    } else {
      throw Exception('Erreur serveur : ${response.statusCode}');
    }
  }
}
