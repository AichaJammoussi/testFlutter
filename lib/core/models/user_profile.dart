class UserProfile {
  final String userId;
  final String email;
  final String nom;
  final String prenom;
  final String phoneNumber;
  final String? profilePictureUrl;

  UserProfile({
    required this.userId,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.phoneNumber,
    this.profilePictureUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      phoneNumber: json['phoneNumber'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  String get fullName => '$prenom $nom';
}