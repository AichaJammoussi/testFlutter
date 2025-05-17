import 'package:flutter/foundation.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
import 'package:testfront/core/models/tache_dto.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/models/tache_creation_dto.dart';
import 'package:testfront/core/services/tache_service.dart';

class TacheProvider extends ChangeNotifier {
  final TacheService _service = TacheService();

  List<TacheDTO> _taches = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TacheDTO> get taches => _taches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Charger toutes les tâches
  Future<void> fetchAllTaches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getAllTaches();

    if (response.success && response.data != null) {
      _taches = response.data!;
    } else {
      _errorMessage = response.message ?? "Erreur inconnue";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Créer une tâche
  Future<bool> createTache(TacheCreationDTO newTache) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.createTache(newTache);

    if (response.success && response.data != null) {
      _taches.add(response.data!);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? "Erreur lors de la création";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour une tâche
  Future<bool> updateTache(int id, TacheUpdateDTO tacheUpdate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.updateTache(id, tacheUpdate);

    if (response.success && response.data != null) {
      final index = _taches.indexWhere((t) => t.tacheId == id);
      if (index != -1) {
        _taches[index] = response.data!;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? "Erreur lors de la mise à jour";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Supprimer une tâche
  Future<bool> deleteTache(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.deleteTache(id);

    if (response.success && response.data == true) {
      _taches.removeWhere((t) => t.tacheId == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? "Erreur lors de la suppression";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour le statut d’une tâche
  Future<bool> updateStatutTache(int id, String statut) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.updateStatutTache(id, statut);

    if (response.success && response.data != null) {
      final index = _taches.indexWhere((t) => t.tacheId == id);
      if (index != -1) {
        _taches[index] = response.data!;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          response.message ?? "Erreur lors de la mise à jour du statut";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Marquer tâche comme terminée
  Future<bool> completeTache(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.completeTache(id);

    if (response.success && response.data != null) {
      final index = _taches.indexWhere((t) => t.tacheId == id);
      if (index != -1) {
        _taches[index] = response.data!;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? "Erreur lors de la complétion";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTachesByMissionId(int missionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final ResponseDTO<List<TacheDTO>> response = await _service
        .getTachesByMission(missionId);

    if (response.success && response.data != null) {
      _taches = response.data!;
    } else {
      _errorMessage = response.message ?? "Erreur inconnue";
    }

    _isLoading = false;
    notifyListeners();
  }
}
