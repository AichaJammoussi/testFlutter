class UserRoleAssignmentDTO {
  final String userId;
  final List<String> roles;

  UserRoleAssignmentDTO({required this.userId, required this.roles});

  factory UserRoleAssignmentDTO.fromJson(Map<String, dynamic> json) {
    return UserRoleAssignmentDTO(
      userId: json['userId'],
      roles: List<String>.from(json['roles']),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'roles': roles,
      };
}