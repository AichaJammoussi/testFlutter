class NotificationDto {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] is bool
          ? json['isRead']
          : (json['isRead'].toString().toLowerCase() == 'true'),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };
}
