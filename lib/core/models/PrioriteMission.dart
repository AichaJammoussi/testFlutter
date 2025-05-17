enum PrioriteMission {
  Basse,
  Moyenne,
  Haute,
  Urgente;

  static PrioriteMission fromInt(int value) {
    return PrioriteMission.values[value];
  }

  String toJson() => name;

  String asString() {
    switch (this) {
      case PrioriteMission.Basse:
        return "Basse";
      case PrioriteMission.Moyenne:
        return "Moyenne";
      case PrioriteMission.Haute:
        return "Haute";
      case PrioriteMission.Urgente:
        return "Urgente";
    }
  }
}
