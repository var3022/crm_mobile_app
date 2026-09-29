class ApiException implements Exception {
  final String code;
  final String message;
  final List<dynamic>? details;
  final int? statusCode;

  ApiException({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
  });

  factory ApiException.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return ApiException(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred.',
      details: json['details'],
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiException: [$code] $message';
  }
}
