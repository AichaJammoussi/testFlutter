class MissionCreationDTO {
  final String titre;
  final String description;
  final DateTime dateDebutPrevue;
  final DateTime dateFinPrevue;
  final int priorite; // enum as int
  final int typeMoyenTransport; // enum as int
  final List<int> vehiculeeIds;

  MissionCreationDTO({
    required this.titre,
    required this.description,
    required this.dateDebutPrevue,
    required this.dateFinPrevue,
    required this.priorite,
    required this.typeMoyenTransport,
    required this.vehiculeeIds,
  });

  Map<String, dynamic> toJson() => {
    'Titre': titre,
    'Description': description,
    'DateDebutPrevue': dateDebutPrevue.toIso8601String(),
    'DateFinPrevue': dateFinPrevue.toIso8601String(),
    'Priorite': priorite,
    'TypeMoyenTransport': typeMoyenTransport,
    'VehiculeeIds': vehiculeeIds,
  };
}
