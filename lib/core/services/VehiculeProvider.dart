import 'package:flutter/foundation.dart';
import 'package:testfront/core/models/StatutVehicule.dart';
import 'package:testfront/core/models/VehiculeCreationDTO.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/services/VehiculeService.dart';

class VehiculeProvider with ChangeNotifier {
  final VehiculeService _vehiculeService = VehiculeService();
  List<VehiculeDTO> _vehicules = [];
  bool _isLoading = false;

  List<VehiculeDTO> get vehicules => _vehicules;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 🔁 Charger les véhicules
  Future<void> loadVehicules() async {
    _setLoading(true);
    try {
      final response = await _vehiculeService.fetchVehicules();
      if (response.success && response.data != null) {
        _vehicules = response.data!;
      } else {
        throw Exception(response.message ?? "Erreur inconnue");
      }
    } catch (e) {
      debugPrint("Erreur: $e");
    } finally {
      _setLoading(false);
    }
  }

  // ➕ Ajouter un véhicule
  Future<ResponseDTO<VehiculeDTO>> createVehicule(VehiculeCreationDTO dto) async {
  _setLoading(true);
  try {
    final response = await _vehiculeService.createVehicule(dto);

    if (response.success && response.data != null) {
      _vehicules.add(response.data!);
    }

    return response;
  } finally {
    _setLoading(false);
  }
}


  // 🗑 Supprimer un véhicule
  Future<void> deleteVehicule(int id) async {
    _setLoading(true);
    try {
      final response = await _vehiculeService.deleteVehicule(id);
      if (response.success) {
        _vehicules.removeWhere((v) => v.vehiculeId == id);
      } else {
        throw Exception(response.message ?? "Erreur lors de la suppression");
      }
    } catch (e) {
      debugPrint("Erreur: $e");
    } finally {
      _setLoading(false);
    }
  }
}
