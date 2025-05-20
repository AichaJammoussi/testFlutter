import 'package:flutter/foundation.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/TacheUpdateDTO.dart';
import 'package:testfront/core/models/UserDto.dart';
import 'package:testfront/core/models/tache_dto.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/models/tache_creation_dto.dart';
import 'package:testfront/core/providers/mission_provider.dart';
import 'package:testfront/core/services/tache_service.dart';

class TacheProvider extends ChangeNotifier {
  final TacheService _service = TacheService();

  List<TacheDTO> _taches = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;
  TacheDTO? _selectedTache;
  TacheDTO? get selectedTache => _selectedTache;

  String? _error;
  String? get error => _error;
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

      await fetchAllTaches();
      if (_selectedTache?.missionId != null) {
        fetchTachesByMissionId(_selectedTache!.missionId!);
        updateEmployes(_selectedTache!.missionId!);
      }
      return true;
    } else {
      _errorMessage = response.message ?? "Erreur lors de la création";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getTacheById(int tacheId) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedTache = null;
    notifyListeners();

    final response = await _service.getTacheById(tacheId);

    if (response.success) {
      _selectedTache = response.data;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Erreur inconnue';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTache(int id, TacheUpdateDTO tacheDto) async {
    _isLoading = true;
    _errorMessage = null;
    _fieldErrors = {};
    notifyListeners();

    final response = await _service.updateTache(id, tacheDto);

    if (response.errors != null) {
      response.errors!.forEach((key, value) {
        if (value is String && value.isNotEmpty) {
          _fieldErrors[key] = value;
          print('🛑 Champ: $key → $value');
        }
      });
    }
    if (response.success) {
      print('✅ Tâche mise à jour avec succès.');
      _isLoading = false;

      notifyListeners();
      await getTacheById(id);
      if (_selectedTache?.missionId != null) {
        fetchTachesByMissionId(_selectedTache!.missionId!);
      }

      return true;
    } else {
      _errorMessage = response.message ?? "Erreur inconnue";
      print('❌ Erreur mise à jour tâche : $_errorMessage');
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
      if (_selectedTache?.missionId != null) {
        fetchTachesByMissionId(_selectedTache!.missionId!);
        updateEmployes(_selectedTache!.missionId!);
      }
      return true;
    } else {
      _errorMessage = response.message ?? "Erreur lors de la suppression";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour le statut d’une tâche
  Future<bool> updateStatutTache(int tacheId, StatutTache newStatut) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.updateStatutTache(
        tacheId,
        newStatut,
      );
      if (response.success && response.data != null) {
        // Met à jour la tâche dans la liste locale
        final index = _taches.indexWhere((t) => t.tacheId == tacheId);
        if (index != -1) {
          _taches[index] = response.data!;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
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

  bool? _updateSuccess;

  bool? get updateSuccess => _updateSuccess;

  Future<void> updateEmployes(int missionId) async {
    _isLoading = true;
    _updateSuccess = null;
    notifyListeners();

    try {
      final success = await _service.updateEmployesFromTaches(missionId);
      _updateSuccess = success;
    } catch (e) {
      _updateSuccess = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<UserDTO> employesDisponibles = [];

  Future<void> loadEmployesDisponibles(
    DateTime dateDebut,
    DateTime dateFin, {
    int? missionId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await _service.fetchEmployesDisponibles(
        dateDebut,
        dateFin,
        missionId: missionId,
      );
      print('Provider - employesDisponibles reçus : ${list.length}');
      employesDisponibles = list;
    } catch (e) {
      print('Erreur lors du chargement des employés disponibles : $e');
      employesDisponibles = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  double? get depenses => _depenses;
  double? _depenses;

  Future<void> loadDepensesMission(int missionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _service.fetchDepensesMission(missionId);
    if (response.success) {
      _depenses = response.data;
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }
}
