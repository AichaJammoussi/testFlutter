import 'package:testfront/core/models/PrioriteTache.dart';
import 'package:testfront/core/models/StatusTache.dart';
import 'package:testfront/core/models/depense_dto.dart';

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
  final List<DepenseDTO>? depenses;

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
    this.depenses,
  });

  factory TacheDTO.fromJson(Map<String, dynamic> json) {
    return TacheDTO(
      tacheId: json['tacheId'],
      titre: json['titre'],
      description: json['description'],
      statutTache: StatutTache.fromInt(json['statut']),
      priorite: PrioriteTache.fromInt(json['priorite']),
      dateCreation: DateTime.parse(json['dateCreation']),
      dateRealisation:
          json['dateRealisation'] != null
              ? DateTime.parse(json['dateRealisation'])
              : null,
      userId: json['userId'],
      userName: json['userName'],
      missionId: json['missionId'],
      missionTitre: json['missionTitre'],
      depenses:
          json['depenses'] != null
              ? List<DepenseDTO>.from(
                json['depenses'].map((x) => DepenseDTO.fromJson(x)),
              )
              : null,
    );
  }

  get statut => null;

  get userPrenom => null;

  Map<String, dynamic> toJson() {
    return {
      'tacheId': tacheId,
      'titre': titre,
      'description': description,
      'statutTache': statutTache.toString().split('.').last,
      'priorite': priorite?.index,
      'dateCreation': dateCreation.toIso8601String(),
      'dateRealisation': dateRealisation?.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'missionId': missionId,
      'missionTitre': missionTitre,
      'depenses': depenses?.map((x) => x.toJson()).toList(),
    };
  }
}
