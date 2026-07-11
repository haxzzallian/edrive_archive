// lib/features/auth/domain/entities/user_entity.dart

class UserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role; // 'client' | 'driver'
  final String? uniqueNumber;
  final bool isVerified;
  final String verificationStatus; // 'unverified' | 'verified'
  final String status; // 'active' | 'inactive'

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.uniqueNumber,
    this.isVerified = false,
    this.verificationStatus = 'unverified',
    this.status = 'active',
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isDriver => role == 'driver';
  bool get isClient => role == 'client';
}
