class ProfileEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String role;
  final double rating;
  final int totalRides;
  final bool isVerified;

  const ProfileEntity({
    required this.id, required this.name, required this.email,
    required this.phone, required this.role,
    this.avatarUrl, this.rating = 5.0, this.totalRides = 0, this.isVerified = false,
  });
}
