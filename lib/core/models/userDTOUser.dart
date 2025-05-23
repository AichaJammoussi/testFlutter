class Userdtouser{
  final String userId;
  final String email;
  final String nom;
  final String prenom;
  final String phoneNumber;
  final String? photoDeProfil;

  Userdtouser({
    required this.userId,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.phoneNumber,
    this.photoDeProfil,
  });

  factory Userdtouser.fromJson(Map<String, dynamic> json) {
    return Userdtouser(
      userId: json['userId'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      phoneNumber: json['phoneNumber'],
      photoDeProfil: json['photoDeProfil'],
    );
  }
}
