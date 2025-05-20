import 'package:flutter/material.dart';
import 'package:testfront/core/models/MissionCreationDTO.dart';
import 'package:testfront/core/models/MissionDTO.dart';
import 'package:testfront/core/models/UserDTO.dart';
import 'package:testfront/core/models/VehiculeMissionDTO.dart';
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
  }

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


  void clearErrors() {
    _error = null;
    _fieldErrors = {};
    notifyListeners();
  }
}
