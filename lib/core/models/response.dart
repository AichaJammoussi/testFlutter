class ResponseDTO<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, String>? errors; // 👈 Ajout du champ errors

  ResponseDTO({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ResponseDTO.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ResponseDTO<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] != null
          ? Map<String, String>.from(json['errors'])
          : null,
    );
  }
}
