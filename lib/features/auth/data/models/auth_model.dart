// lib/features/auth/data/models/auth_model.dart
// Maps the login response: { status, message, token, role, email, _id }

import '../../domain/entities/auth_entity.dart';
import 'user_model.dart';

class AuthModel {
  final String token;
  final String role;
  final String email;
  final String userId;
  final UserModel? user;

  const AuthModel({
    required this.token,
    required this.role,
    required this.email,
    required this.userId,
    this.user,
  });

  factory AuthModel.fromLoginJson(Map<String, dynamic> j) => AuthModel(
        token: j['token'] ?? '',
        role: j['role'] ?? 'client',
        email: j['email'] ?? '',
        // login response has _id at top level (not inside user object)
        userId: j['_id']?.toString() ?? '',
        user: null, // login response has no nested user object
      );

  AuthEntity toEntity() => AuthEntity(
        token: token,
        role: role,
        email: email,
        userId: userId,
        user: user?.toEntity(),
      );
}
