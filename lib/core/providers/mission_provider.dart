import 'package:flutter/material.dart';
import 'package:testfront/core/models/MissionCreationDTO.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/models/UserDTO.dart';
import 'package:testfront/core/models/VehiculeMissionDTO.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/services/MissionService.dart';

class MissionProvider with ChangeNotifier {
  final MissionService _missionService = MissionService();

  List<MissionDTO> _missions = [];
  List<MissionDTO> get missions => _missions;

  List<VehiculeMissionDTO> _vehiculesDisponibles = [];
  List<VehiculeMissionDTO> get vehiculesDisponibles => _vehiculesDisponibles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Map<String, String> get fieldErrors => _fieldErrors;
  Map<String, String> _fieldErrors = {};

  String? _error;
  String? get error => _error;

  Future<void> loadMissions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _missionService.fetchMissions();
    if (response.success) {
      _missions = response.data ?? [];
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createMission(MissionCreationDTO dto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    _fieldErrors = {};

    final response = await _missionService.createMission(dto);
    if (response.success) {
      _missions.add(response.data!);
      _isLoading = false;

      notifyListeners();

      return true;
    } else {
      _error = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  MissionDTO? getMissionById(int id) {
    try {
      return _missions.firstWhere((m) => m.missionId == id);
    } catch (_) {
      return null;
    }
  }/*
MissionDTO? _missionId;
  MissionDTO? get mission => _missionId;
 Future<void> loadMissionById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Provider: chargement de la mission id=$id');
      ResponseDTO<MissionDTO> response = await _missionService.fetchMissionById(id);

      if (response.success && response.data != null) {
        _missionId = response.data;
        print('Provider: mission chargée avec succès: ${_missionId!.titre}');
      } else {
        _error = response.message ?? 'Erreur inconnue';
        print('Provider: erreur chargement mission: $_error');
      }
    } catch (e) {
      _error = e.toString();
      print('Provider: exception: $_error');
    }

    _isLoading = false;
    notifyListeners();
  }*/
  Future<void> loadVehiculesDisponibles(
    DateTime dateDebut,
    DateTime dateFin,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _missionService.fetchVehiculesDisponibles(
      dateDebut,
      dateFin,
    );

    if (response.success) {
      _vehiculesDisponibles = response.data ?? [];
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteMission(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _missionService.deleteMission(id);

    if (response.success && response.data == true) {
      print('✅ Mission supprimée avec succès');
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      print('❌ Erreur suppression mission : $_error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMissionsByUserId(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _missionService.fetchMissionsByUserId(userId);

      if (response.success) {
        _missions = response.data ?? [];
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des missions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMission(int id, MissionCreationDTO missionDto) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _missionService.updateMission(id, missionDto);

      if (response.success) {
        print('✅ Mission mise à jour avec succès.');
        await loadMissions(); // Recharge les missions
        return true;
      } else {
        _error = response.message;
        print('❌ Erreur mise à jour : ${response.message}');
        if (response.errors != null) {
          response.errors!.forEach((key, value) {
            print('🛑 Champ: $key → $value');
          });
        }
        return false;
      }
    } catch (e) {
      _error = 'Erreur lors de la mise à jour de la mission: $e';
      print(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /*double? _totalDepenses;

  double? get totalDepenses => _totalDepenses;

  Future<void> fetchTotalDepenses(int missionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final total = await _missionService.getTotalDepensesParMission(missionId);
      _totalDepenses = total;
    } catch (e) {
      _error = e.toString();
      _totalDepenses = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _totalBudget = 0;
  double get totalBudget => _totalBudget;

  Future<void> chargerTotalBudget(int missionId) async {
    try {
      final total = await _missionService.getTotalBudgetParMission(missionId);
      _totalBudget = total;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
*/
  void clearErrors() {
    _error = null;
    _fieldErrors = {};
    notifyListeners();
  }
}
