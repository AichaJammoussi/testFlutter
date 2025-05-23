class DepenseRapportDTO {
  final int depenseId;
  final String typeDepense;
  final String description;
  final double montant;
  final String moyenPaiement;
  final String justification;

  DepenseRapportDTO({
    required this.depenseId,
    required this.typeDepense,
    required this.description,
    required this.montant,
    required this.moyenPaiement,
    required this.justification,
  });

  factory DepenseRapportDTO.fromJson(Map<String, dynamic> json) {
    return DepenseRapportDTO(
      depenseId: json['depenseId'],
      typeDepense: json['typeDepense'],
      description: json['description'],
      montant: (json['montant'] ?? 0).toDouble(),
      moyenPaiement: json['moyenPaiement'],
      justification: json['justification'],
    );
  }
}
