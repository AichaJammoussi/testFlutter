class User {
  final String id;
  final String email;
  final String? name;
  final String? profilePicture;
    final List<String> roles;
  final String? photoDeProfil;



  User({
    required this.id,
    required this.email,
    this.name,
    this.profilePicture,
    required this.roles,
    this.photoDeProfil,

  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'],
      email: json['email'],
      name: json['name'],
      photoDeProfil: json['photoDeProfil'], roles: [],
    );
  }
    bool get isAdmin => roles.contains('Admin');

}