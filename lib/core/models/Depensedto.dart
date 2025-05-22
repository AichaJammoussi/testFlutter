import 'package:testfront/core/models/MoyenPaiement.dart';
import 'package:testfront/core/models/TypeDepense.dart';

class DepenseDTO {
  final int depenseId;
  final TypeDepense typeDepense;
  final String description;
  final double montant;
  final MoyenPaiement moyenPaiement;
  final String justification;
  final int tacheId;

  DepenseDTO({
    required this.depenseId,
    required this.typeDepense,
    required this.description,
    required this.montant,
    required this.moyenPaiement,
    required this.justification,
    required this.tacheId,
  });

  factory DepenseDTO.fromJson(Map<String, dynamic> json) {
    return DepenseDTO(
      depenseId: json['depenseId'],
      typeDepense: TypeDepense.fromInt(json['typeDepense']),
      description: json['description'],
      montant: (json['montant'] as num).toDouble(),
      moyenPaiement: MoyenPaiement.fromInt(json['moyenPaiement']),

      justification: json['justification'] ?? '',
      tacheId: json['tacheId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depenseId': depenseId,
      'typeDepense': typeDepense.index,
      'description': description,
      'montant': montant,
      'moyenPaiement': moyenPaiement.index,
      'justification': justification,
      'tacheId': tacheId,
    };
  }
}
