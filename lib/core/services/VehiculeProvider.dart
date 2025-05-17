import 'package:flutter/foundation.dart';
import 'package:testfront/core/models/StatutVehicule.dart';
import 'package:testfront/core/models/VehiculeCreationDTO.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/services/VehiculeService.dart';

class VehiculeProvider with ChangeNotifier {
  final VehiculeService _vehiculeService = VehiculeService();

  // Liste des véhicules et état de chargement
  List<VehiculeDTO> _vehicules = [];
  bool _isLoading = false;
  String? _errorMessage; // Message d'erreur
  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;
  // Pour GetById
  VehiculeDTO? _vehicule;
  String? _error;
  // Getters pour accéder aux données
  List<VehiculeDTO> get vehicules => _vehicules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  VehiculeDTO? get vehicule => _vehicule;
  String? get error => _error;
  // Méthode pour gérer l'état de chargement
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 🧳 Charger les véhicules
  Future<void> loadVehicules() async {
    _setLoading(true);
    notifyListeners(); // ✅ Avant l’attente asynchrone

    try {
      final response = await _vehiculeService.fetchVehicules();
      if (response.success && response.data != null) {
        _vehicules = response.data!;
      } else {
        throw Exception(
          response.message ??
              "Erreur inconnue lors de la récupération des véhicules",
        );
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des véhicules: $e");
      _errorMessage =
          'Erreur lors du chargement des véhicules: ${e.toString()}';
    } finally {
      _setLoading(false);
      notifyListeners(); // ✅ Après l’appel asynchrone
    }
  }

  // ➕ Créer un véhicule
  // Ajoutez un attribut pour afficher les messages d’erreur

  // 🔁 Ajouter un véhicule
  Future<ResponseDTO> createVehicule(VehiculeCreationDTO dto) async {
    _setLoading(true);
    _errorMessage = null;
    _fieldErrors = {}; // Réinitialise les erreurs de champ
    ResponseDTO response = ResponseDTO(success: false);

    try {
      print("DTO envoyé : ${dto.toJson()}");

      response = await _vehiculeService.createVehicule(dto);
      notifyListeners(); // ✅ Après l’appel asynchrone
      print("Réponse création: ${response.success}, ${response.message}");

      if (response.success) {
        await loadVehicules(); // Recharger les données si succès
      }
      _errorMessage = response.message;
      print("Erreurs de champs: $_fieldErrors");

      // If backend provides field errors, map them into _fieldErrors
      if (response.errors != null) {
        _fieldErrors = Map<String, String>.from(
          response.errors!.map(
            (key, value) =>
                MapEntry(key, value?.toString() ?? 'Erreur inconnue'),
          ),
        );
        print("Erreurs de champs: $_fieldErrors");
      }
    } catch (e) {
      _errorMessage = 'Erreur : ${e.toString()}';
      response = ResponseDTO(success: false, message: _errorMessage);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
    return response;
  }

  Future<ResponseDTO> updateVehicule(int id, VehiculeCreationDTO dto) async {
    _setLoading(true);
    _fieldErrors = {}; // Reset errors map
    ResponseDTO response = ResponseDTO(success: false);

    try {
      response = await _vehiculeService.updateVehicule(id, dto);
      notifyListeners(); // ✅ Après l’appel asynchrone

      if (response.success) {
        await loadVehicules(); // Refresh the vehicle list
      } else {
        _errorMessage = response.message;

        // If backend provides field errors, map them into _fieldErrors
        if (response.errors != null) {
          _fieldErrors = Map<String, String>.from(
            response.errors!.map(
              (key, value) =>
                  MapEntry(key, value?.toString() ?? 'Erreur inconnue'),
            ),
          );
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      response = ResponseDTO(success: false, message: _errorMessage);
    } finally {
      _setLoading(false);
      notifyListeners(); // Notify listeners to update UI
    }

    return response;
  }

  // 🗑 Supprimer un véhicule
  Future<void> deleteVehicule(int id) async {
    _setLoading(true);
    try {
      final response = await _vehiculeService.deleteVehicule(id);
      if (response.success) {
        // Supprimer le véhicule de la liste
        _vehicules.removeWhere((v) => v.vehiculeId == id);
      } else {
        throw Exception(
          response.message ?? "Erreur lors de la suppression du véhicule",
        );
      }
    } catch (e) {
      debugPrint("Erreur lors de la suppression du véhicule: $e");
      _errorMessage =
          'Erreur lors de la suppression du véhicule: ${e.toString()}';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

VehiculeDTO? getVehiculeById(int id) {
  if (_vehicule?.vehiculeId == id) return _vehicule;
  return null;
}

  Future<void> fetchVehiculeById(int id) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await _vehiculeService.getVehiculeById(id);
       if (response.success && response.data != null) {
        _vehicules = response.data! as List<VehiculeDTO>;
      } else {
        throw Exception(
          response.message ??
              "Erreur inconnue lors de la récupération des véhicules",
        );
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des véhicules: $e");
      _errorMessage =
          'Erreur lors du chargement des véhicules: ${e.toString()}';
    } finally {
      _setLoading(false);
      notifyListeners(); // ✅ Après l’appel asynchrone
    }
  }
}
