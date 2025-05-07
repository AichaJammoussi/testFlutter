class RoleDTO {
  final String id;
  final String name;

  RoleDTO({required this.id, required this.name});

  factory RoleDTO.fromJson(Map<String, dynamic> json) {
    return RoleDTO(
      id: json['id'],
      name: json['name'],
    );
  }
}