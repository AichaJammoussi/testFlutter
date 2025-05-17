class UserDTO {
  final String id;
  final String nom;
  final String prenom;
  final String userName;

  UserDTO({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.userName,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'userName': userName,
  };
}
