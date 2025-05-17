import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';

class Tache {
  final int? tacheId;
  final String titre;
  final String description;
  final StatutTache? statut;
  final PrioriteTache priorite;
  final DateTime dateCreation;
  final DateTime? dateRealisation;
  final String userId;
  final int? missionId;

  Tache({
    this.tacheId,
    required this.titre,
    required this.description,
    required this.statut,
    required this.priorite,
    required this.dateCreation,
    this.dateRealisation,
    required this.userId,
    this.missionId,
  });

  factory Tache.fromJson(Map<String, dynamic> json) {
    return Tache(
      tacheId: json['tacheId'],
      titre: json['titre'],
      description: json['description'],
      statut: StatutTache.fromInt(json['statut']),
      priorite: PrioriteTache.fromInt(json['priorite']),
      dateCreation: DateTime.parse(json['dateCreation']),
      dateRealisation:
          json['dateRealisation'] != null
              ? DateTime.parse(json['dateRealisation'])
              : null,
      userId: json['userId'],
      missionId: json['missionId'],
    );
  }
}
