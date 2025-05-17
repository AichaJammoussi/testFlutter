class NotificationCreateDTO {
  final String userId;
  final String title;
  final String message;

  NotificationCreateDTO({
    required this.userId,
    required this.title,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'message': message,
      };
}
