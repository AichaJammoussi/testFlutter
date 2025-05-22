enum MoyenPaiement {
  ESPECE,
  CARTEBANCAIRE,
  VIREMENTBANCAIRE,
  CHEQUE,
  PAIMENETMOBILE,
  AUTRE;

  static MoyenPaiement fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ESPECE':
        return MoyenPaiement.ESPECE;
      case 'CARTE_BANCAIRE':
        return MoyenPaiement.CARTEBANCAIRE;
      case 'CHEQUE':
        return MoyenPaiement.CHEQUE;
      case 'VIREMENTBANCAIRE':
        return MoyenPaiement.VIREMENTBANCAIRE;
      case 'PAIMENETMOBILE':
        return MoyenPaiement.PAIMENETMOBILE;
      case 'AUTRE':
        return MoyenPaiement.AUTRE;
      default:
        throw Exception('MoyenPaiement inconnu: $value');
    }
  }


  static MoyenPaiement fromInt(int value) {
    return MoyenPaiement.values[value];
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case MoyenPaiement.ESPECE:
        return 'Espèce';
      case MoyenPaiement.CARTEBANCAIRE:
        return 'Carte bancaire';

      case MoyenPaiement.VIREMENTBANCAIRE:
        return 'Virement bancaire';
      case MoyenPaiement.CHEQUE:
        return 'Chèque';
      case MoyenPaiement.PAIMENETMOBILE:
        return 'Paiment Mobile';
      case MoyenPaiement.AUTRE:
        return 'Autre';
    }
  }
}
