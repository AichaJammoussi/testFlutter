class UserRolesDTO {
  final String userId;
  final String userName;
  final String email;
  final List<String> roles;

  UserRolesDTO({
    required this.userId,
    required this.userName,
    required this.email,
    required this.roles,
  });

  factory UserRolesDTO.fromJson(Map<String, dynamic> json) {
    return UserRolesDTO(
      userId: json['userId'],
      userName: json['userName'],
      email: json['email'],
      roles: List<String>.from(json['roles']),
    );
  }
}