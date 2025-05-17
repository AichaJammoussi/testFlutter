enum StatutMission {
  PLANIFIEE,
  EN_COURS,
  TERMINEE,
  ANNULEE;

  static StatutMission fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PLANIFIEE':
        return StatutMission.PLANIFIEE;
      case 'EN_COURS':
        return StatutMission.EN_COURS;
      case 'TERMINEE':
        return StatutMission.TERMINEE;
      case 'ANNULEE':
        return StatutMission.ANNULEE;
      default:
        throw Exception('StatutMission inconnu: $value');
    }
  }

  static StatutMission fromInt(int value) {
    return StatutMission.values[value];
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case StatutMission.PLANIFIEE:
        return 'Planifiée';
      case StatutMission.EN_COURS:
        return 'En cours';
      case StatutMission.TERMINEE:
        return 'Terminée';
      case StatutMission.ANNULEE:
        return 'Annulée';
    }
  }
}
