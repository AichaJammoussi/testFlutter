import 'package:dio/dio.dart';
import 'package:stage_front_end/core/models/user_profile.dart';
import '../api/endpoints.dart';

class ProfileService {
  final Dio dio;

  ProfileService(this.dio);

  Future<UserProfile> getProfile(String userId) async {
    final response = await dio.get(
      '${ApiEndpoints.getProfile}/$userId',
    );
    return UserProfile.fromJson(response.data);
  }

  Future<UserProfile> updateProfile({
    required String userId,
    required String nom,
    required String prenom,
    required String phoneNumber,
  }) async {
    final response = await dio.put(
      '${ApiEndpoints.updateProfile}/$userId',
      data: {
        'nom': nom,
        'prenom': prenom,
        'phoneNumber': phoneNumber,
      },
    );
    return UserProfile.fromJson(response.data);
  }

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    await dio.post(
      '${ApiEndpoints.changePassword}/$userId',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}