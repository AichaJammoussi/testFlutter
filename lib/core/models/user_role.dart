class UserWithRoles {
  final String userId;
  final String email;
  final List<String> roles;

  UserWithRoles({
    required this.userId,
    required this.email,
    required this.roles,
  });

  factory UserWithRoles.fromJson(Map<String, dynamic> json) {
    return UserWithRoles(
      userId: json['userId'],
      email: json['email'],
      roles: List<String>.from(json['roles']),
    );
  }
}
