import 'auth_user.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }
}

class AuthTenant {
  final String id;
  final String name;
  final String subdomain;
  final String plan;
  final String status;

  AuthTenant({
    required this.id,
    required this.name,
    required this.subdomain,
    required this.plan,
    required this.status,
  });

  factory AuthTenant.fromJson(Map<String, dynamic> json) {
    return AuthTenant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subdomain: json['subdomain'] ?? '',
      plan: json['plan'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class LoginResponse {
  final AuthUser user;
  final AuthTokens tokens;
  final AuthTenant tenant;

  LoginResponse({
    required this.user,
    required this.tokens,
    required this.tenant,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: AuthUser.fromJson(json['user'] ?? {}),
      tokens: AuthTokens.fromJson(json['tokens'] ?? {}),
      tenant: AuthTenant.fromJson(json['tenant'] ?? {}),
    );
  }
}
