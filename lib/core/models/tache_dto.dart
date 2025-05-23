import 'package:testfront/core/models/Depensedto.dart';
import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';

class TacheDTO {
  final int tacheId;
  final String titre;
  final String description;
  final StatutTache? statutTache;
  final PrioriteTache? priorite;
  final DateTime dateCreation;
  final DateTime? dateRealisation;
  final String userId;
  final String? userName;
  final int? missionId;
  final String? missionTitre;
  final List<DepenseDTO>? depense;
  final double budget;
  final double? depenses;

  TacheDTO({
    required this.tacheId,
    required this.titre,
    required this.description,
    required this.statutTache,
    required this.priorite,
    required this.dateCreation,
    this.dateRealisation,
    required this.userId,
    this.userName,
    this.missionId,
    this.missionTitre,
    this.depense,
    required this.budget,
    this.depenses,
  });

  factory TacheDTO.fromJson(Map<String, dynamic> json) {
    return TacheDTO(
      tacheId: json['tacheId'],
      titre: json['titre'],
      description: json['description'],
      statutTache:
          json['statutTache'] != null
              ? StatutTache.fromInt(json['statutTache'])
              : null,
      priorite:
          json['priorite'] != null
              ? PrioriteTache.fromInt(json['priorite'])
              : null,
      dateCreation: DateTime.parse(json['dateCreation']),
      dateRealisation:
          json['dateRealisation'] != null
              ? DateTime.parse(json['dateRealisation'])
              : null,
      userId: json['userId'],
      userName: json['userName'],
      missionId: json['missionId'],
      missionTitre: json['missionTitre'],
      depense:
          json['depense'] != null
              ? List<DepenseDTO>.from(
                json['depense'].map((x) => DepenseDTO.fromJson(x)),
              )
              : null,
      budget: json['budget'],
      depenses: json['depenses'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tacheId': tacheId,
      'titre': titre,
      'description': description,
      'statutTache': statutTache?.index,
      'priorite': priorite?.index,
      'dateCreation': dateCreation.toIso8601String(),
      'dateRealisation': dateRealisation?.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'missionId': missionId,
      'missionTitre': missionTitre,
      'depense': depense?.map((x) => x.toJson()).toList(),
      'budget': budget,
      'depenses':depenses,
    };
  }
}
