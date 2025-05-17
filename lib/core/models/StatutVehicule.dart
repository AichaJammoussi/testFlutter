enum StatutVehicule {
  Disponible,
  EnMission,
  EnMaintenance,
  HorsService;

  static StatutVehicule fromString(String value) {
    switch (value) {
      case 'Disponible':
        return StatutVehicule.Disponible;
      case 'EnMission':
        return StatutVehicule.EnMission;
      case 'EnMaintenance':
        return StatutVehicule.EnMaintenance;
      case 'HorsService':
        return StatutVehicule.HorsService;
      default:
        throw Exception('StatutVehicule inconnu: $value');
    }
  }

  String toJson() => name;
}
