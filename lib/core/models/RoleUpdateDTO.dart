class RoleUpdateDTO {
  final String id;
  final String newName;

  RoleUpdateDTO({required this.id, required this.newName});

  Map<String, dynamic> toJson() => {
        'id': id,
        'newRoleName': newName,
      };
}