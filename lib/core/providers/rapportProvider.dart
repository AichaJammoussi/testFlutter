import 'package:flutter/material.dart';
import 'package:testfront/core/models/MissionRapportDto.dart';
import '../services/rapport_service.dart';

class RapportProvider with ChangeNotifier {
  final RapportService _service = RapportService();

  bool isLoading = false;
  bool? tousValides;
  String? error;
  MissionRapportDto? rapport;

  /// Chargement du rapport mission
  Future<void> loadRapport(int missionId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      rapport = await _service.genererRapport(missionId);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
  /// Validation par l'employé
  Future<bool> validerParEmploye(int missionId) async {
    try {
      final success = await _service.validerParEmploye(missionId);
      notifyListeners();
      return success;
    } catch (e) {
      error = "Erreur de validation: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  /// Vérifie si tous ont validé
  Future<void> checkTousOntValide(int missionId) async {
    try {
      tousValides = await _service.tousOntValide(missionId);
    } catch (e) {
      error = "Erreur de vérification: ${e.toString()}";
    }
    notifyListeners();
  }

  /// Validation admin (oui/non)
  Future<bool> validerParAdmin(int missionId, bool accepte) async {
    try {
      final result = await _service.validerParAdmin(missionId, accepte);
      notifyListeners();
      return result;
    } catch (e) {
      error = "Erreur côté admin: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  /// Réinitialiser l’état
  void reset() {
    isLoading = false;
    rapport = null;
    tousValides = null;
    error = null;
    notifyListeners();
  }
}
