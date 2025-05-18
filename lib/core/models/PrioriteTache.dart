enum PrioriteTache {
  Basse,
  Moyenne,
  Haute;

  /// Convertit un entier reçu depuis l'API vers une valeur de l'enum
  static PrioriteTache fromInt(int value) {
    return PrioriteTache.values[value];
  }

  /// Pour l'envoyer en JSON sous forme de nom (optionnel)
  String toJson() => name;

  /// Retourne une string plus lisible pour l'affichage
  String asString() {
    switch (this) {
      case PrioriteTache.Basse:
        return "Basse";
      case PrioriteTache.Moyenne:
        return "Moyenne";
      case PrioriteTache.Haute:
        return "Haute";
    }
  }
}
