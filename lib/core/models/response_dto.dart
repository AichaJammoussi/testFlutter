class ResponseDTO<T> {
  final bool success;
  final String message;
  final T data;
  final Map<String, dynamic>? errors;

  ResponseDTO({
    required this.success,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ResponseDTO.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ResponseDTO(
      success: json['success'],
      message: json['message'],
      data: fromJsonT(json['data']),
      errors: (json['errors'] as Map?)?.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      ),
    );
  }
}
