import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyUserRoles = 'user_roles';
  static const _keyUserEmail = 'user_email';
  static const _keyUserName = 'user_name';

  late final SharedPreferences _prefs;

  StorageService(SharedPreferences prefs) : _prefs = prefs;

  Future<void> saveAuthData({
    required String token,
    required String userId,
    required List<String> roles,
    required String email,
    required String fullName,
  }) async {
    await _prefs.setString(_keyToken, token);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setStringList(_keyUserRoles, roles);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserName, fullName);
  }

  String? getToken() => _prefs.getString(_keyToken);

  String? getUserId() => _prefs.getString(_keyUserId);

  List<String> getUserRoles() => _prefs.getStringList(_keyUserRoles) ?? [];

  String? getUserEmail() => _prefs.getString(_keyUserEmail);

  String? getUserName() => _prefs.getString(_keyUserName);

  bool isAdmin() => getUserRoles().contains('Admin');

  Future<void> clearAuthData() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserRoles);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
  }

  bool isLoggedIn() => getToken() != null;
}