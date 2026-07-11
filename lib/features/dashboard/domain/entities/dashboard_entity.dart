// lib/features/dashboard/domain/entities/dashboard_entity.dart

class RideStatsEntity {
  final int totalRides;
  final int pending;
  final int negotiating;
  final int assigned;
  final int accepted;
  final int inProgress;
  final int completed;
  final int cancelled;
  final int rejected;
  final double totalSpent;
  final double completionRate;

  const RideStatsEntity({
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
}

class DashboardProfileEntity {
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? profilePicture;
  final String? phoneNumber;
  final bool isDriver;
  final double ratings;
  final bool verified;

  const DashboardProfileEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.profilePicture,
    this.phoneNumber,
    this.isDriver = false,
    this.ratings = 0,
    this.verified = false,
  });

  String get fullName => '$firstName $lastName'.trim();
}

class DashboardEntity {
  final RideStatsEntity stats;
  final DashboardProfileEntity profile;

  const DashboardEntity({
    required this.stats,
    required this.profile,
  });
}
