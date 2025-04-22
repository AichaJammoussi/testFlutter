class User {
  final String id;
  final String email;
  final String? name;
  final String? profilePicture;
    final List<String> roles;


  User({
    required this.id,
    required this.email,
    this.name,
    this.profilePicture,
    required this.roles
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'],
      email: json['email'],
      name: json['name'],
      profilePicture: json['profilePicture'], roles: [],
    );
  }
    bool get isAdmin => roles.contains('Admin');

}