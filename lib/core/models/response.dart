class ResponseDTO<T> {
  final bool success;
  final String? message;
  final T? data;

  ResponseDTO({
    required this.success,
    this.message,
    this.data,
  });

  factory ResponseDTO.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ResponseDTO<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : null,
    );
  }
}