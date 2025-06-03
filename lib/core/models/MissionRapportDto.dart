import 'package:testfront/core/models/EmployeMissionRapportDto.dart';
import 'package:testfront/core/models/UserTachesRapportDto.dart';
import 'package:testfront/core/models/VehiculeDto.dart'; // à créer si pas encore
import 'package:intl/intl.dart';

class MissionRapportDto {
  final int missionId;
  final String titre;
  final String description;
  final String statut;
  final String priorite;
  final double budget;
  final double depenses;
  final double remboursement;

  final DateTime dateDebutPrevue;
  final DateTime dateFinPrevue;
  final DateTime? dateDebutReelle;
  final DateTime? dateFinReelle;

  final String typeMoyenTransport;
  final List<VehiculeDTO> vehicules;

  final List<UserTachesRapportDto> tachesParEmploye;
  final List<EmployeMissionRapportDto> employesMission;

  MissionRapportDto({
    required this.missionId,
    required this.titre,
    required this.description,
    required this.statut,
    required this.priorite,
    required this.budget,
    required this.depenses,
    required this.remboursement,
    required this.dateDebutPrevue,
    required this.dateFinPrevue,
    this.dateDebutReelle,
    this.dateFinReelle,
    required this.typeMoyenTransport,
    required this.vehicules,
    required this.tachesParEmploye,
    required this.employesMission,
  });

  factory MissionRapportDto.fromJson(Map<String, dynamic> json) {
    return MissionRapportDto(
      missionId: json['missionId'],
      titre: json['titre'],
      description: json['description'],
      statut: json['statut'],
      priorite: json['priorite'],
      budget: (json['budget'] ?? 0).toDouble(),
      depenses: (json['depenses'] ?? 0).toDouble(),
      remboursement: (json['remboursement'] ?? 0).toDouble(),
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
      typeMoyenTransport: json['typeMoyenTransport'] ?? '',
      vehicules:
          (json['vehicules'] as List<dynamic>)
              .map((e) => VehiculeDTO.fromJson(e))
              .toList(),
      tachesParEmploye:
          (json['tachesParEmploye'] as List<dynamic>)
              .map((e) => UserTachesRapportDto.fromJson(e))
              .toList(),
      employesMission:
          (json['employesMission'] as List<dynamic>)
              .map((e) => EmployeMissionRapportDto.fromJson(e))
              .toList(),
    );
  }
}
