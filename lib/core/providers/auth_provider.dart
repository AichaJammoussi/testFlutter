import 'package:flutter/foundation.dart';
import '../api/auth_api.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthApi _authApi;
  final StorageService _storageService;
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  
  AuthProvider(this._authApi, this._storageService) {
    _checkLoginStatus();
  }
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  
  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();
    
    _isLoggedIn = await _storageService.isLoggedIn();
    _isAdmin = await _storageService.isAdmin();
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _authApi.login(email, password);
      
      if (response.success && response.token != null) {
        await _storageService.saveAuthData(
          response.token!,
          response.userId ?? '',
          response.userName ?? '',
          response.email ?? '',
          response.roles ?? []
        );
        
        _isLoggedIn = true;
        _isAdmin = (response.roles ?? []).contains('Admin');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Échec de connexion';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau ou serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register(
    String email, 
    String password, 
    String confirmPassword, 
    String nom, 
    String prenom, 
    String phoneNumber
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _authApi.register(
        email, password, confirmPassword, nom, prenom, phoneNumber
      );
      
      if (response.success) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Échec d\'inscription';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau ou serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _storageService.clearAuthData();
    _isLoggedIn = false;
    _isAdmin = false;
    notifyListeners();
  }
}