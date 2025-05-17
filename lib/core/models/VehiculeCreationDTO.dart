class VehiculeCreationDTO {
  final String marque;
  final String modele;
  final String immatriculation;
  final int anneeMiseEnCirculation;
  final int kilometrage;
  final int statut; // << NOTEZ que c'est bien un int ici

  VehiculeCreationDTO({
    required this.marque,
    required this.modele,
    required this.immatriculation,
    required this.anneeMiseEnCirculation,
    required this.kilometrage,
    required this.statut,
  });

  Map<String, dynamic> toJson() => {
    'Marque': marque,
    'Modele': modele,
    'Immatriculation': immatriculation,
    'AnneeMiseEnCirculation': anneeMiseEnCirculation,
    'Kilometrage': kilometrage,
    'Statut': statut,
  };
}
