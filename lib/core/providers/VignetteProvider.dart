import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:testfront/core/models/VignetteCreationDto.dart';
import 'package:testfront/core/models/vignette_dto.dart';
import 'package:testfront/core/models/response.dart';
import 'package:testfront/core/services/vignette_service.dart';

class VignetteProvider with ChangeNotifier {
  final VignetteService _vignetteService = VignetteService();

  List<VignetteDto> _vignettes = [];
  List<VignetteDto> get vignettes => _vignettes;
  ResponseDTO<VignetteDto>? _vignetteResponse;
  ResponseDTO<VignetteDto>? get vignetteResponse => _vignetteResponse;
  bool? _doitPayer;
  DateTime? _dateLimitePaiement;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool? get doitPayer => _doitPayer;
  DateTime? get dateLimitePaiement => _dateLimitePaiement;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Fonction pour définir si le véhicule doit payer la vignette
  void _setDoitPayer(bool doitPayer) {
    _doitPayer = doitPayer;
    notifyListeners();
  }

  // Fonction pour définir la date limite de paiement
  void _setDateLimitePaiement(DateTime dateLimite) {
    _dateLimitePaiement = dateLimite;
    notifyListeners();
  }

  /// 🔹 Créer une vignette
  Future<ResponseDTO<VignetteDto>?> createVignette(
    VignetteCreationDto dto,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _vignetteService.createVignette(dto);

      if (!response.success) {
        _errorMessage = response.message;
        if (response.errors != null) {
          _errorMessage =
              '${response.message}\n${response.errors!.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
        }
      }

      return response;
    } catch (e) {
      _errorMessage = 'Erreur inattendue: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Récupérer la date limite de paiement de la vignette
  Future<ResponseDTO<DateTime>?> getDateLimitePaiement(
    int vehiculeId,
    int annee,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _vignetteService.getDateLimitePaiement(
        vehiculeId,
        annee,
      );

      if (!response.success) {
        _errorMessage = response.message;
        if (response.errors != null) {
          _errorMessage =
              '${response.message}\n${response.errors!.entries.map((e) => '${e.key}: ${e.value}').join('\n')}';
        }
      } else if (response.data != null) {
        _dateLimitePaiement = response.data!;
      } else {
        _errorMessage = 'Aucune date limite disponible';
      }

      return response;
    } catch (e) {
      _errorMessage = 'Erreur inattendue: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Mettre à jour une vignette
  /* Future<ResponseDTO<VignetteDTO>> updateVignette(
    int id,
    VignetteCreationDto dto,
    File? file,
  ) async {
    _setLoading(true);
    final result = await _vignetteService.updateVignette(id, dto, file);
    _setLoading(false);

    if (result.success && result.data != null) {
      final index = _vignettes.indexWhere((v) => v.vignetteId == id);
      if (index != -1) {
        _vignettes[index] = result.data!;
      }
      _setError(null);
    } else {
      _setError(result.message);
    }

    notifyListeners();
    return result;
  }
*/
  /// 🔹 Récupérer toutes les vignettes
  Future<void> fetchAllVignettes() async {
    _setLoading(true);
    final result = await _vignetteService.getAllVignettes();
    _setLoading(false);

    if (result.success && result.data != null) {
      _vignettes = result.data!;
      _setError(null);
    } else {
      _setError(result.message);
    }

    notifyListeners();
  }

  /// 🔹 Supprimer une vignette
  Future<ResponseDTO<bool>> deleteVignette(int id) async {
    _setLoading(true);
    final result = await _vignetteService.deleteVignette(id);
    _setLoading(false);

    if (result.success && result.data == true) {
      _vignettes.removeWhere((v) => v.VignetteId == id);
      _setError(null);
    } else {
      _setError(result.message);
    }

    notifyListeners();
    return result;
  }

  /// 🔹 Récupérer les vignettes par véhicule
  Future<void> fetchVignettesByVehiculeId(int vehiculeId) async {
    _setLoading(true);
    final result = await _vignetteService.getVignettesByVehiculeId(vehiculeId);
    _setLoading(false);

    if (result.success && result.data != null) {
      _vignettes = result.data!;
      _setError(null);
    } else {
      _setError(result.message);
    }

    notifyListeners();
  }

  /// 🔹 Récupérer une seule vignette
  Future<ResponseDTO<VignetteDto>> getVignetteById(int id) async {
    return await _vignetteService.getVignetteById(id);
  }
}
