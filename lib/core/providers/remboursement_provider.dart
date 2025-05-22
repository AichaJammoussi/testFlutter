import 'package:flutter/material.dart';
import 'package:testfront/core/models/RemboursementDTO.dart';
import 'package:testfront/core/models/StatutRemboursement.dart';
import 'package:testfront/core/services/RemboursementService.dart';
import 'package:flutter/material.dart';
import 'package:testfront/core/models/RemboursementDTO.dart';
import 'package:testfront/core/services/RemboursementService.dart';

class RemboursementProvider extends ChangeNotifier {
  final RemboursementService _service = RemboursementService();

  bool _isLoading = false;
  String? _error;
  List<RemboursementDTO> _remboursements = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RemboursementDTO> get remboursements => _remboursements;

  /// Charge les remboursements de l'employé connecté
  Future<void> loadMesRemboursements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _service.getMesRemboursements();
    if (response.success && response.data != null) {
      _remboursements = response.data!;
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Crée ou met à jour une demande pour une mission donnée
  Future<void> creerOuMettreAJourDemande(int missionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _service.creerOuMettreAJourDemande(missionId);

    if (response.success && response.data != null) {
      final nouvelleDemande = response.data!;

      final index = _remboursements.indexWhere((r) => r.missionId == missionId);

      if (index != -1) {
        _remboursements[index] = nouvelleDemande;
      } else {
        _remboursements.add(nouvelleDemande);
      }
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge tous les remboursements (admin)
  Future<void> loadTousLesRemboursements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _remboursements = await _service.getTousLesRemboursements();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> changerStatut(
    int remboursementId,
    StatutRemboursement statut,
  ) async {
    try {
      print(
        "🔄 Changement du statut pour le remboursement ID: $remboursementId => $statut",
      );

      final success = await _service.changerStatutRemboursement(
        remboursementId,
        statut,
      );
      if (success) {
        final index = _remboursements.indexWhere(
          (r) => r.remboursementId == remboursementId,
        );
        if (index != -1) {
          _remboursements[index].statut = statut;
          loadTousLesRemboursements();
          notifyListeners();
        }
        print("✅ Statut mis à jour localement.");
        return true;
      } else {
        print("❌ Erreur lors du changement de statut.");
        return false;
      }
    } catch (e) {
      print("🛑 Exception lors du changement de statut : $e");
      return false;
    }
  }
}
