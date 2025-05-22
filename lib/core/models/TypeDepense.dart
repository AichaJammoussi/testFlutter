enum TypeDepense {
  TRANSPORT,
  LOGEMENT,
  Nourriture,
  MATERIEL,
  COMMUNICATION,
  DIVERS;

  static TypeDepense fromString(String value) {
    switch (value.toUpperCase()) {
      case 'TRANSPORT':
        return TypeDepense.TRANSPORT;
      case 'LOGEMENT':
        return TypeDepense.LOGEMENT;
      case 'Nourriture':
        return TypeDepense.Nourriture;
      case 'MATERIEL':
        return TypeDepense.MATERIEL;
      case 'COMMUNICATION':
        return TypeDepense.COMMUNICATION;
      case 'DIVERS':
        return TypeDepense.DIVERS;
      default:
        throw Exception('TypeDepense inconnu: $value');
    }
  }

  static TypeDepense fromInt(int value) {
    return TypeDepense.values[value];
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case TypeDepense.TRANSPORT:
        return 'Transport';
      case TypeDepense.LOGEMENT:
        return 'Logement';
      case TypeDepense.Nourriture:
        return 'Repas';
      case TypeDepense.MATERIEL:
        return 'Matériel';
      case TypeDepense.COMMUNICATION:
        return 'Cpmmunication';
      case TypeDepense.DIVERS:
        return 'Divers';
    }
  }
}
