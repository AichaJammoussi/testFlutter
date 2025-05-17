import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:testfront/core/config/api_config.dart';
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

    debugPrint('Réponse du backend (getAllTaches): ${response.statusCode} - ${response.body}');

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

    final body = jsonEncode({
      'titre': tacheDto.titre,
      'description': tacheDto.description,
      'priorite': tacheDto.priorite,
      'userId': tacheDto.userId,
      'idMission': tacheDto.missionId,
    });

    debugPrint('Envoi au backend (tâche): $body');

    final response = await http.post(
      Uri.parse('$_baseUrl${ApiConfig.taches}'), // Assurez-vous que le bon endpoint est utilisé
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint(
      'Réponse du backend (tâche): ${response.statusCode} - ${response.body}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      return ResponseDTO<TacheDTO>.fromJson(
        decoded,
        (data) => TacheDTO.fromJson(data),
      );
    }

    final decodedError = json.decode(response.body);
    return ResponseDTO<TacheDTO>.fromJson(
      decodedError,
      (data) => TacheDTO.fromJson(data),
    );
  } catch (e) {
    debugPrint('Erreur createTache: $e');
    return ResponseDTO(success: false, message: e.toString());
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
        'Réponse du backend (getTacheById): ${response.statusCode} - ${response.body}');

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

    debugPrint('Réponse du backend (getTachesByUser): ${response.statusCode} - ${response.body}');

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

    debugPrint('Réponse du backend (getTachesByMission): ${response.statusCode} - ${response.body}');

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

Future<ResponseDTO<TacheDTO>> updateTache(int tacheId, TacheUpdateDTO tacheDto) async {
  try {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await http.put(
      Uri.parse('$_baseUrl${ApiConfig.taches}/$tacheId'),
      headers: headers,
      body: jsonEncode(tacheDto.toJson()),
    );

    debugPrint('Réponse du backend (updateTache): ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      return ResponseDTO<TacheDTO>.fromJson(
        decoded,
        (data) => TacheDTO.fromJson(data),
      );
    }

    final decodedError = json.decode(response.body);
    return ResponseDTO<TacheDTO>.fromJson(
      decodedError,
      (data) => TacheDTO.fromJson(data),
    );
  } catch (e) {
    debugPrint('Erreur updateTache: $e');
    return ResponseDTO<TacheDTO>(
      success: false,
      message: "Erreur interne",
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

    debugPrint('Réponse du backend (deleteTache): ${response.statusCode} - ${response.body}');

    final decoded = json.decode(response.body);

    return ResponseDTO<bool>.fromJson(
      decoded,
      (data) => data as bool,
    );
  } catch (e) {
    debugPrint('Erreur deleteTache: $e');
    return ResponseDTO<bool>(
      success: false,
      message: "Erreur interne",
      data: false,
    );
  }
}
Future<ResponseDTO<TacheDTO>> updateStatutTache(int tacheId, String newStatut) async {
  try {
    final headers = await _getHeaders();
    final body = json.encode({'statut': newStatut});

    final response = await http.put(
      Uri.parse('$_baseUrl${ApiConfig.taches}/$tacheId/statut'),
      headers: headers,
      body: body,
    );

    debugPrint('Réponse du backend (updateStatutTache): ${response.statusCode} - ${response.body}');

    final decoded = json.decode(response.body);
    return ResponseDTO<TacheDTO>.fromJson(
      decoded,
      (data) => TacheDTO.fromJson(data),
    );
  } catch (e) {
    debugPrint('Erreur updateStatutTache: $e');
    return ResponseDTO<TacheDTO>(
      success: false,
      message: "Erreur interne",
      data: null,
    );
  }
}
Future<ResponseDTO<TacheDTO>> completeTache(int tacheId) async {
  try {
    final headers = await _getHeaders();

    final response = await http.put(
      Uri.parse('$_baseUrl${ApiConfig.taches}/$tacheId/complete'),
      headers: headers,
    );

    debugPrint('Réponse du backend (completeTache): ${response.statusCode} - ${response.body}');

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
Future<ResponseDTO<List<UserDTO>>> getEmployesDisponibles({
  required DateTime dateDebut,
  required DateTime dateFin,
}) async {
  final uri = Uri.parse('https://localhost:8080/api/Taches/employes-disponibles')
      .replace(queryParameters: {
    'dateDebut': dateDebut.toIso8601String(),
    'dateFin': dateFin.toIso8601String(),
  });

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);

      return ResponseDTO<List<UserDTO>>.fromJson(
        jsonBody,
        (data) => (data as List)
            .map((item) => UserDTO.fromJson(item))
            .toList(),
      );
    } else {
      return ResponseDTO<List<UserDTO>>(
        success: false,
        message: "Erreur serveur : ${response.statusCode}",
      );
    }
  } catch (e) {
    return ResponseDTO<List<UserDTO>>(
      success: false,
      message: "Erreur de connexion ou exception : $e",
    );
  }
}



}

