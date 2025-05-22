import 'dart:io';

import 'package:testfront/core/models/MoyenPaiement.dart';
import 'package:testfront/core/models/TypeDepense.dart';

class DepenseCreationDTO {
  final TypeDepense typeDepense;
  final String description;
  final double montant;
  final MoyenPaiement moyenPaiement;
  final File? justification;
  final int tacheId;

  DepenseCreationDTO({
    required this.typeDepense,
    required this.description,
    required this.montant,
    required this.moyenPaiement,
    this.justification,
    required this.tacheId,
  });

  factory DepenseCreationDTO.fromJson(Map<String, dynamic> json) {
    return DepenseCreationDTO(
      typeDepense: TypeDepense.fromString(json['typeDepense']),
      description: json['description'],
      montant: (json['montant'] as num).toDouble(),
      moyenPaiement: MoyenPaiement.fromString(json['moyenPaiement']),
      justification: json['justification'] ?? '',
      tacheId: json['tacheId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TypeDepense': typeDepense.index,
      'Description': description,
      'Montant': montant,
      'MoyenPaiement': moyenPaiement.index,
      'TacheId': tacheId,
    };
  }
}
