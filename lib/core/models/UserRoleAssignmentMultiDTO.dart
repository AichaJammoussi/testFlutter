class UserRoleAssignmentMultiDTO {
  List<String> userIds;
  List<String> roles;

  UserRoleAssignmentMultiDTO({required this.userIds, required this.roles});

  factory UserRoleAssignmentMultiDTO.fromJson(Map<String, dynamic> json) {
    return UserRoleAssignmentMultiDTO(
      userIds: List<String>.from(json['userIds']),
      roles: List<String>.from(json['roles']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userIds': userIds,
      'roles': roles,
    };
  }
}
