import 'package:testfront/core/models/StatutVehicule.dart';


class VehiculeDTO {
  final int vehiculeId;
  final String marque;
  final String modele;
  final String immatriculation;
  final int anneeMiseEnCirculation;
  final int kilometrage;
  final StatutVehicule statut;

  VehiculeDTO({
    required this.vehiculeId,
    required this.marque,
    required this.modele,
    required this.immatriculation,
    required this.anneeMiseEnCirculation,
    required this.kilometrage,
    required this.statut,
  });

  factory VehiculeDTO.fromJson(Map<String, dynamic> json) {
    return VehiculeDTO(
      vehiculeId: json['vehiculeId'],
      marque: json['marque'],
      modele: json['modele'],
      immatriculation: json['immatriculation'],
      anneeMiseEnCirculation: json['anneeMiseEnCirculation'],
      kilometrage: json['kilometrage'],
      statut: StatutVehicule.values.firstWhere(
        (e) => e.name.toLowerCase() == json['statut'].toString().toLowerCase(),
        orElse: () => StatutVehicule.Disponible,
      ),
    );
  }
}
