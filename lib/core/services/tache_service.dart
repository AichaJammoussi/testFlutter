import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
import 'package:testfront/core/models/UserDto.dart';
import 'package:testfront/core/models/auth_storage.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/models/tache_creation_dto.dart';
import 'package:testfront/core/models/tache_dto.dart';
import 'package:testfront/core/services/api_Service.dart';
import 'package:testfront/core/services/auth_service.dart';

class TacheService {
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

  ResponseDTO<T> _handleError<T>(dynamic e) {
    debugPrint('TacheService Error: $e');
    return ResponseDTO(
      success: false,
      message: e is Exception ? e.toString() : 'Erreur inconnue',
    );
  }

  Future<ResponseDTO<List<TacheDTO>>> getAllTaches() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.taches}'),
        headers: headers,
      );

      debugPrint(
        'Réponse du backend (getAllTaches): ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        return ResponseDTO<List<TacheDTO>>.fromJson(
          decoded,
          (data) => (data as List).map((e) => TacheDTO.fromJson(e)).toList(),
        );
      }

      // Gestion des autres cas
      final decodedError = json.decode(response.body);
      return ResponseDTO<List<TacheDTO>>.fromJson(
        decodedError,
        (data) => (data as List).map((e) => TacheDTO.fromJson(e)).toList(),
      );
    } catch (e) {
      debugPrint('Erreur getAllTaches: $e');
      return ResponseDTO(success: false, message: e.toString());
    }
  }

  Future<ResponseDTO<TacheDTO>> createTache(TacheCreationDTO tacheDto) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl${ApiConfig.taches}');

      print('📤 Envoi tâche → $url');
      print(
        '📄 Corps de la requête : ${json.encode({"tacheDto": tacheDto.toJson()})}',
      );

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(tacheDto.toJson()),
      );

      print('📥 Statut HTTP: ${response.statusCode}');
      print('📥 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        return ResponseDTO<TacheDTO>.fromJson(
          json.decode(response.body),
          (data) => TacheDTO.fromJson(data),
        );
      } else {
        final decoded =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        print('❌ Erreur API tâche: ${decoded['message'] ?? 'Réponse vide'}');

        return ResponseDTO<TacheDTO>(
          success: false,
          message:
              decoded['message'] ?? 'Erreur lors de la création de la tâche',
          errors:
              decoded['errors'] != null
                  ? Map<String, String>.from(decoded['errors'])
                  : {"http": "Code HTTP ${response.statusCode}"},
          data: null,
        );
      }
    } catch (e) {
      print('💥 Exception tâche: $e');
      return ResponseDTO<TacheDTO>(
        success: false,
        message: 'Exception: ${e.toString()}',
        errors: {"exception": e.toString()},
        data: null,
      );
    }
  }

  Future<ResponseDTO<TacheDTO>> getTacheById(int tacheId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.taches}/$tacheId'),
        headers: headers,
      );

      debugPrint(
        'Réponse du backend (getTacheById): ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ResponseDTO<TacheDTO>.fromJson(
          decoded,
          (data) => TacheDTO.fromJson(data),
        );
      }

      // Gestion d’erreur si non 200
      final decodedError = json.decode(response.body);
      return ResponseDTO<TacheDTO>.fromJson(
        decodedError,
        (data) => TacheDTO.fromJson(data),
      );
    } catch (e) {
      debugPrint('Erreur getTacheById: $e');
      return ResponseDTO(success: false, message: e.toString());
    }
  }

  Future<ResponseDTO<List<TacheDTO>>> getTachesByUser(String userId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.taches}/by-user/$userId'),
        headers: headers,
      );

      debugPrint(
        'Réponse du backend (getTachesByUser): ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        return ResponseDTO<List<TacheDTO>>.fromJson(
          decoded,
          (data) => (data as List).map((e) => TacheDTO.fromJson(e)).toList(),
        );
      }

      final decodedError = json.decode(response.body);
      return ResponseDTO<List<TacheDTO>>.fromJson(
        decodedError,
        (data) => (data as List).map((e) => TacheDTO.fromJson(e)).toList(),
      );
    } catch (e) {
      debugPrint('Erreur getTachesByUser: $e');
      return ResponseDTO(success: false, message: e.toString());
    }
  }

  Future<ResponseDTO<List<TacheDTO>>> getTachesByMission(int missionId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.taches}/mission/$missionId'),
        headers: headers,
      );

      debugPrint(
        'Réponse du backend (getTachesByMission): ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        return ResponseDTO<List<TacheDTO>>.fromJson(
          decoded,
          (data) => (data as List).map((e) => TacheDTO.fromJson(e)).toList(),
        );
      }

      final decodedError = json.decode(response.body);
      return ResponseDTO<List<TacheDTO>>.fromJson(
        decodedError,
        (data) => (data as List).map((e) => TacheDTO.fromJson(e)).toList(),
      );
    } catch (e) {
      debugPrint('Erreur getTachesByMission: $e');
      return ResponseDTO(success: false, message: e.toString());
    }
  }

  Future<ResponseDTO<TacheDTO>> updateTache(
    int tacheId,
    TacheUpdateDTO tacheDto,
  ) async {
    try {
      final headers = await _getHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.put(
        Uri.parse('$_baseUrl${ApiConfig.taches}/$tacheId'),
        headers: headers,
        body: jsonEncode(tacheDto.toJson()),
      );

      debugPrint('🔁 updateTache: ${response.statusCode} - ${response.body}');

      final decoded = json.decode(response.body);
      return ResponseDTO<TacheDTO>.fromJson(
        decoded,
        (data) => TacheDTO.fromJson(data),
      );
    } catch (e) {
      debugPrint('❌ Erreur updateTache: $e');
      return ResponseDTO<TacheDTO>(success: false, message: "Erreur interne");
    }
  }

  Future<ResponseDTO<TacheDTO>> updateStatutTache(
    int tacheId,
    StatutTache newStatut,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl${ApiConfig.taches}/$tacheId/statut');

      print('🔄 Mise à jour statut tâche → $url');
      print(
        '📄 Corps de la requête : ${json.encode({'newStatut': newStatut.name})}',
      );

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(newStatut.index),
      );

      print('📥 Statut HTTP: ${response.statusCode}');
      print('📥 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return ResponseDTO<TacheDTO>.fromJson(
          decoded,
          (data) => TacheDTO.fromJson(data),
        );
      } else {
        final decoded =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        return ResponseDTO<TacheDTO>(
          success: false,
          message:
              decoded['message'] ?? 'Erreur lors de la mise à jour du statut',
          errors:
              decoded['errors'] != null
                  ? Map<String, String>.from(decoded['errors'])
                  : {"http": "Code HTTP ${response.statusCode}"},
          data: null,
        );
      }
    } catch (e, stackTrace) {
      print('💥 Exception update statut tâche: $e');
      print('📌 StackTrace: $stackTrace');

      return ResponseDTO<TacheDTO>(
        success: false,
        message: 'Exception: ${e.toString()}',
        errors: {"exception": e.toString()},
        data: null,
      );
    }
  }

  Future<ResponseDTO<bool>> deleteTache(int tacheId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$_baseUrl${ApiConfig.taches}/$tacheId'),
        headers: headers,
      );

      debugPrint(
        'Réponse du backend (deleteTache): ${response.statusCode} - ${response.body}',
      );

      final decoded = json.decode(response.body);

      return ResponseDTO<bool>.fromJson(decoded, (data) => data as bool);
    } catch (e) {
      debugPrint('Erreur deleteTache: $e');
      return ResponseDTO<bool>(
        success: false,
        message: "Erreur interne",
        data: false,
      );
    }
  }

  Future<bool> updateEmployesFromTaches(int missionId) async {
    try {
      final headers = await _getHeaders();
      if (headers.isEmpty) {
        print('❌ Headers sont vides, token probablement absent');
        return false;
      }

      final url = '$_baseUrl${ApiConfig.missions}/$missionId/update-employes';
      print('🔗 URL requête: $url');
      print('🛠 Headers: $headers');

      final response = await http.post(Uri.parse(url), headers: headers);

      print('📬 Statut HTTP: ${response.statusCode}');
      print('📦 Corps réponse: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Employés mis à jour pour la mission $missionId');
        return true;
      } else {
        print(
          '❌ Erreur API updateEmployes: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e, stacktrace) {
      print('❌ Exception updateEmployesFromTaches: $e');
      print('🧾 Stacktrace: $stacktrace');
      return false;
    }
  }

  Future<ResponseDTO<TacheDTO>> completeTache(int tacheId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse('$_baseUrl${ApiConfig.taches}/$tacheId/complete'),
        headers: headers,
      );

      debugPrint(
        'Réponse du backend (completeTache): ${response.statusCode} - ${response.body}',
      );

      final decoded = json.decode(response.body);
      return ResponseDTO<TacheDTO>.fromJson(
        decoded,
        (data) => TacheDTO.fromJson(data),
      );
    } catch (e) {
      debugPrint('Erreur completeTache: $e');
      return ResponseDTO<TacheDTO>(
        success: false,
        message: "Erreur interne",
        data: null,
      );
    }
  }

  Future<List<UserDTO>> fetchEmployesDisponibles(
    DateTime dateDebut,
    DateTime dateFin, {
    int? missionId,
  }) async {
    final queryParameters = {
      'dateDebut': dateDebut.toIso8601String(),
      'dateFin': dateFin.toIso8601String(),
    };

    if (missionId != null) {
      queryParameters['missionId'] = missionId.toString();
    }

    final uri = Uri.parse(
      '$_baseUrl${ApiConfig.taches}/employes-disponibles',
    ).replace(queryParameters: queryParameters);

    print('Requête GET vers : $uri');

    final response = await http.get(uri);

    print('Code de réponse HTTP : ${response.statusCode}');
    print('Corps de la réponse : ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      print('Réponse JSON décodée : $jsonResponse');

      if (jsonResponse['success'] == true) {
        final data = jsonResponse['data'] as List;
        print('Nombre d\'employés disponibles reçus : ${data.length}');
        return data.map((e) => UserDTO.fromJson(e)).toList();
      } else {
        print('Erreur API : ${jsonResponse['message']}');
        throw Exception('Erreur API: ${jsonResponse['message']}');
      }
    } else {
      print('Erreur HTTP : ${response.statusCode}');
      throw Exception('Erreur HTTP: ${response.statusCode}');
    }
  }

  Future<ResponseDTO<double>> fetchDepensesMission(int missionId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
        '$_baseUrl${ApiConfig.missions}/$missionId/depenses',
      );
      print('📡 [API CALL] GET $url');

      final response = await http.get(url, headers: headers);

      print('📥 [API RESPONSE] Status: ${response.statusCode}');
      print('📥 [API RESPONSE] Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Dépenses reçues : $jsonData');

        return ResponseDTO<double>(
          success: true,
          data: (jsonData is num) ? jsonData.toDouble() : null,
        );
      } else {
        print('❌ Erreur HTTP: ${response.statusCode}');
        return _handleError<double>('Code ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('🛑 Exception attrapée: $e');
      print('📌 Stack trace: $stackTrace');
      return _handleError<double>(e.toString());
    }
  }
}
