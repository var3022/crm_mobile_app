/// A generic wrapper for parsed API responses based on the JSend envelope.
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;
  final String timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic json)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : null,
      meta: json['meta'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }
}
