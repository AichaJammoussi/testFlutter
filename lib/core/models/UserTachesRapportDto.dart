import 'package:testfront/core/models/TacheRapportDto.dart';

class UserTachesRapportDto {
  final String userId;
  final String nomComplet;
  final List<TacheRapportDto> taches;
  final double montantRemboursement;

  UserTachesRapportDto({
    required this.userId,
    required this.nomComplet,
    required this.taches,
    required this.montantRemboursement,
  });

  factory UserTachesRapportDto.fromJson(Map<String, dynamic> json) {
    return UserTachesRapportDto(
      userId: json['userId'],
      nomComplet: json['nomComplet'],
      taches:
          (json['taches'] as List<dynamic>)
              .map((e) => TacheRapportDto.fromJson(e))
              .toList(),
      montantRemboursement: (json['montantRemboursement'] as num).toDouble(),
    );
  }
}
