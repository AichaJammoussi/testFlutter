import 'package:testfront/core/models/EmployeMissionRapportDto.dart';
import 'package:testfront/core/models/UserTachesRapportDto.dart';

class MissionRapportDto {
  final int missionId;
  final String titre;
  final String description;
  final String statut;
  final String priorite;
  final double budget;
  final double depenses;
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
      tachesParEmploye: (json['tachesParEmploye'] as List<dynamic>)
          .map((e) => UserTachesRapportDto.fromJson(e))
          .toList(),
      employesMission: (json['employesMission'] as List<dynamic>)
          .map((e) => EmployeMissionRapportDto.fromJson(e))
          .toList(),
    );
  }
}