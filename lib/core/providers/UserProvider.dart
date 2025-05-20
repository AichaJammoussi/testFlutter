import 'package:flutter/material.dart';
import 'package:testfront/core/models/UserDto.dart';
import 'package:testfront/core/models/user.dart';
import 'package:testfront/core/services/UserService.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isAuthenticated => _user != null;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  UserDTO? _userr;
  bool _isLoading = false;
  String? _error;

  UserDTO? get userr => _userr;
  bool get isLoading => _isLoading;
  String? get error => _error;
  final UserService _service = UserService();

  
  String? _errorMessage;

  
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getUserById(id);

    if (response.success && response.data != null) {
      _userr = response.data;
    } else {
      _userr = null;
      _errorMessage = response.message ?? 'Erreur inconnue';
    }

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _userr = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
