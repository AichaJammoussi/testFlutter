import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as _client;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:testfront/core/models/change_email.dart';
import 'package:testfront/core/models/change_password.dart';
import 'package:testfront/core/models/confirmEmail_change.dart';
import 'package:testfront/core/models/profile_model.dart';
import 'package:testfront/core/models/reset_ppassword.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/models/update_profile_dto.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ProfileService {
  final AuthService _authService = AuthService();
  final String _baseUrl = ApiConfig.baseUrl;

  // Headers communs
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAuthToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'accept': '*/*',
      if (kDebugMode) 'ngrok-skip-browser-warning': 'true',
    };
  }

  // 1. Obtenir le profil utilisateur
  Future<ResponseDTO<UserProfileDTO>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/Profile/GetProfile'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return ResponseDTO<UserProfileDTO>.fromJson(
          json.decode(response.body),
          (data) => UserProfileDTO.fromJson(data),
        );
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseDTO(success: false, message: 'Erreur de connexion: $e');
    }
  }

  // 2. Mettre à jour le profil
  Future<ResponseDTO> updateProfile(UpdateProfileDto model) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/Profile/UpdateProfile'),
        headers: await _getHeaders(),
        body: json.encode(model.toJson()),
      );

      if (response.statusCode == 200) {
        return ResponseDTO.fromJson(json.decode(response.body), (data) => data);
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseDTO(success: false, message: 'Erreur de connexion: $e');
    }
  }

  // 3. Changer le mot de passe
  Future<ResponseDTO> changePassword(ChangePasswordDTO model) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/Profile/ChangePassword'),
        headers: await _getHeaders(),
        body: json.encode(model.toJson()),
      );

      if (response.statusCode == 200) {
        return ResponseDTO.fromJson(json.decode(response.body), (data) => data);
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseDTO(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /*// 4. Mettre à jour la photo de profil
  Future<ResponseDTO<String>> updateProfilePicture(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/Profile/UpdateProfilePicture'),
      );

      // Ajout des headers
      request.headers.addAll(await _getHeaders());
      
      // Ajout du fichier
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return ResponseDTO<String>.fromJson(
          json.decode(responseBody),
          (data) => data.toString(),
        );
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseDTO(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }*/
  Future<bool> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final uri = Uri.parse('$_baseUrl/profile/$userId/profile-picture');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        final respStr = await response.stream.bytesToString();
        print('Erreur serveur : ${response.statusCode} - $respStr');
        return false;
      }
    } on SocketException catch (_) {
      print("Erreur : Pas de connexion internet.");
      return false;
    } on HttpException catch (e) {
      print("Erreur HTTP : ${e.message}");
      return false;
    } on FormatException catch (e) {
      print("Erreur de format : ${e.message}");
      return false;
    } catch (e) {
      print("Erreur inconnue : $e");
      return false;
    }
  }

  /*
  // 5. Mot de passe oublié
  Future<ResponseDTO> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/Profile/ForgotPassword'),
        headers: await _getHeaders(),
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return ResponseDTO.fromJson(json.decode(response.body), (data) => data);
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseDTO(success: false, message: 'Erreur de connexion: $e');
    }
  }

  // 6. Réinitialiser le mot de passe
  Future<ResponseDTO> resetPassword(ResetPasswordDTO model) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/Profile/ResetPassword'),
        headers: await _getHeaders(),
        body: json.encode(model.toJson()),
      );

      if (response.statusCode == 200) {
        return ResponseDTO.fromJson(json.decode(response.body), (data) => data);
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseDTO(success: false, message: 'Erreur de connexion: $e');
    }
  }
*/
  // 7. Demande de changement d'email
  Future<ResponseDTO> requestEmailChange(ChangeEmailRequestDTO model) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/Profile/RequestEmailChange'),
        headers: await _getHeaders(),
        body: json.encode(model.toJson()),
      );

      if (response.statusCode == 200) {
        return ResponseDTO.fromJson(json.decode(response.body), (data) => data);
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseDTO(success: false, message: 'Erreur de connexion: $e');
    }
  }

  // 8. Confirmer le changement d'email
  Future<ResponseDTO> confirmEmailChange(ConfirmEmailChangeDTO model) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/Profile/ConfirmEmailChange'),
        headers: await _getHeaders(),
        body: json.encode(model.toJson()),
      );

      if (response.statusCode == 200) {
        return ResponseDTO.fromJson(json.decode(response.body), (data) => data);
      } else {
        return ResponseDTO(
          success: false,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ResponseDTO(success: false, message: 'Erreur de connexion: $e');
    }
  }

  // Méthode pour envoyer l'email pour la réinitialisation du mot de passe
  // Appel de l'API pour demander la réinitialisation de mot de passe
  Future<void> forgotPassword(String email) async {
    final url = Uri.parse(
      '$_baseUrl/api/Profile/forgot-password',
    ); // Change l'endpoint selon ton API

    // Corps de la requête
    final body = json.encode({'email': email});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              'Erreur lors de l\'envoi du lien de réinitialisation',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }

  // Méthode pour réinitialiser le mot de passe
  // Méthode pour réinitialiser le mot de passe
  // Méthode pour réinitialiser le mot de passe
  Future<ResponseDTO<String>> resetPassword(
    String email,
    String token,
    String newPassword,
    String confirmPassword,
  ) async {
    final url = Uri.parse('$_baseUrl/api/Profile/reset-password');

    // Vérification si les mots de passe correspondent
    if (newPassword != confirmPassword) {
      return ResponseDTO<String>(
        success: false,
        message: "Les mots de passe ne correspondent pas.",
      );
    }

    // Préparation du corps de la requête
    final body = json.encode({
      'email': email,
      'token': token,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });

    try {
      // Envoi de la requête POST avec en-tête Content-Type pour JSON
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Vérification du statut de la réponse
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ResponseDTO<String>(
          success: true,
          message: data['message'] ?? "Mot de passe réinitialisé avec succès",
        );
      } else {
        // Gérer les erreurs côté serveur
        final errorData = jsonDecode(response.body);
        return ResponseDTO<String>(
          success: false,
          message:
              errorData['message'] ??
              'Erreur inattendue lors de la réinitialisation du mot de passe.',
        );
      }
    } catch (e) {
      // Gestion des erreurs réseau
      return ResponseDTO<String>(success: false, message: 'Erreur réseau: $e');
    }
  }
}
