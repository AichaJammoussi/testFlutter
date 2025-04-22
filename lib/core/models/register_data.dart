class RegisterData {
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;

  RegisterData({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'phoneNumber': phoneNumber,
      };
}