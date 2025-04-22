class AuthResponse {
  final bool success;
  final String message;
  final String token;
  final String refreshToken;
  final DateTime? expiration;
  final String userId;
  final String userName;
  final String email;
  final List<String> roles;

  AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.refreshToken,
    this.expiration,
    required this.userId,
    required this.userName,
    required this.email,
    required this.roles,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiration: json['expiration'] != null 
          ? DateTime.parse(json['expiration']) 
          : null,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}