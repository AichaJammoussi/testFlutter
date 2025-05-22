import 'package:testfront/core/models/StatutRemboursement.dart';

class RemboursementDTO {
  final int remboursementId;
  final String employeId;
  final int missionId;
  final double montant;
   StatutRemboursement statut;
  final DateTime dateDemande;
  final DateTime? dateValidation;

  RemboursementDTO({
    required this.remboursementId,
    required this.employeId,
    required this.missionId,
    required this.montant,
    required this.statut,
    required this.dateDemande,
    this.dateValidation,
  });
  factory RemboursementDTO.fromJson(Map<String, dynamic> json) {
    return RemboursementDTO(
      remboursementId:
          json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      employeId: json['employeId'] ?? '',
      missionId:
          json['missionId'] is int
              ? json['missionId']
              : int.parse(json['missionId'].toString()),
      montant: (json['montant'] as num).toDouble(),
      statut: StatutRemboursement.fromInt(
        json['statut'] is int
            ? json['statut']
            : int.parse(json['statut'].toString()),
      ),
      dateDemande: DateTime.parse(json['dateDemande']),
      dateValidation:
          (json['dateValidation'] != null &&
                  json['dateValidation'].toString().isNotEmpty)
              ? DateTime.tryParse(json['dateValidation'].toString())
              : null,
    );
  }
}
