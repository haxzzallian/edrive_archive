// lib/features/auth/domain/entities/auth_entity.dart
// Returned after successful login — token + user info

import 'user_entity.dart';

class AuthEntity {
  final String token;
  final String role;
  final String email;
  final String userId; // the _id field from login response
  final UserEntity? user;

  const AuthEntity({
    required this.token,
    required this.role,
    required this.email,
    required this.userId,
    this.user,
  });
}
