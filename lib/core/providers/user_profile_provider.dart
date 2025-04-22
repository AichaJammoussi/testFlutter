import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:stage_front_end/core/models/user_profile.dart';
import '../api/user_profile_api.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class UserProfileProvider with ChangeNotifier {
  final UserProfileApi _userProfileApi;
  final StorageService _storageService;
  
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  
  UserProfileProvider(this._userProfileApi, this._storageService);
  
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final userId = await _storageService.getUserId();
      
      if (userId == null) {
        _errorMessage = 'Utilisateur non connecté';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final response = await _userProfileApi.getUserProfile(userId);
      
      if (response.success && response.data != null) {
        _userProfile = response.data;
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = response.message ?? 'Échec de chargement du profil';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau ou serveur';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateUserProfile(String nom, String prenom, String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final userId = await _storageService.getUserId();
      
      if (userId == null) {
        _errorMessage = 'Utilisateur non connecté';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final response = await _userProfileApi.updateUserProfile(userId, nom, prenom, phoneNumber);
      
      if (response.success) {
        // Rafraîchir le profil après mise à jour
        await loadUserProfile();
        return true;
      } else {
        _errorMessage = response.message ?? 'Échec de mise à jour du profil';
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
  
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final userId = await _storageService.getUserId();
      
      if (userId == null) {
        _errorMessage = 'Utilisateur non connecté';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final response = await _userProfileApi.changePassword(userId, currentPassword, newPassword);
      
      _isLoading = false;
      
      if (response.success) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Échec de changement de mot de passe';
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
  
  Future<bool> updateProfilePicture(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final userId = await _storageService.getUserId();
      
      if (userId == null) {
        _errorMessage = 'Utilisateur non connecté';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final response = await _userProfileApi.updateProfilePicture(userId, imageFile);
      
      if (response.success && response.data != null) {
        // Mettre à jour l'URL de l'image dans le profil utilisateur
        if (_userProfile != null) {
          _userProfile = UserProfile(
            userId: _userProfile!.userId,
            email: _userProfile!.email,
            nom: _userProfile!.nom,
            prenom: _userProfile!.prenom,
            phoneNumber: _userProfile!.phoneNumber,
            profilePictureUrl: response.data
          );
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Échec de mise à jour de la photo de profil';
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
}