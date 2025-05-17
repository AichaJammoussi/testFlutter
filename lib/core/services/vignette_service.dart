import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:testfront/core/models/VignetteCreationDto.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/models/vignette_dto.dart';
import 'package:path/path.dart';

import '../config/api_config.dart';

import 'auth_service.dart';

class VignetteService {
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

  ResponseDTO<T> _handleError<T>(dynamic error) {
    return ResponseDTO<T>(success: false, message: error.toString());
  }

  /// 🔹 1. Créer une vignette
  Future<ResponseDTO<VignetteDto>> createVignette(
    VignetteCreationDto dto,
  ) async {
    final url = Uri.parse('$_baseUrl${ApiConfig.vignettes}');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(dto.toJson());

    print('➡️ Envoi de la requête POST vers $url');
    print('📝 Corps de la requête : $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('✅ Réponse HTTP reçue. Statut : ${response.statusCode}');
      print('📦 Contenu brut : ${response.body}');

      final jsonRes = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✔️ Vignette créée avec succès : ${jsonRes['message']}');
        return ResponseDTO(success: true, message: jsonRes['message']);
      } else {
        print('❌ Échec de la création. Message : ${jsonRes['message']}');
        print('❗ Erreurs de validation : ${jsonRes['errors']}');

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
    } catch (e) {
      print('🚨 Exception lors de la requête : $e');
      throw Exception('Erreur réseau ou serveur : ${e.toString()}');
    }
  }

  /// 🔹 2. Obtenir une vignette par ID
  Future<ResponseDTO<VignetteDto>> getVignetteById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.vignettes}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<VignetteDto>.fromJson(
          json.decode(response.body),
          (data) => VignetteDto.fromJson(data),
        );
      }

      return _handleError("Erreur HTTP : ${response.statusCode}");
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 🔹 3. Obtenir toutes les vignettes
  Future<ResponseDTO<List<VignetteDto>>> getAllVignettes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.vignettes}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<List<VignetteDto>>.fromJson(
          json.decode(response.body),
          (data) =>
              List<VignetteDto>.from(data.map((x) => VignetteDto.fromJson(x))),
        );
      }

      return _handleError("Erreur HTTP : ${response.statusCode}");
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 🔹 4. Obtenir les vignettes d'un véhicule
  Future<ResponseDTO<List<VignetteDto>>> getVignettesByVehiculeId(
    int vehiculeId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConfig.vignettes}/vehicule/$vehiculeId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<List<VignetteDto>>.fromJson(
          json.decode(response.body),
          (data) =>
              List<VignetteDto>.from(data.map((x) => VignetteDto.fromJson(x))),
        );
      }

      return _handleError("Erreur HTTP : ${response.statusCode}");
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 🔹 5. Supprimer une vignette
  Future<ResponseDTO<bool>> deleteVignette(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl${ApiConfig.vignettes}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<bool>.fromJson(
          json.decode(response.body),
          (data) => data as bool,
        );
      }

      return _handleError("Erreur HTTP : ${response.statusCode}");
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 🔹 1. Vérifier si le véhicule doit payer la vignette
  Future<ResponseDTO<bool>> doitPayerVignette(int vehiculeId, int annee) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/vignette/doit-payer/$vehiculeId/$annee'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ResponseDTO<bool>.fromJson(
          json.decode(response.body),
          (data) => data,
        );
      }

      return _handleError("Erreur HTTP : ${response.statusCode}");
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 🔹 2. Récupérer la date limite de paiement de la vignette
  Future<ResponseDTO<DateTime>> getDateLimitePaiement(
    int vehiculeId,
    int annee,
  ) async {
    try {
      print("🔄 DÉBUT de getDateLimitePaiement");
      print("📦 Paramètres reçus: vehiculeId=$vehiculeId, annee=$annee");

      final headers = await _getHeaders();
      print("📨 Headers préparés: $headers");

      final url =
          '$_baseUrl${ApiConfig.vignettes}/date-limite-paiement/$vehiculeId/$annee';
      print("🌐 URL appelée: $url");

      final response = await http.get(Uri.parse(url), headers: headers);

      print("📥 Status HTTP reçu: ${response.statusCode}");
      print("📥 Corps de réponse: ${response.body}");

      if (response.statusCode == 200) {
        final result = ResponseDTO<DateTime>.fromJson(
          json.decode(response.body),
          (data) => DateTime.parse(data),
        );
        print("✅ Résultat parsé: ${result.data}");
        return result;
      }

      print("⚠️ Erreur HTTP : ${response.statusCode}");
      return _handleError("Erreur HTTP : ${response.statusCode}");
    } catch (e) {
      print("❌ Exception attrapée: $e");
      return _handleError(e);
    }
  }
}
