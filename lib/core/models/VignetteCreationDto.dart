class VignetteCreationDto {
  final int VehiculeId;
  final double Montant;
  final DateTime DatePaiement;
  final int Annee;

  VignetteCreationDto({
    required this.VehiculeId,
    required this.Montant,
    required this.DatePaiement,
    required this.Annee,
  });

  Map<String, dynamic> toJson() => {
    'VehiculeId': VehiculeId,
    'Annee': Annee,

    'Montant': Montant,
    'DatePaiement': DatePaiement.toIso8601String(),
  };
}
