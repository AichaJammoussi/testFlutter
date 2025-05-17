class TacheUpdateDTO {
  final String? titre;
  final String? description;
  final int? priorite;

  TacheUpdateDTO({this.titre, this.description, this.priorite});

  Map<String, dynamic> toJson() => {
        if (titre != null) 'titre': titre,
        if (description != null) 'description': description,
        if (priorite != null) 'priorite': priorite,
      };
}
