import 'package:flutter/material.dart';
import 'package:testfront/core/models/DepenseCreationDTO.dart';
import 'package:testfront/core/models/Depensedto.dart';
import 'package:testfront/core/services/depenseService.dart';

class DepenseProvider extends ChangeNotifier {
  final DepenseService _service = DepenseService();

  List<DepenseDTO> _depenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DepenseDTO> get depenses => _depenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Créer une dépense
  Future<bool> createDepense(DepenseCreationDTO newDepense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.createDepense(newDepense);

    if (response.success && response.data != null) {
      _depenses.add(response.data!);
      _isLoading = false;
      notifyListeners();

      await fetchAllDepenses(); // Recharge la liste complète
      return true;
    } else {
      _errorMessage =
          response.message ?? "Erreur lors de la création de la dépense";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Récupérer toutes les dépenses
  Future<void> fetchAllDepenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getAllDepenses();

    if (response.success && response.data != null) {
      _depenses = response.data!;
    } else {
      _errorMessage =
          response.message ?? "Erreur lors du chargement des dépenses";
    }
    _isLoading = false;
    notifyListeners();
  }

  // Supprimer une dépense par id
  Future<bool> deleteDepense(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.deleteDepense(id);

    if (response.success && response.data == true) {
      _depenses.removeWhere((depense) => depense.depenseId == id);
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

  // Mettre à jour une dépense
  Future<bool> updateDepense(int id, DepenseCreationDTO updatedDepense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.updateDepense(id, updatedDepense);

    if (response.success && response.data != null) {
      final index = _depenses.indexWhere((d) => d.depenseId == id);
      if (index != -1) {
        _depenses[index] = response.data!;
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

  // Récupérer une dépense par id
  Future<DepenseDTO?> getDepenseById(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getDepenseById(id);

    _isLoading = false;
    if (response.success && response.data != null) {
      notifyListeners();
      return response.data!;
    } else {
      _errorMessage = response.message ?? "Erreur lors de la récupération";
      notifyListeners();
      return null;
    }
  }
  Future<bool> fetchDepensesByTacheId(int tacheId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.getDepensesByTacheId(tacheId);

    if (response.success && response.data != null) {
      _depenses = response.data!;
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
}
