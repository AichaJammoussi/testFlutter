import 'package:flutter/foundation.dart';
import 'package:testfront/core/models/RoleDto.dart';
import 'package:testfront/core/models/UserRoleAssignmentMultiDTO.dart';
import 'package:testfront/core/models/UserRolesDTO.dart';
import 'package:testfront/core/services/role_service.dart';

class RoleProvider with ChangeNotifier {
  final RoleService _service = RoleService();

  List<RoleDTO> _roles = [];
  bool _isLoading = false;

  List<RoleDTO> get roles => _roles;
  bool get isLoading => _isLoading;

  // Utilisateurs par rôle
  List<UserRolesDTO> _usersByRole = [];
  bool _isUsersLoading = false;

  List<UserRolesDTO> get usersByRole => _usersByRole;
  bool get isUsersLoading => _isUsersLoading;

  /// Récupération des rôles depuis le backend
  Future<void> fetchRoles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _service.fetchRoles();
      if (result.success && result.data != null) {
        _roles = result.data!;
      }
    } catch (e) {
      debugPrint('Erreur lors du fetch des rôles: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ajout d’un nouveau rôle
  Future<bool> addRole(String name) async {
    try {
      final response = await _service.createRole(name);
      if (response.success && response.data != null) {
        _roles.add(response.data!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'ajout du rôle: $e');
      return false;
    }
  }

  /// Mise à jour d’un rôle existant
  Future<bool> updateRole(String id, String name) async {
    try {
      final response = await _service.updateRole(id, name);
      if (response.success && response.data != null) {
        final index = _roles.indexWhere((r) => r.id == id);
        if (index != -1) {
          _roles[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour: $e');
      return false;
    }
  }

  /// Suppression d’un rôle
  Future<bool> deleteRole(String id) async {
    try {
      final response = await _service.deleteRole(id);
      if (response.success && response.data != null) {
        _roles.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la suppression: $e');
      return false;
    }
  }

  /// Récupération des utilisateurs assignés à un rôle
  Future<void> fetchUsersByRole(String roleName) async {
    _isUsersLoading = true;
    notifyListeners();

    try {
      final response = await _service.getUsersByRole(roleName);
      if (response.success && response.data != null) {
        _usersByRole = response.data!;
      } else {
        _usersByRole = [];
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération des utilisateurs du rôle: $e');
      _usersByRole = [];
    }

    _isUsersLoading = false;
    notifyListeners();
  }

  /// Assignation de rôles à plusieurs utilisateurs
  Future<bool> assignRolesToMultipleUsers(
    List<String> userIds,
    List<String> roles,
  ) async {
    try {
      final response = await _service.assignRolesToMultipleUsers(
        userIds,
        roles,
      );
      if (response.success && response.data != null) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de l\'assignation des rôles: $e');
      return false;
    }
  }
  

/// Récupération de tous les utilisateurs avec leurs rôles
 Future<List<UserRolesDTO>> getAllUsersWithRoles() async {
  _isLoading = true;
  notifyListeners();

  try {
    final response = await _service.getAllUsersWithRoles();
    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  } catch (e) {
    debugPrint('Error fetching users with roles: $e');
    return [];
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<bool> removeRoleFromUser(String userId, String roleName) async {
 try {
 final response = await _service.removeRoleFromUser(userId, roleName);
 if (response.success) {
 notifyListeners();
 return true;
 }
 return false;
 } catch (e) {
 debugPrint('Erreur lors de la suppression du rôle: $e');
 return false;
 }
 }

}
