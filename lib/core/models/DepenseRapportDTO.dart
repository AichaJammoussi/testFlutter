import 'package:testfront/core/models/MoyenPaiement.dart';

class DepenseRapportDTO {
  final int depenseId;
  final String typeDepense;
  final String description;
  final double montant;
  final String moyenPaiement; // champ final toujours String (label humain)
  final String? justification;

  DepenseRapportDTO({
    required this.depenseId,
    required this.typeDepense,
    required this.description,
    required this.montant,
    required this.moyenPaiement,
    this.justification,
  });

  factory DepenseRapportDTO.fromJson(Map<String, dynamic> json) {
    final int mpIndex = json['moyenPaiement'];
    final MoyenPaiement mpEnum = MoyenPaiement.fromInt(mpIndex);

    return DepenseRapportDTO(
      depenseId: json['depenseId'],
      typeDepense: json['typeDepense'],
      description: json['description'],
      montant: (json['montant'] ?? 0).toDouble(),
      moyenPaiement: mpEnum.label, // conversion vers un label lisible
      justification: json['justification'],
    );
  }
}
