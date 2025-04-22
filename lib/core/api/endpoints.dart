class ApiEndpoints {
  static const String login = '/Auth/login';
  static const String register = '/auth/register';
  static const String validateToken = '/auth/validate-token';
  static const String getProfile = '/profile/GetProfile';
  static const String updateProfile = '/profile/UpdateProfile';
  static const String baseUrl = 'https://localhost:7261/api';

  static const String profile = '$baseUrl/Auth';

  static String changePassword(String userId) =>
      '$profile/change-password/$userId';
}
