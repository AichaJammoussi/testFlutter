class EmployeMissionRapportDto {
  final String userId;
  final String nomComplet;

  EmployeMissionRapportDto({required this.userId, required this.nomComplet});

  factory EmployeMissionRapportDto.fromJson(Map<String, dynamic> json) {
    return EmployeMissionRapportDto(
      userId: json['userId'],
      nomComplet: json['nomComplet'],
    );
  }
}