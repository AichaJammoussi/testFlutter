import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';

class TacheCreationDTO {
  final String titre;
  final String description;
  final PrioriteTache priorite;
  final DateTime dateCreation;
  final String userId;
  final int? idMission;
    final double budget;


  TacheCreationDTO({
    required this.titre,
    required this.description,
    required this.priorite,
    required this.dateCreation,
    required this.userId,
    this.idMission,
    required this.budget,
  });

  Map<String, dynamic> toJson() => {
    'Titre': titre,
    'Description': description,
    'Priorite': priorite.index,
    'UserId': userId,
    'IdMission': idMission,
    'Budget' : budget,
  };
}
