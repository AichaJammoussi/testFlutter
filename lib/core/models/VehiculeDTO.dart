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
      anneeMiseEnCirculation:
          json['anneeMiseEnCirculation'], // 👈 ne pas parser en String
      kilometrage: json['kilometrage'],
      statut: StatutVehicule.fromString(json['statut']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'vehiculeId': vehiculeId,
      'marque': marque,
      'modele': modele,
      'immatriculation': immatriculation,
      'anneeMiseEnCirculation': anneeMiseEnCirculation,
      'kilometrage': kilometrage,
      'statut': statut,
    };
  }
}
