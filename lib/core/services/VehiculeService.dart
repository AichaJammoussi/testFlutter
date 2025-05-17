import 'dart:convert';
import 'dart:io';
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
      final url = Uri.parse('$_baseUrl${ApiConfig.vehicules}/$id');
      print('[GET] Récupération véhicule ID: $id | URL: $url');

      final response = await http.get(url, headers: headers);
      print('[RESPONSE] Code: ${response.statusCode} | Body: ${response.body}');

      if (response.statusCode == 200) {
        final parsedJson = json.decode(response.body);
        print('[PARSE] JSON reçu: $parsedJson');
        return ResponseDTO<VehiculeDTO>.fromJson(
          json.decode(response.body),

          (data) => VehiculeDTO.fromJson(data),
        );
      }
      

      print('[ERREUR] Statut HTTP inattendu: ${response.statusCode}');
      return _handleError('Erreur HTTP ${response.statusCode}');
    } catch (e, stacktrace) {
      print('[EXCEPTION] Erreur lors du fetch du véhicule ID: $id');
      print('Message: $e');
      print('Stacktrace: $stacktrace');
      return _handleError(e);
    }
  }

  Future<ResponseDTO<VehiculeDTO>> createVehicule(
    VehiculeCreationDTO dto,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.vehicules}'),
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
        body: jsonEncode(dto.toJson()),
      );

      final jsonRes = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ResponseDTO(success: true, message: jsonRes['message']);
      } else {
        // Ajout d'une gestion plus robuste des erreurs de l'API
        return ResponseDTO(
          success: false,
          message:
              jsonRes['message'] ??
              'Une erreur est survenue lors de la création du véhicule.',
          errors:
              jsonRes['errors'] != null
                  ? Map<String, String>.from(jsonRes['errors'])
                  : null,
        );
      }
    } on SocketException catch (_) {
      return ResponseDTO(
        success: false,
        message:
            'Impossible de se connecter au serveur. Vérifiez votre connexion Internet.',
      );
    } on FormatException catch (_) {
      return ResponseDTO(
        success: false,
        message: 'Format de réponse invalide. Veuillez réessayer plus tard.',
      );
    } catch (e) {
      return ResponseDTO(
        success: false,
        message: 'Une erreur inattendue est survenue: ${e.toString()}',
      );
    }
  }

  Future<ResponseDTO> updateVehicule(int id, VehiculeCreationDTO dto) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl${ApiConfig.vehicules}/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dto.toJson()),
      );

      final jsonRes = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ResponseDTO(success: true, message: jsonRes['message']);
      } else {
        return ResponseDTO(
          success: false,
          message: jsonRes['message'],
          errors:
              jsonRes['errors'] != null
                  ? Map<String, String>.from(jsonRes['errors'])
                  : null,
        );
      }
    } catch (e) {
      return ResponseDTO(success: false, message: "Erreur réseau : $e");
    }
  }

  // 🔹 5. Delete
  Future<ResponseDTO<bool>> deleteVehicule(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl${ApiConfig.vehicules}/$id'),
        headers: headers,
      );
      final jsonRes = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ResponseDTO(success: true, message: jsonRes['message']);
      } else {
        return ResponseDTO(
          success: false,
          message: jsonRes['message'],
          errors:
              jsonRes['errors'] != null
                  ? Map<String, String>.from(jsonRes['errors'])
                  : null,
        );
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  // 🔸 Generic error handler
  ResponseDTO<T> _handleError<T>(dynamic error) {
    return ResponseDTO<T>(success: false, message: error.toString());
  }
}
