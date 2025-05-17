class VehiculeMissionDTO {
  final int vehiculeeId;
  final String marque;
  final String modele;
  final String immatriculation;

  VehiculeMissionDTO({
    required this.vehiculeeId,
    required this.marque,
    required this.modele,
    required this.immatriculation,
  });

  factory VehiculeMissionDTO.fromJson(Map<String, dynamic> json) {
    return VehiculeMissionDTO(
      vehiculeeId: json['vehiculeeId'],
      marque: json['marque'],
      modele: json['modele'],
      immatriculation: json['immatriculation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehiculeeId': vehiculeeId,
      'marque': marque,
      'modele': modele,
      'immatriculation': immatriculation,
    };
  }
}
