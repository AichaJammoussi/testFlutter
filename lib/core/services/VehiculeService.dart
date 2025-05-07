import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:testfront/core/models/VehiculeCreationDTO.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/models/response.dart';

import '../config/api_config.dart';

import 'auth_service.dart';

class VehiculeService {
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

  // 🔹 1. Get all vehicles
  Future<ResponseDTO<List<VehiculeDTO>>> fetchVehicules() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.vehicules}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<List<VehiculeDTO>>.fromJson(
          json.decode(response.body),
          (data) =>
              List<VehiculeDTO>.from(data.map((x) => VehiculeDTO.fromJson(x))),
        );
      }

      // Gestion explicite des autres codes de réponse HTTP
      String errorMessage;
      switch (response.statusCode) {
        case 400:
          errorMessage = "Requête invalide. Vérifiez les paramètres.";
          break;
        case 401:
          errorMessage = "Non autorisé. Veuillez vous reconnecter.";
          break;
        case 403:
          errorMessage =
              "Accès refusé. Vous n'avez pas les droits nécessaires.";
          break;
        case 404:
          errorMessage = "Ressource non trouvée.";
          break;
        case 500:
          errorMessage = "Erreur interne du serveur. Réessayez plus tard.";
          break;
        default:
          errorMessage = "Erreur inconnue : ${response.statusCode}";
          break;
      }

      return _handleError(errorMessage);
    } catch (e) {
      return _handleError("Erreur réseau ou de décodage : ${e.toString()}");
    }
  }

  // 🔹 2. Get by ID
  Future<ResponseDTO<VehiculeDTO>> getVehiculeById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.vehicules}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<VehiculeDTO>.fromJson(
          json.decode(response.body),
          (data) => VehiculeDTO.fromJson(data),
        );
      }

      return _handleError('Erreur ${response.statusCode}');
    } catch (e) {
      return _handleError(e);
    }
  }

  // 🔹 3. Create
  Future<ResponseDTO<VehiculeDTO>> createVehicule(
    VehiculeCreationDTO dto,
  ) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode(dto.toJson());

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.vehicules}'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<VehiculeDTO>.fromJson(
          json.decode(response.body),
          (data) => VehiculeDTO.fromJson(data),
        );
      } else if (response.statusCode == 400) {
        return _handleError('Requête invalide : ${response.body}');
      } else if (response.statusCode == 404) {
        return _handleError('Ressource non trouvée : ${response.body}');
      } else if (response.statusCode == 500) {
        return _handleError('Erreur serveur : ${response.body}');
      }

      return _handleError(
        'Erreur inattendue (${response.statusCode}) : ${response.body}',
      );
    } catch (e) {
      return _handleError('Exception levée : ${e.toString()}');
    }
  }

  // 🔹 4. Update
/*  Future<ResponseDTO<VehiculeDTO>> updateVehicule(VehiculeDTO dto) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({"dto": dto.toJson()});

      final response = await http.put(
        Uri.parse('$_baseUrl${ApiConfig.vehicules}/${dto.vehiculeId}'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<VehiculeDTO>.fromJson(
          json.decode(response.body),
          (data) => VehiculeDTO.fromJson(data),
        );
      }

      return _handleError('Erreur ${response.statusCode}');
    } catch (e) {
      return _handleError(e);
    }
  }*/

  // 🔹 5. Delete
  Future<ResponseDTO<bool>> deleteVehicule(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl${ApiConfig.vehicules}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<bool>.fromJson(
          json.decode(response.body),
          (data) => data as bool,
        );
      }

      return _handleError('Erreur ${response.statusCode}');
    } catch (e) {
      return _handleError(e);
    }
  }

  // 🔸 Generic error handler
  ResponseDTO<T> _handleError<T>(dynamic error) {
    return ResponseDTO<T>(success: false, message: error.toString());
  }
}
