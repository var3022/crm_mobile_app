import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_response.dart';
import 'api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  final SecureStorageService _secureStorage = SecureStorageService();
  final Uuid _uuid = const Uuid();

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Attach Request ID
        options.headers['X-Request-ID'] = _uuid.v4();

        // Attach Authorization Token if available
        final accessToken = await _secureStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }

        // Attach Tenant ID if available (for multi-tenant support)
        final tenantId = await _secureStorage.getTenantId();
        if (tenantId != null) {
          options.headers['X-Tenant-ID'] = tenantId;
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  /// Sends a GET request and returns a parsed [ApiResponse].
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJsonT,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _parseResponse<T>(response, fromJsonT);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sends a POST request and returns a parsed [ApiResponse].
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJsonT,
  }) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return _parseResponse<T>(response, fromJsonT);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sends a PATCH request and returns a parsed [ApiResponse].
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJsonT,
  }) async {
    try {
      final response = await _dio.patch(path, data: data, queryParameters: queryParameters);
      return _parseResponse<T>(response, fromJsonT);
    } catch (e) {
      throw _handleError(e);
    }
  }

  ApiResponse<T> _parseResponse<T>(Response response, T Function(dynamic json)? fromJsonT) {
    if (response.data is Map<String, dynamic>) {
      final dataMap = response.data as Map<String, dynamic>;
      final isSuccess = dataMap['success'] == true;
      if (isSuccess) {
        return ApiResponse<T>.fromJson(dataMap, fromJsonT);
      } else {
        // API returned success: false but with HTTP 200/2xx (rare, but possible)
        throw ApiException.fromJson(dataMap['error'] ?? {}, statusCode: response.statusCode);
      }
    }
    // Fallback if data is not a map
    throw ApiException(
      code: 'INVALID_RESPONSE',
      message: 'The server returned an invalid response format.',
      statusCode: response.statusCode,
    );
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data is Map<String, dynamic>) {
        final dataMap = error.response!.data as Map<String, dynamic>;
        if (dataMap.containsKey('error')) {
          return ApiException.fromJson(dataMap['error'], statusCode: error.response?.statusCode);
        }
      }
      // Network or connection errors
      return ApiException(
        code: _mapDioErrorToCode(error.type),
        message: error.message ?? 'A network error occurred.',
        statusCode: error.response?.statusCode,
      );
    }
    return ApiException(code: 'UNKNOWN_ERROR', message: error.toString());
  }

  String _mapDioErrorToCode(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'TIMEOUT';
      case DioExceptionType.connectionError:
        return 'CONNECTION_ERROR';
      default:
        return 'NETWORK_ERROR';
    }
  }
}
