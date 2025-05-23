import 'package:testfront/core/models/DepenseRapportDTO.dart';

class TacheRapportDto {
  final String titre;
  final String? dateRealisation;
  final double budgetTache;
  final double depensesTotales;
  final List<DepenseRapportDTO> depenses;

  TacheRapportDto({
    required this.titre,
    this.dateRealisation,
    required this.budgetTache,
    required this.depensesTotales,
    required this.depenses,
  });

  factory TacheRapportDto.fromJson(Map<String, dynamic> json) {
    return TacheRapportDto(
      titre: json['titre'],
      dateRealisation: json['dateRealisation'],
      budgetTache: (json['budgetTache'] ?? 0).toDouble(),
      depensesTotales: (json['depensesTotales'] ?? 0).toDouble(),
      depenses: (json['depenses'] as List<dynamic>)
          .map((e) => DepenseRapportDTO.fromJson(e))
          .toList(),
    );
  }
}