import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';

class TacheCreationDTO {
  final String titre;
  final String description;
  final PrioriteTache priorite;
  final DateTime dateCreation;
  final String userId;
  final int? missionId;

  TacheCreationDTO({
    required this.titre,
    required this.description,
    required this.priorite,
    required this.dateCreation,
    required this.userId,
    this.missionId,
  });

  Map<String, dynamic> toJson() => {
  'titre': titre,
  'description': description,
  'priorite': priorite.index,
  'userId': userId,
  'missionId': missionId,
  'dateCreation': dateCreation.toIso8601String(),
};

}
