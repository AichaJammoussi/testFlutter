import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';

class TacheUpdateDTO {
  final String titre;
  final String description;
  final PrioriteTache priorite;
  final double budget;
  final String userId;
  final StatutTache statut;

  TacheUpdateDTO({
    required this.titre,
    required this.description,
    required this.priorite,
    required this.budget,
    required this.statut,

    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'titre': titre,
    'description': description,
    'priorite': priorite.index,
    'budget': budget,
    'userId': userId,
    'statut': statut.index,
  };
}
