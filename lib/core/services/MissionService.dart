import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/MissionCreationDTO.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/models/UserDTO.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/models/VehiculeMissionDTO.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/services/auth_service.dart';

class MissionService {
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

  Future<ResponseDTO<List<MissionDTO>>> fetchMissions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.missions}'),
        headers: headers,
      );

      print('✅ Statut HTTP: ${response.statusCode}');
      print('📦 Réponse brute: ${response.body}');

      if (response.statusCode == 200) {
        return ResponseDTO<List<MissionDTO>>.fromJson(
          json.decode(response.body),
          (data) =>
              List<MissionDTO>.from(data.map((x) => MissionDTO.fromJson(x))),
        );
      }

      return _handleError('Code ${response.statusCode}');
    } catch (e) {
      return _handleError(e);
    }
  }

  ResponseDTO<T> _handleError<T>(dynamic error) {
    return ResponseDTO<T>(success: false, message: error.toString());
  }

  // ✅ GET Mission by ID
  Future<ResponseDTO<MissionDTO>> fetchMissionById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.missions}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<MissionDTO>.fromJson(
          json.decode(response.body),
          (data) => MissionDTO.fromJson(data),
        );
      }
      return _handleError('Code ${response.statusCode}');
    } catch (e) {
      return _handleError(e.toString());
    }
  }

  // ✅ POST Create Mission
  Future<ResponseDTO<MissionDTO>> createMission(
    MissionCreationDTO missionDto,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl${ApiConfig.missions}');

      print('📤 Envoi mission → $url');
      print('📄 Corps de la requête : ${json.encode(missionDto.toJson())}');

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(missionDto.toJson()),
      );

      print('📥 Statut HTTP: ${response.statusCode}');
      print('📥 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        return ResponseDTO<MissionDTO>.fromJson(
          json.decode(response.body),
          (data) => MissionDTO.fromJson(data),
        );
      } else {
        final decoded =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        print('❌ Erreur API mission: ${decoded['message'] ?? 'Réponse vide'}');

        return ResponseDTO<MissionDTO>(
          success: false,
          message:
              decoded['message'] ?? 'Erreur lors de la création de la mission',
          errors:
              decoded['errors'] != null
                  ? Map<String, String>.from(decoded['errors'])
                  : {"http": "Code HTTP ${response.statusCode}"},
          data: null,
        );
      }
    } catch (e) {
      print('💥 Exception mission: $e');
      return ResponseDTO<MissionDTO>(
        success: false,
        message: 'Exception: ${e.toString()}',
        errors: {"exception": e.toString()},
        data: null,
      );
    }
  }

  Future<ResponseDTO<List<UserDTO>>> fetchEmployesDisponibles(
    DateTime dateDebut,
    DateTime dateFin,
  ) async {
    final String url =
        '$_baseUrl${ApiConfig.missions}/disponibles?dateDebut=${dateDebut.toIso8601String()}&dateFin=${dateFin.toIso8601String()}';

    try {
      final headers = await _getHeaders(); // ✅ ajoute les headers ici
      print('🔍 Requête employé disponible → $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ); // ✅ headers ajoutés

      print('📥 Statut HTTP: ${response.statusCode}');
      print('📥 Corps: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List data = decoded['data'];
        return ResponseDTO<List<UserDTO>>(
          success: true,
          message: decoded['message'] ?? 'Employés récupérés avec succès',
          data: data.map((e) => UserDTO.fromJson(e)).toList(),
        );
      } else {
        final decoded =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        print('❌ Erreur API employés: ${decoded['message'] ?? 'Réponse vide'}');
        return ResponseDTO<List<UserDTO>>(
          success: false,
          message:
              decoded['message'] ??
              'Erreur lors de la récupération des employés',
          errors:
              decoded['errors'] != null
                  ? Map<String, String>.from(decoded['errors'])
                  : {"http": "Code HTTP ${response.statusCode}"},
          data: [],
        );
      }
    } catch (e) {
      print('💥 Exception employé: $e');
      return ResponseDTO<List<UserDTO>>(
        success: false,
        message: 'Erreur réseau/serveur : ${e.toString()}',
        errors: {"exception": e.toString()},
        data: [],
      );
    }
  }

  Future<ResponseDTO<List<VehiculeMissionDTO>>> fetchVehiculesDisponibles(
    DateTime dateDebut,
    DateTime dateFin,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl${ApiConfig.missions}/vehicules-disponibles?dateDebut=${dateDebut.toIso8601String()}&dateFin=${dateFin.toIso8601String()}',
    );

    try {
      final headers = await _getHeaders(); // ✅ Ajoute le token
      print('🚗 Requête véhicules disponibles → $uri');

      final response = await http.get(
        uri,
        headers: headers,
      ); // ✅ headers ajoutés

      print('📥 Statut HTTP: ${response.statusCode}');
      print('📥 Corps: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);
        return ResponseDTO<List<VehiculeMissionDTO>>(
          success: jsonResult['success'],
          message: jsonResult['message'] ?? 'Véhicules récupérés avec succès',
          data:
              (jsonResult['data'] as List)
                  .map((e) => VehiculeMissionDTO.fromJson(e))
                  .toList(),
        );
      } else {
        final decoded =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        print(
          '❌ Erreur API véhicules: ${decoded['message'] ?? 'Réponse vide'}',
        );
        return ResponseDTO<List<VehiculeMissionDTO>>(
          success: false,
          message:
              decoded['message'] ??
              'Erreur lors de la récupération des véhicules',
          errors:
              decoded['errors'] != null
                  ? Map<String, String>.from(decoded['errors'])
                  : {"http": "Code HTTP ${response.statusCode}"},
          data: [],
        );
      }
    } catch (e) {
      print('💥 Exception véhicules: $e');
      return ResponseDTO<List<VehiculeMissionDTO>>(
        success: false,
        message: 'Erreur réseau/serveur : ${e.toString()}',
        errors: {"exception": e.toString()},
        data: [],
      );
    }
  }

  Future<ResponseDTO<bool>> deleteMission(int id) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$_baseUrl${ApiConfig.missions}/$id');

      print('🗑️ Suppression de mission → $uri');

      final response = await http.delete(uri, headers: headers);

      print('📥 Statut HTTP: ${response.statusCode}');
      print('📥 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ResponseDTO<bool>(
          success: decoded['success'],
          message: decoded['message'],
          data: decoded['data'],
          errors:
              decoded['errors'] != null
                  ? Map<String, String>.from(decoded['errors'])
                  : null,
        );
      } else {
        final decoded = json.decode(response.body);
        return ResponseDTO<bool>(
          success: false,
          message: decoded['message'] ?? 'Erreur serveur.',
          errors:
              decoded['errors'] != null
                  ? Map<String, String>.from(decoded['errors'])
                  : {"http": "Code ${response.statusCode}"},
          data: false,
        );
      }
    } catch (e) {
      print('💥 Exception suppression mission: $e');
      return ResponseDTO<bool>(
        success: false,
        message: 'Exception: ${e.toString()}',
        errors: {"exception": e.toString()},
        data: false,
      );
    }
  }

  Future<ResponseDTO<MissionDTO>> updateMission(
    int id,
    MissionCreationDTO missionDto,
  ) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$_baseUrl${ApiConfig.missions}/$id');

      print('🔄 Mise à jour de la mission → $uri');
      print('📤 Données envoyées : ${json.encode(missionDto.toJson())}');

      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(missionDto.toJson()),
      );

      print('📥 Statut HTTP: ${response.statusCode}');
      print('📥 Corps réponse: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ResponseDTO<MissionDTO>.fromJson(
          decoded,
          (data) => MissionDTO.fromJson(data),
        );
      } else {
        final decoded = json.decode(response.body);
        return ResponseDTO<MissionDTO>(
          success: false,
          message: decoded['message'] ?? 'Erreur inconnue',
          errors:
              decoded['errors'] != null
                  ? Map<String, String>.from(decoded['errors'])
                  : {},
          data: null,
        );
      }
    } catch (e) {
      print('💥 Exception updateMission: $e');
      return ResponseDTO<MissionDTO>(
        success: false,
        message: 'Erreur lors de la mise à jour : ${e.toString()}',
        errors: {"exception": e.toString()},
        data: null,
      );
    }
  }

 
}
