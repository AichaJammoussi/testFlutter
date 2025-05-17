enum PrioriteTache {
  Basse,
  Moyenne,
  Haute;
  //  Urgente;

  static PrioriteTache fromInt(int value) {
    return PrioriteTache.values[value];
  }

  String toJson() => name;

  String asString() {
    switch (this) {
      case PrioriteTache.Basse:
        return "Basse";
      case PrioriteTache.Moyenne:
        return "Moyenne";
      case PrioriteTache.Haute:
        return "Haute";
      /* case PrioriteTache.Urgente:
        return "Urgente";*/
    }
  }
}
