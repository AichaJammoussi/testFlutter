import 'package:testfront/core/models/StatutVehicule.dart';

class VehiculeCreationDTO {
  String marque;
  String modele;
  String immatriculation;
  int anneeMiseEnCirculation;
  int kilometrage;
  StatutVehicule statut;

  VehiculeCreationDTO({
    required this.marque,
    required this.modele,
    required this.immatriculation,
    required this.anneeMiseEnCirculation,
    required this.kilometrage,
    required this.statut,
  });

  Map<String, dynamic> toJson() => {
    'marque': marque,
    'modele': modele,
    'immatriculation': immatriculation,
    'anneeMiseEnCirculation': anneeMiseEnCirculation,
    'kilometrage': kilometrage,
    'statut': statut.name,
  };
}
