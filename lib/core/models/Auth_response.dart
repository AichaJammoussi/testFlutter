class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final String? refreshToken;
  final DateTime? expiration;
  final String? userId;
  final String? userName;
  final String? email;
  final List<String>? roles;
  final String? photoDeProfil;
  final Map<String, dynamic>? errors;
  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
    this.expiration,
    this.userId,
    this.userName,
    this.email,
    this.roles,
    this.photoDeProfil,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Gestion flexible des erreurs
    Map<String, dynamic>? errors;
    if (json['errors'] != null) {
      errors = {};
      (json['errors'] as Map<String, dynamic>).forEach((key, value) {
        if (value is String) {
          errors![key] = value;
        } else if (value is List) {
          errors![key] = value.isNotEmpty ? value[0] : '';
        }
      });
    }
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      token: json['token'],
      refreshToken: json['refreshToken'],
      expiration:
          json['expiration'] != null
              ? DateTime.parse(json['expiration'])
              : null,
      userId: json['userId'],
      userName: json['userName'],
      email: json['email'],
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
      photoDeProfil: json['photoDeProfil'],
      errors: errors,
    );
  }
}
