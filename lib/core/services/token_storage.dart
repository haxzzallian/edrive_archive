// lib/core/services/token_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  final _storage = const FlutterSecureStorage();

  // Session keys
  static const _kToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kRole = 'user_role';
  static const _kEmail = 'user_email';
  static const _kName = 'user_name';

  // Pending verification keys (cleared after verify-email)
  static const _kPendingEmail = 'pending_email';
  static const _kPendingRole = 'pending_role';

  // In-memory cache — populated on init()
  String? token;
  String? userId;
  String? role;
  String? email;
  String? name;
  String? pendingEmail;
  String? pendingRole;

  bool get hasToken => token != null && token!.isNotEmpty;
  bool get isDriver => role == 'driver';
  bool get isClient => role == 'client';

  Future<void> init() async {
    token = await _storage.read(key: _kToken);
    userId = await _storage.read(key: _kUserId);
    role = await _storage.read(key: _kRole);
    email = await _storage.read(key: _kEmail);
    name = await _storage.read(key: _kName);
    pendingEmail = await _storage.read(key: _kPendingEmail);
    pendingRole = await _storage.read(key: _kPendingRole);
  }

  // Called after successful LOGIN
  Future<void> saveSession({
    required String token,
    required String userId,
    required String role,
    required String email,
    String? name,
  }) async {
    this.token = token;
    this.userId = userId;
    this.role = role;
    this.email = email;
    this.name = name;
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kUserId, value: userId);
    await _storage.write(key: _kRole, value: role);
    await _storage.write(key: _kEmail, value: email);
    if (name != null) await _storage.write(key: _kName, value: name);
  }

  // Called after successful REGISTER — stores email/role so OTP page
  // knows the user's email and where to route after verification
  Future<void> savePendingVerification({
    required String email,
    required String role,
  }) async {
    pendingEmail = email;
    pendingRole = role;
    await _storage.write(key: _kPendingEmail, value: email);
    await _storage.write(key: _kPendingRole, value: role);
  }

  // Called after successful VERIFY-EMAIL
  Future<void> clearPendingVerification() async {
    pendingEmail = null;
    pendingRole = null;
    await _storage.delete(key: _kPendingEmail);
    await _storage.delete(key: _kPendingRole);
  }

  // Called on logout
  Future<void> clearSession() async {
    token = null;
    userId = null;
    role = null;
    email = null;
    name = null;
    await _storage.deleteAll();
  }
}
