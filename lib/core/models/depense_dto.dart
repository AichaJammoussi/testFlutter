class DepenseDTO {
  final String type;
  final double montant;
  final String description;

  DepenseDTO({
    required this.type,
    required this.montant,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'montant': montant,
    'description': description,
  };

  factory DepenseDTO.fromJson(Map<String, dynamic> json) {
    return DepenseDTO(
      type: json['type'],
      montant: json['montant'].toDouble(),
      description: json['description'],
    );
  }
}