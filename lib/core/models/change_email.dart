class ChangeEmailRequestDTO {
  final String newEmail;
  final String currentPassword;

  ChangeEmailRequestDTO({
    required this.newEmail,
    required this.currentPassword,
  });

  Map<String, dynamic> toJson() => {
    'newEmail': newEmail,
    'currentPassword': currentPassword,
  };
}