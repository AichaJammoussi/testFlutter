class UpdateProfileDto {
  final String? nom;
  final String? prenom;
  final String? phoneNumber;

  UpdateProfileDto({
    this.nom,
    this.prenom,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        if (nom != null) 'nom': nom,
        if (prenom != null) 'prenom': prenom,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };
}