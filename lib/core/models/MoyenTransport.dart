enum MoyenTransport {
  Vehicule,
  Autre;

  static MoyenTransport fromInt(int value) {
    return MoyenTransport.values[value];
  }

  int toInt() => index;

  String toJson() => name;

  static String asString(MoyenTransport type) {
    switch (type) {
      case MoyenTransport.Vehicule:
        return 'Vehicule';
      case MoyenTransport.Autre:
        return 'Autre';
    }
  }

  static int fromString(String type) {
    switch (type.toLowerCase()) {
      case 'véhicule':
        return MoyenTransport.Vehicule.index;
      case 'autre':
        return MoyenTransport.Autre.index;
      default:
        throw ArgumentError('Type de moyen de transport invalide : $type');
    }
  }
}
