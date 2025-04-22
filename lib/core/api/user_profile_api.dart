import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:stage_front_end/core/models/user_profile.dart';
import '../models/response.dart';
import '../models/user.dart';
import 'api_client.dart';

class UserProfileApi {
  final ApiClient _apiClient;

  UserProfileApi(this._apiClient);

  Future<ResponseDTO<UserProfile>> getUserProfile(String userId) async {
    final response = await _apiClient.get('user-profile/$userId');
    final jsonData = jsonDecode(response.body);
    return ResponseDTO.fromJson(jsonData, (data) => UserProfile.fromJson(data));
  }

  Future<ResponseDTO> updateUserProfile(String userId, String nom, String prenom, String phoneNumber) async {
    final response = await _apiClient.put(
      'user-profile/$userId',
      {
        'nom': nom,
        'prenom': prenom,
        'phoneNumber': phoneNumber,
      },
    );

    final jsonData = jsonDecode(response.body);
    return ResponseDTO.fromJson(jsonData, null);
  }

  Future<ResponseDTO> changePassword(String userId, String currentPassword, String newPassword) async {
    final response = await _apiClient.post(
      'user-profile/$userId/change-password',
      {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    final jsonData = jsonDecode(response.body);
    return ResponseDTO.fromJson(jsonData, null);
  }

  Future<ResponseDTO<String>> updateProfilePicture(String userId, File imageFile) async {
    var uri = Uri.parse('${_apiClient.baseUrl}/user-profile/$userId/profile-picture');
    
    var request = http.MultipartRequest('POST', uri);
    
    // Ajout du token d'authentification
    final token = await _apiClient._storageService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Ajout du fichier image
    var fileExtension = imageFile.path.split('.').last.toLowerCase();
    var contentType = '';
    if (['jpg', 'jpeg'].contains(fileExtension)) {
      contentType = 'image/jpeg';
    } else if (fileExtension == 'png') {
      contentType = 'image/png';
    }

    request.files.add(
      http.MultipartFile(
        'file',
        imageFile.readAsBytes().asStream(),
        imageFile.lengthSync(),
        filename: imageFile.path.split('/').last,
        contentType: MediaType.parse(contentType),
      ),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    final jsonData = jsonDecode(response.body);
    return ResponseDTO<String>.fromJson(jsonData, (data) => data as String);
  }
}