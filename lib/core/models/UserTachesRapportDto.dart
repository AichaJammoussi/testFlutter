import 'package:testfront/core/models/TacheRapportDto.dart';

class UserTachesRapportDto {
  final String userId;
  final String nomComplet;
  final bool estValide;
  final List<TacheRapportDto> taches;

  UserTachesRapportDto({
    required this.userId,
    required this.nomComplet,
    required this.estValide,
    required this.taches,
  });

  factory UserTachesRapportDto.fromJson(Map<String, dynamic> json) {
    return UserTachesRapportDto(
      userId: json['userId'],
      nomComplet: json['nomComplet'],
      estValide: json['estValide'] ?? false,
      taches: (json['taches'] as List<dynamic>)
          .map((e) => TacheRapportDto.fromJson(e))
          .toList(),
    );
  }
}