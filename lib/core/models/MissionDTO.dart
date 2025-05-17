import 'package:testfront/core/models/PrioriteMission.dart';
import 'package:testfront/core/models/StatutMission.dart';
import 'package:testfront/core/models/UserDTO.dart';
import 'package:testfront/core/models/VehiculeDTO.dart';
import 'package:testfront/core/models/MoyenTransport.dart';

class MissionDTO {
  final int missionId;
  final String titre;
  final String description;
  final DateTime dateDebutPrevue;
  final DateTime dateFinPrevue;
  final DateTime? dateDebutReelle;
  final DateTime? dateFinReelle;
  final StatutMission statut;
  final PrioriteMission priorite;
  final MoyenTransport typeMoyenTransport;
  final double budget;
  final double? depenses;
  final DateTime dateCreation;
  final String creePar;
  final List<UserDTO> employes;
  final List<VehiculeDTO>? vehicules;

  MissionDTO({
    required this.missionId,
    required this.titre,
    required this.description,
    required this.dateDebutPrevue,
    required this.dateFinPrevue,
    this.dateDebutReelle,
    this.dateFinReelle,
    required this.statut,
    required this.priorite,
    required this.typeMoyenTransport,
    required this.budget,
    this.depenses,
    required this.dateCreation,
    required this.creePar,
    required this.employes,
    this.vehicules,
  });

  factory MissionDTO.fromJson(Map<String, dynamic> json) {
    return MissionDTO(
      missionId: json['missionId'],
      titre: json['titre'],
      description: json['description'],
      dateDebutPrevue: DateTime.parse(json['dateDebutPrevue']),
      dateFinPrevue: DateTime.parse(json['dateFinPrevue']),
      dateDebutReelle:
          json['dateDebutReelle'] != null
              ? DateTime.parse(json['dateDebutReelle'])
              : null,
      dateFinReelle:
          json['dateFinReelle'] != null
              ? DateTime.parse(json['dateFinReelle'])
              : null,
      statut: StatutMission.fromInt(json['statut']),
      priorite: PrioriteMission.fromInt(json['priorite']),
      typeMoyenTransport: MoyenTransport.fromInt(json['typeMoyenTransport']),
      budget: (json['budget'] as num).toDouble(),
      depenses:
          json['depenses'] != null
              ? (json['depenses'] as num).toDouble()
              : null,
      dateCreation: DateTime.parse(json['dateCreation']),
      creePar: json['creePar'],
      employes:
          (json['employes'] as List).map((e) => UserDTO.fromJson(e)).toList(),
      vehicules:
          json['vehicules'] != null
              ? (json['vehicules'] as List)
                  .map((v) => VehiculeDTO.fromJson(v))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'missionId': missionId,
      'titre': titre,
      'description': description,
      'dateDebutPrevue': dateDebutPrevue.toIso8601String(),
      'dateFinPrevue': dateFinPrevue.toIso8601String(),
      'dateDebutReelle': dateDebutReelle?.toIso8601String(),
      'dateFinReelle': dateFinReelle?.toIso8601String(),
      'statut': statut.toJson(),
      'priorite': priorite.toJson(),
      'typeMoyenTransport': typeMoyenTransport.toJson(),
      'budget': budget,
      'depenses': depenses,
      'dateCreation': dateCreation.toIso8601String(),
      'creePar': creePar,
      'employes': employes.map((e) => e.toJson()).toList(),
      'vehicules': vehicules?.map((v) => v.toJson()).toList(),
    };
  }
}
