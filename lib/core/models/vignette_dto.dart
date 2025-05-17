class VignetteDto {
  final int VignetteId;
  final int Annee;
  final DateTime DatePaiement;
  final DateTime DateLimitePaiement;

  final double Montant;
  final int VehiculeId;
  final bool isValid;

  VignetteDto({
    required this.VignetteId,
    required this.Annee,
    required this.DatePaiement,
    required this.Montant,
    required this.VehiculeId,
    required this.DateLimitePaiement,
    required this.isValid,
  });

  factory VignetteDto.fromJson(Map<String, dynamic> json) {
    return VignetteDto(
      VignetteId: json['vignetteId'],
      Annee: json['annee'],
      DatePaiement: DateTime.parse(json['datePaiement']),
      Montant: json['montant'].toDouble(),
      VehiculeId: json['vehiculeId'],
      DateLimitePaiement: DateTime.parse(json['dateLimitePaiement']),
      isValid: json['isValid'],
    );
  }
}
