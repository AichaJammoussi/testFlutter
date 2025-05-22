import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/DepenseCreationDTO.dart';
import 'package:testfront/core/models/Depensedto.dart';
import 'package:testfront/core/models/response.dart';
import 'package:http/http.dart' as http;
import 'package:testfront/core/services/auth_service.dart';

class DepenseService {
  final String _baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _authService.getAuthToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'accept': '*/*',
      if (kDebugMode) 'ngrok-skip-browser-warning': 'true',
    };

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  ResponseDTO<T> _handleError<T>(dynamic e) {
    debugPrint('DepenseService Error: $e');
    return ResponseDTO(
      success: false,
      message: e is Exception ? e.toString() : 'Erreur inconnue',
    );
  }

  Future<ResponseDTO<DepenseDTO>> createDepense(
    DepenseCreationDTO depenseDto,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.depenses}');
      final request = http.MultipartRequest('POST', url);

      // Headers (s'ils sont requis, comme Authorization)
      final headers = await _getHeaders(isMultipart: true);
      request.headers.addAll(headers);
      final montantFormatted = depenseDto.montant.toString().replaceAll(
        '.',
        ',',
      );

      // Champs texte
      request.fields['TypeDepense'] = depenseDto.typeDepense.index.toString();
      request.fields['Description'] = depenseDto.description;
      request.fields['Montant'] = montantFormatted;
      request.fields['MoyenPaiement'] =
          depenseDto.moyenPaiement.index.toString();
      request.fields['TacheId'] = depenseDto.tacheId.toString();

      // Fichier justificatif s’il existe
      if (depenseDto.justification != null) {
        final file = await http.MultipartFile.fromPath(
          'Justification',
          depenseDto.justification!.path,
          contentType: MediaType('image', 'png'), // adapter selon format
        );
        request.files.add(file);
      }

      debugPrint('📤 Envoi dépense → $url');
      debugPrint('📄 Champs envoyés : ${request.fields}');

      // Envoi de la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Statut HTTP: ${response.statusCode}');
      debugPrint('📥 Corps de la réponse: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ResponseDTO<DepenseDTO>.fromJson(
          json.decode(response.body),
          (data) => DepenseDTO.fromJson(data),
        );
      } else {
        final decoded =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        debugPrint(
          '❌ Erreur API dépense: ${decoded['message'] ?? 'Réponse vide'}',
        );

        return ResponseDTO<DepenseDTO>(
          success: false,
          message:
              decoded['message'] ?? 'Erreur lors de la création de la dépense',
          errors:
              decoded['errors'] != null
                  ? Map<String, String>.from(decoded['errors'])
                  : {"http": "Code HTTP ${response.statusCode}"},
          data: null,
        );
      }
    } catch (e) {
      return _handleError<DepenseDTO>(e);
    }
  }

  Future<ResponseDTO<DepenseDTO>> getDepenseById(int id) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/api/Depense/$id');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return ResponseDTO<DepenseDTO>.fromJson(
          json.decode(response.body),
          (data) => DepenseDTO.fromJson(data),
        );
      } else {
        return ResponseDTO<DepenseDTO>(
          success: false,
          message: 'Erreur lors de la récupération de la dépense',
          data: null,
        );
      }
    } catch (e) {
      return _handleError<DepenseDTO>(e);
    }
  }

  Future<ResponseDTO<List<DepenseDTO>>> getAllDepenses() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/api/Depense');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return ResponseDTO<List<DepenseDTO>>.fromJson(
          json.decode(response.body),
          (list) => (list as List).map((e) => DepenseDTO.fromJson(e)).toList(),
        );
      } else {
        return ResponseDTO<List<DepenseDTO>>(
          success: false,
          message: 'Erreur lors de la récupération des dépenses',
          data: null,
        );
      }
    } catch (e) {
      return _handleError<List<DepenseDTO>>(e);
    }
  }

  Future<ResponseDTO<DepenseDTO>> updateDepense(
    int id,
    DepenseCreationDTO depenseDto,
  ) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.depenses}/$id');
      final request = http.MultipartRequest('PUT', url);

      // Headers (ajuster si besoin)
      final headers = await _getHeaders(isMultipart: true);
      request.headers.addAll(headers);

      // Formater montant en string avec virgule
      final montantFormatted = depenseDto.montant.toString().replaceAll(
        '.',
        ',',
      );

      // Champs texte à envoyer
      request.fields['TypeDepense'] = depenseDto.typeDepense.index.toString();
      request.fields['Description'] = depenseDto.description;
      request.fields['Montant'] = montantFormatted;
      request.fields['MoyenPaiement'] =
          depenseDto.moyenPaiement.index.toString();
      request.fields['TacheId'] = depenseDto.tacheId.toString();

      // Ajouter fichier justificatif si fourni
      if (depenseDto.justification != null) {
        final file = await http.MultipartFile.fromPath(
          'Justification',
          depenseDto.justification!.path,
          contentType: MediaType('image', 'png'), // adapte selon le format réel
        );
        request.files.add(file);
      }

      debugPrint('📤 Envoi mise à jour dépense → $url');
      debugPrint('📄 Champs envoyés : ${request.fields}');

      // Envoi de la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Statut HTTP: ${response.statusCode}');
      debugPrint('📥 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        return ResponseDTO<DepenseDTO>.fromJson(
          json.decode(response.body),
          (data) => DepenseDTO.fromJson(data),
        );
      } else {
        final decoded =
            response.body.isNotEmpty ? json.decode(response.body) : {};
        debugPrint(
          '❌ Erreur API mise à jour dépense: ${decoded['message'] ?? 'Réponse vide'}',
        );

        return ResponseDTO<DepenseDTO>(
          success: false,
          message:
              decoded['message'] ??
              'Erreur lors de la mise à jour de la dépense',
          errors:
              decoded['errors'] != null
                  ? Map<String, String>.from(decoded['errors'])
                  : {"http": "Code HTTP ${response.statusCode}"},
          data: null,
        );
      }
    } catch (e) {
      return _handleError<DepenseDTO>(e);
    }
  }

  Future<ResponseDTO<bool>> deleteDepense(int id) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/api/Depense/$id');

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return ResponseDTO<bool>(
          success: true,
          message: 'Dépense supprimée avec succès',
          data: true,
        );
      } else {
        return ResponseDTO<bool>(
          success: false,
          message: 'Erreur lors de la suppression de la dépense',
          data: false,
        );
      }
    } catch (e) {
      return _handleError<bool>(e);
    }
  }

  Future<ResponseDTO<List<DepenseDTO>>> getDepensesByTacheId(
    int tacheId,
  ) async {
    final headers = await _getHeaders();

    try {
      final url = Uri.parse('$_baseUrl/api/Depense/tache/$tacheId');

      print('GET Request URL: $url');
      print('Request Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        return ResponseDTO<List<DepenseDTO>>.fromJson(
          jsonResponse,
          (data) =>
              (data as List).map((item) => DepenseDTO.fromJson(item)).toList(),
        );
      } else {
        print('Erreur serveur: ${response.statusCode}');
        return ResponseDTO<List<DepenseDTO>>(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
          data: null,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Erreur HTTP: $e');
      return ResponseDTO<List<DepenseDTO>>(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }
}
