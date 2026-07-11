// lib/features/auth/data/models/user_model.dart

import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? uniqueNumber;
  final bool isVerified;
  final String verificationStatus;
  final String status;

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        // Register response uses _id, login uses _id at top level
        id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
        firstName: j['firstName'] ?? '',
        lastName: j['lastName'] ?? '',
        email: j['email'] ?? '',
        role: j['role'] ?? 'client',
        uniqueNumber: j['uniqueNumber'],
        // verify-email response has isVerified directly
        isVerified: j['isVerified'] == true,
        verificationStatus: j['verificationStatus'] ?? 'unverified',
        status: j['status'] ?? 'active',
      );

  UserEntity toEntity() => UserEntity(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        uniqueNumber: uniqueNumber,
        isVerified: isVerified,
        verificationStatus: verificationStatus,
        status: status,
      );
}
