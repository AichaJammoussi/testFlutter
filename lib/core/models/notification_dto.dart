// models/notification_dto.dart
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
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
