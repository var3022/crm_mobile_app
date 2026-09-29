import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_user.dart';
import '../models/login_response.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _secureStorage = SecureStorageService();

  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  /// Logs in the user and securely stores tokens.
  Future<LoginResponse> login(String email, String password) async {
    final response = await _apiClient.post<LoginResponse>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      fromJsonT: (json) => LoginResponse.fromJson(json),
    );

    if (response.data != null) {
      final tokens = response.data!.tokens;
      await _secureStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await _secureStorage.saveTenantId(response.data!.tenant.id);
    }
    
    return response.data!;
  }

  /// Registers a new tenant and admin user, and securely stores tokens.
  Future<LoginResponse> register({
    required String tenantName,
    required String subdomain,
    required String adminEmail,
    required String adminPassword,
    required String adminFirstName,
    required String adminLastName,
  }) async {
    final response = await _apiClient.post<LoginResponse>(
      '/auth/register',
      data: {
        'tenantName': tenantName,
        'subdomain': subdomain,
        'adminEmail': adminEmail,
        'adminPassword': adminPassword,
        'adminFirstName': adminFirstName,
        'adminLastName': adminLastName,
      },
      fromJsonT: (json) => LoginResponse.fromJson(json),
    );

    if (response.data != null) {
      final tokens = response.data!.tokens;
      await _secureStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await _secureStorage.saveTenantId(response.data!.tenant.id);
    }
    
    return response.data!;
  }

  /// Logs out the user and clears secure storage.
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // If the logout API fails (e.g., token already invalid), we should still clear local state.
    } finally {
      await _secureStorage.clearAll();
    }
  }

  /// Retrieves the current authenticated user's profile.
  Future<AuthUser> getCurrentUser() async {
    final response = await _apiClient.get<AuthUser>(
      '/auth/me',
      fromJsonT: (json) => AuthUser.fromJson(json),
    );
    return response.data!;
  }

  /// Resends the email verification link.
  Future<void> resendVerificationEmail(String email) async {
    await _apiClient.post('/auth/resend-verification', data: {'email': email});
  }

  /// Requests a password reset email.
  Future<void> forgotPassword(String email) async {
    await _apiClient.post('/auth/forgot-password', data: {'email': email});
  }

  /// Resets the password using a token (OTP) and new password.
  Future<void> resetPassword({required String token, required String newPassword}) async {
    await _apiClient.post('/auth/reset-password', data: {
      'token': token,
      'newPassword': newPassword,
    });
  }
}
