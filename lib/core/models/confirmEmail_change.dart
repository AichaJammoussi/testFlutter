class ConfirmEmailChangeDTO {
  final String userId;
  final String newEmail;
  final String token;

  ConfirmEmailChangeDTO({
    required this.userId,
    required this.newEmail,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'newEmail': newEmail,
    'token': token,
  };
}