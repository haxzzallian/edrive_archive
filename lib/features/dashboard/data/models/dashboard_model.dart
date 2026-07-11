// lib/features/dashboard/data/models/dashboard_model.dart

import '../../domain/entities/dashboard_entity.dart';

class RideStatsModel {
  final int totalRides,
      pending,
      negotiating,
      assigned,
      accepted,
      inProgress,
      completed,
      cancelled,
      rejected;
  final double totalSpent, completionRate;

  const RideStatsModel({
    this.totalRides = 0,
    this.pending = 0,
    this.negotiating = 0,
    this.assigned = 0,
    this.accepted = 0,
    this.inProgress = 0,
    this.completed = 0,
    this.cancelled = 0,
    this.rejected = 0,
    this.totalSpent = 0,
    this.completionRate = 0,
  });

  factory RideStatsModel.fromJson(Map<String, dynamic> j) => RideStatsModel(
        totalRides: (j['totalRides'] as num?)?.toInt() ?? 0,
        pending: (j['pending'] as num?)?.toInt() ?? 0,
        negotiating: (j['negotiating'] as num?)?.toInt() ?? 0,
        assigned: (j['assigned'] as num?)?.toInt() ?? 0,
        accepted: (j['accepted'] as num?)?.toInt() ?? 0,
        inProgress: (j['inProgress'] as num?)?.toInt() ?? 0,
        completed: (j['completed'] as num?)?.toInt() ?? 0,
        cancelled: (j['cancelled'] as num?)?.toInt() ?? 0,
        rejected: (j['rejected'] as num?)?.toInt() ?? 0,
        totalSpent: (j['totalSpent'] as num?)?.toDouble() ?? 0,
        completionRate: (j['completionRate'] as num?)?.toDouble() ?? 0,
      );

  RideStatsEntity toEntity() => RideStatsEntity(
        totalRides: totalRides,
        pending: pending,
        negotiating: negotiating,
        assigned: assigned,
        accepted: accepted,
        inProgress: inProgress,
        completed: completed,
        cancelled: cancelled,
        rejected: rejected,
        totalSpent: totalSpent,
        completionRate: completionRate,
      );
}

class DashboardProfileModel {
  final String firstName, lastName, email, role;
  final String? profilePicture, phoneNumber;
  final bool isDriver, verified;
  final double ratings;

  const DashboardProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.profilePicture,
    this.phoneNumber,
    this.isDriver = false,
    this.verified = false,
    this.ratings = 0,
  });

  factory DashboardProfileModel.fromJson(Map<String, dynamic> j) {
    final userId = j['userId'] as Map<String, dynamic>? ?? j;
    return DashboardProfileModel(
      firstName: userId['firstName']?.toString() ?? '',
      lastName: userId['lastName']?.toString() ?? '',
      email: userId['email']?.toString() ?? '',
      role: userId['role']?.toString() ?? 'client',
      profilePicture: j['profilePicture']?.toString(),
      phoneNumber: j['phoneNumber']?.toString(),
      isDriver: j['isDriver'] as bool? ?? false,
      verified: j['verified'] as bool? ?? false,
      ratings: (j['ratings'] as num?)?.toDouble() ?? 0,
    );
  }

  DashboardProfileEntity toEntity() => DashboardProfileEntity(
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        profilePicture: profilePicture,
        phoneNumber: phoneNumber,
        isDriver: isDriver,
        verified: verified,
        ratings: ratings,
      );
}
