class ChangePasswordDTO {
  final String currentPassword;
  final String newPassword;

  ChangePasswordDTO({required this.currentPassword, required this.newPassword});

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}
