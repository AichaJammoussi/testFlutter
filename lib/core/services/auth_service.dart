import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as client;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testfront/core/config/api_config.dart';
import 'package:testfront/core/models/auth_response.dart';
import 'package:testfront/core/models/register_data.dart';

class AuthService {
  final http.Client client;
  static const String _authTokenKey = 'auth_token';
  
  
  static const String _userIdKey = 'user_id';

  AuthService({http.Client? client}) : client = client ?? http.Client();

   Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}');
    
    if (kDebugMode) {
      print('🔄 Tentative de connexion vers $uri');
      print('📩 Données envoyées: {email: $email, password: ********}');
    }

    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (kDebugMode) {
        print('✅ Statut HTTP: ${response.statusCode}');
        print('📦 Réponse brute: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 400) {
        return AuthResponse.fromJson(jsonResponse);
      } else {
        return AuthResponse(
          success: false,
          message: 'Erreur serveur (${response.statusCode})',
          errors: jsonResponse['errors'] != null
              ? Map<String, String>.from(jsonResponse['errors'])
              : null,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la connexion: $e');
      }
      
      // Gestion plus fine des erreurs réseau
      if (e is http.ClientException) {
        return AuthResponse(
          success: false,
          message: 'Erreur de connexion au serveur',
          errors: {'network': 'Vérifiez votre connexion internet'},
        );
      } else if (e is FormatException) {
        return AuthResponse(
          success: false,
          message: 'Réponse serveur invalide',
          errors: {'server': 'Erreur technique côté serveur'},
        );
      } else {
        return AuthResponse(
          success: false,
          message: 'Erreur inattendue: ${e.toString()}',
          errors: {'server': 'Erreur technique'},
        );
      }
    }
  }
  Future<AuthResponse> register(RegisterData data) async {
    final uri = Uri.parse(ApiConfig.baseUrl + ApiConfig.register);
    var request = http.MultipartRequest('POST', uri);

    // Ajout des champs requis
    request.fields['nom'] = data.nom;
    request.fields['prenom'] = data.prenom;
    request.fields['email'] = data.email;
    request.fields['phoneNumber'] = data.phoneNumber;
    request.fields['password'] = data.password;
    request.fields['confirmPassword'] = data.confirmPassword;

    // Ajout du fichier photo si disponible
    if (data.photoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photoDeProfil', // Important : doit correspondre au backend C#
          data.photoFile!.path,
        ),
      );
    }

    try {
      print('🔄 Envoi de la requête vers $uri');
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      print('✅ Statut HTTP : ${streamedResponse.statusCode}');
      print('📦 Réponse brute : $responseBody');

      final jsonResponse = jsonDecode(responseBody);

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 400) {
        return AuthResponse.fromJson(jsonResponse);
      } else {
        return AuthResponse(
          success: false,
          message: 'Erreur serveur (${streamedResponse.statusCode})',
          errors: jsonResponse['errors'] != null
              ? Map<String, String>.from(jsonResponse['errors'])
              : null,
        );
      }
    } catch (e) {
      print('❌ Erreur réseau : $e');
      return AuthResponse(
        success: false,
        message: 'Erreur réseau: ${e.toString()}',
      );
    }
  }

 Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }
   Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

 Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> testApiConnection() async {
    final stopwatch = Stopwatch()..start();
    debugPrint('🔄 Testing API connection to ${ApiConfig.baseUrl}');

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/Auth/test-connection');
      final response = await client
          .get(uri)
          .timeout(const Duration(seconds: 5));

      stopwatch.stop();
      debugPrint('⏱ Response time: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('📊 Status: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      if (response.statusCode != 200) {
        throw HttpException('Unexpected status: ${response.statusCode}');
      }

      return true;
    } on TimeoutException {
      debugPrint('⌛ Timeout after 5 seconds');
      return false;
    } on SocketException catch (e) {
      debugPrint('🔌 Network error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('⚠️ Error: $e');
      return false;
    }
  }
}
/* | 
http.Client | Le moteur qui envoie tes requêtes HTTP/HTTPS
final client; | Ta voiture pour aller vers l'API
client ?? http.Client(); | Soit tu amènes ta propre voiture, soit je t’en donne une neuve. 🚗*/

