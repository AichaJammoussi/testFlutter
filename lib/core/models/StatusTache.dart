enum StatutTache {
  PLANIFIEE,
  ENCOURS,
  TERMINEE,
  ANNULEE;

  static StatutTache fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PLANIFIEE':
        return StatutTache.PLANIFIEE;
      case 'EN_COURS':
        return StatutTache.ENCOURS;
      case 'TERMINEE':
        return StatutTache.TERMINEE;
      case 'ANNULEE':
        return StatutTache.ANNULEE;
      default:
        throw Exception('StatutMission inconnu: $value');
    }
  }

  static StatutTache fromInt(int value) {
    return StatutTache.values[value];
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case StatutTache.PLANIFIEE:
        return 'Planifiée';
      case StatutTache.ENCOURS:
        return 'En cours';
      case StatutTache.TERMINEE:
        return 'Terminée';
      case StatutTache.ANNULEE:
        return 'Annulée';
    }
  }
}
