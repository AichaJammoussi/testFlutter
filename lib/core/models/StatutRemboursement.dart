enum StatutRemboursement {
  ENATTENTE,
  APPROUVE,
  REJETE;

  static StatutRemboursement fromString(String value) {
    switch (value) {
      case 'EnAttente':
        return StatutRemboursement.ENATTENTE;
      case 'Approuve':
        return StatutRemboursement.APPROUVE;
      case 'Rejete':
        return StatutRemboursement.REJETE;
      default:
        throw Exception('StatutRemboursement inconnu: $value');
    }
  }

  static StatutRemboursement fromInt(int value) {
    return StatutRemboursement.values[value];
  }

  String toJson() => name;
}
